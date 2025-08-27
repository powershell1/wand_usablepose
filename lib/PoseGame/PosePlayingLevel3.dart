import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wandquest/BluetoothPages.dart/WandQuestData.dart';
import 'package:wandquest/colors.dart'; // Assuming this is where ColorsAsset.primary is.
import 'package:wandquest/Pages/HomePage.dart'; // Import your HomePage

import 'dart:io';

import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:wandquest/Magic/MatrixComputation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

// Reusable widget for text with a stroke and solid color fill
class StrokedText extends StatelessWidget {
  const StrokedText({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 14,
    this.strokeWidth = 3,
    this.fontWeight = FontWeight.w600,
    this.letterSpacing,
    this.strokeColor = Colors.white,
    this.shadows,
  });

  final String text;
  final Color color;
  final double fontSize;
  final double strokeWidth;
  final FontWeight fontWeight;
  final double? letterSpacing;
  final Color strokeColor;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            shadows: shadows,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing,
            shadows: shadows,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Reusable widget for text with a stroke and gradient fill
class StrokedGradientText extends StatelessWidget {
  const StrokedGradientText({
    super.key,
    required this.text,
    required this.gradient,
    this.fontSize = 48,
    this.strokeWidth = 6,
    this.fontWeight = FontWeight.w800,
    this.shadows,
  });

  final String text;
  final Gradient gradient;
  final double fontSize;
  final double strokeWidth;
  final FontWeight fontWeight;
  final List<Shadow>? shadows;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The Text Border (bottom layer)
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            shadows: shadows,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.white,
          ),
        ),
        // The Gradient Fill (top layer)
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            shadows: shadows,
            foreground: Paint()
              ..shader = gradient.createShader(
                Rect.fromLTWH(0.0, 0.0, fontSize * text.length * 0.5, fontSize),
              ),
          ),
        ),
      ],
    );
  }
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


class PosePlayingLevel3 extends StatefulWidget {
  const PosePlayingLevel3({super.key});

  @override
  State<PosePlayingLevel3> createState() => _PosePlayingLevel3State();
}

class _PosePlayingLevel3State extends State<PosePlayingLevel3> {
  // Timer and progress variables
  Timer? _timer;
  int _remainingSeconds = 180; 
  final int _totalPoses = 5;
  int _currentPoses = 2;


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
  void dispose() {
    controller.dispose();
    poseDetector.close();
    interpreter.close();
    _timer?.cancel();
    super.dispose();
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
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        print("times up!");
        context.read<WandQuestData>().WandQuestWrite?.write(utf8.encode("TM"));
        _showRewardDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor().toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  void _showRewardDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8827D7), width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StrokedGradientText(
                  text: 'CONGRATULATION!',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  strokeWidth: 5,
                  gradient: LinearGradient(colors: [Color(0xFFFE5190), Color(0xFF8827D7)]),
                ),
                const SizedBox(height: 22),
                const StrokedText(
                  text: 'REWARDS',
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  strokeWidth: 4,
                  strokeColor: Color(0xFF4c0082),
                ),
                const SizedBox(height: 6),
                const StrokedText(
                  text: '150',
                  color: Color(0xFF333333),
                  fontSize: 100,
                  fontWeight: FontWeight.w800,
                  strokeWidth: 8,
                  strokeColor: Colors.white,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))],
                ),
                const StrokedGradientText(
                  text: 'R-POINTS',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  strokeWidth: 4,
                  gradient: LinearGradient(colors: [Color(0xFFF99F3B), Color(0xFFE87A1C)]),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) =>  HomePage()),
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF06A59),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4c0082), width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: StrokedText(
                        text: 'RETURN',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        strokeWidth: 4,
                        strokeColor: Color(0xFF4c0082),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPauseDialog() {
    _pauseTimer();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8827D7), width: 4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    _startTimer();
                  },
                  child: Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF63FF94),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4c0082), width: 3),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: StrokedText(
                        text: 'RESUME',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        strokeWidth: 4,
                        strokeColor: Color(0xFF4c0082),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    
                    Navigator.of(context).pop();
                    context.read<WandQuestData>().WandQuestWrite?.write(utf8.encode("TM"));
                    
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  child: Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF06A59),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF4c0082), width: 3),
                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: StrokedText(
                        text: 'EXIT',
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        strokeWidth: 4,
                        strokeColor: Color(0xFF4c0082),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/SqueezeStartLevel3BG.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(gradient: ColorsAsset.primary),
                child: const Center(child: Text('Background not found', style: TextStyle(color: Colors.white))),
              );
            },
          ),
          // Main Content Column
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.032),
                  // "POSE" Title
                  Center(
                    child: GestureDetector(
                      onTap: _showPauseDialog,
                      child: Text(
                        'POSE',
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 3.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  // Black container for the image
                  Container(
                    width: screenWidth * 0.8,
                    height: screenHeight * 0.45,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white, width: 4)
                    ),
                    // child: const Center(child: Text('Image Area', style: TextStyle(color: Colors.white))),
                  ),
                  SizedBox(height: 28,),
                  // Progress Counter
                  StrokedText(
                    text: '$_currentPoses/$_totalPoses',
                    color: const Color(0xFF4c0082),
                    fontSize: 80,
                    fontWeight: FontWeight.w800,
                    strokeWidth: 8,
                    strokeColor: Colors.white,
                  ),
                SizedBox(height: 2,), // ADJUSTED SPACE
                  // Timer at the bottom
                  Center(
                    child: StrokedGradientText(
                      text: _formatTime(_remainingSeconds),
                      fontSize: 80,
                      fontWeight: FontWeight.w800,
                      strokeWidth: 8,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E2DE2), Color(0xFFFE5190)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02), // REDUCED BOTTOM PADDING
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
