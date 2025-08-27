import 'dart:io';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:wandquest/Magic/MatrixComputation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

/// CameraApp is the Main Application.
class CameraApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  /// Default Constructor
  const CameraApp({super.key, required this.cameras});

  @override
  State<CameraApp> createState() => _CameraAppState();
}

final int _cameraIndex = 0;

final _orientations = {
  DeviceOrientation.portraitUp: 0,
  DeviceOrientation.landscapeLeft: 90,
  DeviceOrientation.portraitDown: 180,
  DeviceOrientation.landscapeRight: 270,
};

final poseIndexToString = {
  0: "Baseball Pose",
  1: "Flexing Pose",
  2: "Statue of Liberty Pose",
  3: "Superman Pose",
  4: "Ultraman Pose",
};

class _CameraAppState extends State<CameraApp> {
  late Interpreter interpreter;
  late CameraController controller;
  final options = PoseDetectorOptions(
    model: PoseDetectionModel.accurate,
    mode: PoseDetectionMode.stream,
  );
  late final poseDetector = PoseDetector(options: options);

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final camera = widget.cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
      _orientations[controller.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  bool isComputedFinished = true;

  Future<void> onAvailable(CameraImage image) async {
    if (!isComputedFinished) return;
    isComputedFinished = false;
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) {
      isComputedFinished = true;
      return;
    }
    final List<Pose> poses = await poseDetector.processImage(inputImage);
    if (poses.isEmpty) {
      isComputedFinished = true;
      return;
    }
    Pose pose = poses.first;
    List<Vec3> computedCords = computeNormalizedCoords(pose.landmarks);
    List<double> flatList = computedCords.expand((e) => e).toList();
    var output = List.filled(5, 0).reshape([1, 5]);
    interpreter.run(flatList.reshape([1, 24]), output);
    var highestIndex = 0;
    for (var i = 1; i < output[0].length; i++) {
      if (output[0][i] > output[0][highestIndex]) {
        highestIndex = i;
      }
    }
    String matchedPose = poseIndexToString[highestIndex] ?? "Unknown Pose";
    print(matchedPose);
    isComputedFinished = true;
  }

  Future<void> interpreterPromise() async {
    interpreter = await Interpreter.fromAsset('assets/pose_cls.tflite');
    print('Interpreter created successfully');
  }

  @override
  void initState() {
    super.initState();
    interpreterPromise();
    controller = CameraController(
      widget.cameras[_cameraIndex],
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup
                .nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );
    controller
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
          print('Camera initialized');
          controller.startImageStream(onAvailable);
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case 'CameraAccessDenied':
                // Handle access errors here.
                break;
              default:
                // Handle other errors here.
                break;
            }
          }
        });
  }

  @override
  void dispose() {
    controller.dispose();
    poseDetector.close();
    interpreter.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return Container();
    }
    return MaterialApp(home: CameraPreview(controller));
  }
}
