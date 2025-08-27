import "package:camera/camera.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart"; // <-- import this
import "package:provider/provider.dart";
import "package:wandquest/BluetoothPages.dart/WandQuestData.dart";
import "package:wandquest/MembershipPages/BMIResultPage.dart";
import "package:wandquest/MembershipPages/LoginPage.dart";
import "package:wandquest/MembershipPages/SignupPage.dart";
import "package:wandquest/MembershipPages/StartPage.dart";
import "package:wandquest/Pages/HomePage.dart";
import "package:wandquest/PoseGame/PosePlayingLevel3.dart";
import "package:wandquest/PoseGame/PoseStartLevel3.dart";
import "package:wandquest/RaceGame/RaceStartLevel3.dart";
import "package:wandquest/SqueezeGame/SqueezeStartLevel3.dart";
import "package:wandquest/test_pose.dart";

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Hide status bar and navigation bar
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  _cameras = await availableCameras();
  runApp(
    ChangeNotifierProvider(
      create: (_) => WandQuestData(),
      child:  MyApp(),
    ),
  );
}
bool devM = false;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: devM ? CameraApp(cameras: _cameras) : HomePage(),
    );
  }
}
