import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:wandquest/BluetoothPages.dart/FindingPage.dart';
import 'package:wandquest/BluetoothPages.dart/FoundedPage.dart';
import 'package:wandquest/BluetoothPages.dart/WandQuestData.dart';
import 'package:wandquest/RunGame/RunStartLevel3.dart';
import 'package:wandquest/SqueezeGame/SqueezeStartLevel3.dart';
import 'package:wandquest/RaceGame/RaceStartLevel3.dart';
import 'package:wandquest/PoseGame/PoseStartLevel3.dart';
import 'package:wandquest/colors.dart'; // Your custom colors file
import 'package:carousel_slider/carousel_slider.dart';

class StrokedGradientText extends StatelessWidget {
  const StrokedGradientText({
    super.key,
    required this.text,
    required this.gradient,
    this.fontSize = 48,
    this.strokeWidth = 6,
    this.fontWeight = FontWeight.w800,
  });

  final String text;
  final Gradient gradient;
  final double fontSize;
  final double strokeWidth;
  final FontWeight fontWeight;

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
            foreground: Paint()
              ..shader = gradient.createShader(
                // A more dynamic Rect for the shader
                Rect.fromLTWH(0.0, 0.0, fontSize * text.length * 0.6, fontSize),
              ),
          ),
        ),
      ],
    );
  }
}

// WIDGET for solid color text with a white border
class StrokedText extends StatelessWidget {
  const StrokedText({
    super.key,
    required this.text,
    required this.color,
    this.fontSize = 14,
    this.strokeWidth = 3,
    this.fontWeight = FontWeight.w600,
    this.letterSpacing, // Added for letter spacing
  });

  final String text;
  final Color color;
  final double fontSize;
  final double strokeWidth;
  final FontWeight fontWeight;
  final double? letterSpacing; // Added for letter spacing

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
            letterSpacing: letterSpacing, // Applied letter spacing
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = Colors.white,
          ),
        ),
        // The Solid Color Fill (top layer)
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: fontSize,
            fontWeight: fontWeight,
            letterSpacing: letterSpacing, // Applied letter spacing
            color: color,
          ),
        ),
      ],
    );
  }
}

class QuestCard extends StatelessWidget {
  const QuestCard({
    super.key,
    required this.title,
    required this.reward,
    required this.currentProgress,
    required this.totalProgress,
    required this.progressGradient,
    required this.buttonColor,
    required this.titleGradient,
  });

  final String title;
  final String reward;
  final int currentProgress;
  final int totalProgress;
  final Gradient progressGradient;
  final Color buttonColor;
  final Gradient titleGradient;

  @override
  Widget build(BuildContext context) {
    final double progressPercent = currentProgress / totalProgress;

    return Container(
      width: 315,
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StrokedGradientText(
                text: title,
                gradient: titleGradient,
                fontSize: 16,
                strokeWidth: 3,
                fontWeight: FontWeight.w800,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: buttonColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  reward,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE9E3F3),
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progressPercent,
                child: Container(
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: progressGradient,
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$currentProgress/$totalProgress',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ShopItemCard extends StatelessWidget {
  const ShopItemCard({
    super.key,
    required this.label,
    required this.statusText,
    required this.statusColor,
    required this.gradient,
    this.size = 100.0,
    this.borderColor,
    this.selectedBorderColor,
    this.isSelected = false,
    this.isPurchased = false,
    this.onTap,
    this.backgroundImage,
  });

  final String label;
  final String statusText;
  final Color statusColor;
  final Gradient gradient;
  final double size;
  final Color? borderColor;
  final Color? selectedBorderColor;
  final bool isSelected;
  final bool isPurchased;
  final VoidCallback? onTap;
  final String? backgroundImage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: size,
            height: size,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(
                      color: selectedBorderColor ?? Colors.transparent,
                      width: 5,
                    )
                  : null,
              color: !isSelected ? borderColor : Colors.transparent,
              borderRadius: BorderRadius.circular(24),
              boxShadow: isPurchased && !isSelected
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (backgroundImage != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Transform.scale(
                        scale: 0.7,
                        child: Image.asset(
                          backgroundImage!,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  Center(
                    child: StrokedText(
                      text: label,
                      color: Colors.white,
                      fontSize: size == 140 ? 28 : 20,
                      strokeWidth: 1.4,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          StrokedText(
            text: statusText,
            color: statusColor,
            fontSize: 13,
            strokeWidth: 2.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key, this.connectionstate});

  var connectionstate;
  final connect_instance = FoundedPage();

  @override
  State<HomePage> createState() => _HomePageState();
}

enum GameplayMode { single, multi }

enum PointType { r, s }

class _HomePageState extends State<HomePage> {
  // Gameplay State
  GameplayMode _selectedMode = GameplayMode.single;
  int _currentCarouselIndex = 0;

  // --- POINT AND SHOP STATE ---
  int rPoints = 4250;
  int sPoints = 2550;

  int _selectedThemeIndex = 0;
  int _selectedUpgradeIndex = 0;

  Set<int> _purchasedThemes = {};
  Set<int> _purchasedUpgrades = {};

  final List<Map<String, String>> singlePlayerItems = [
    {'name': 'Run', 'path': 'assets/RunCard.png'},
    {'name': 'Squeeze', 'path': 'assets/SqueezeCard.png'},
    {'name': 'Pose', 'path': 'assets/PoseCard.png'},
  ];

  final List<Map<String, String>> multiPlayerItems = [
    {'name': 'Relay', 'path': 'assets/RelayCard.png'},
    {'name': 'Race', 'path': 'assets/RaceCard.png'},
  ];

  // --- NEW BLUETOOTH DIALOG ---
  void _showBluetoothDialog(BuildContext context, bool isConnected) {
    final bluetoothData = Provider.of<WandQuestData>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: ColorsAsset.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const StrokedText(
                  text: 'Bluetooth',
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  strokeWidth: 0.1,
                  letterSpacing: 0.7,
                ),
                const SizedBox(height: 16),
                Text(
                  isConnected
                      ? "Device is connected.\nDisconnect now?"
                      : "Bluetooth is not connected.\nConnect now?",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        bluetoothData.signOut();
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 124,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xFFFF4646),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isConnected ? 'DISCONNECT' : 'CANCEL',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!isConnected)
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const FindingPage(),
                            ),
                          );
                        },
                        child: Container(
                          width: 124,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF3CD663),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'CONNECT',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPurchaseDialog(
    BuildContext context,
    String itemName,
    int price,
    PointType pointType,
    int itemIndex,
    bool isTheme,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              gradient: ColorsAsset.primary,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Confirm Purchase",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    "Buy $itemName for $price ${pointType == PointType.r ? 'R-PTS' : 'S-PTS'}?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "CANCEL",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8827D7),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (pointType == PointType.r) {
                            if (rPoints >= price) {
                              rPoints -= price;
                              if (isTheme) _purchasedThemes.add(itemIndex);
                            }
                          } else {
                            if (sPoints >= price) {
                              sPoints -= price;
                              if (!isTheme) _purchasedUpgrades.add(itemIndex);
                            }
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3CD663),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            "CONFIRM",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Permission.bluetoothScan.request();

  }

  void sendStringToArduino(BuildContext context, String message) {
  // 1. Get the provider instance here, inside the function
  final bluetoothData = Provider.of<WandQuestData>(context, listen: false);

  // 2. Check if the write characteristic is available
  if (bluetoothData.WandQuestWrite != null) {
    try {
      // 3. Encode the string to bytes and send it
      bluetoothData.WandQuestWrite!.write(utf8.encode(message));
      print("Sent '$message' successfully.");
    } catch (e) {
      print("Error sending message: $e");
    }
  } else {
    print("Write characteristic is not available.");
  }
}

  Future<void> _requestPermissions() async {
    final bluetoothScan = await Permission.bluetoothScan.request();
    final bluetoothConnect = await Permission.bluetoothConnect.request();
    final bluetooth = await Permission.bluetooth
        .request(); // For older versions
    final location = await Permission.locationWhenInUse.request();

    if (bluetoothScan.isGranted &&
        bluetoothConnect.isGranted &&
        location.isGranted) {
      print("Permissions granted");
    } else {
      print("Permissions denied");
    }
  }


  Widget build(BuildContext context) {
    final List<Map<String, String>> currentList =
        _selectedMode == GameplayMode.single
        ? singlePlayerItems
        : multiPlayerItems;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Appbar
            Container(
              width: 390,
              height: 84,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 8),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 152,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: ColorsAsset.primary,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/ProfilePic.png', width: 30),
                          const SizedBox(width: 14),
                          Text(
                            'Hi Natthan',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Consumer<WandQuestData>(
                      builder: (context, bluetoothData, child) {
                        return GestureDetector(
                          onTap: () {
                            _showBluetoothDialog(context, bluetoothData.isConnected);
                          },
                          child: Container(
                            width: 42,
                            height: 42,
                            
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(500),
                              color: bluetoothData.isConnected
                                  ?  Color(
                                      0xFF00FF73,
                                    )
                                  :  Color(
                                      0xFFF1615D,
                                    ), 
                            ),
                            child: Center(
                              child: Icon(
                                bluetoothData.isConnected
                                    ? Icons.bluetooth_connected
                                    : Icons.bluetooth_disabled,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(width: 10),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(500),
                        color: Colors.white,
                        border: Border.all(
                          width: 2,
                          color: const Color(0xFF8827D7),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.notifications,
                          color: Color(0xFFFFC107),
                          size: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Points container
            Container(
              width: 322,
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(0, 8),
                    blurRadius: 12,
                  ),
                ],
                gradient: ColorsAsset.primary,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Natthan’s Points',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StrokedGradientText(
                              text: '$rPoints R-Points',
                              fontSize: 20,
                              strokeWidth: 3,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF99F3B), Color(0xFFE87A1C)],
                              ),
                            ),
                            const StrokedText(
                              text: 'From Run Games',
                              color: Color(0xFF8827D7),
                              fontSize: 11,
                              strokeWidth: 2.5,
                            ),
                            const SizedBox(height: 8),
                            StrokedGradientText(
                              text: '$sPoints S-Points',
                              fontSize: 20,
                              strokeWidth: 3,
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFE5190), Color(0xFFE43A5D)],
                              ),
                            ),
                            const StrokedText(
                              text: 'From Pose and squeeze Games',
                              color: Color(0xFF8827D7),
                              fontSize: 11,
                              strokeWidth: 2.5,
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.military_tech,
                          color: Colors.white,
                          size: 80,
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Quest',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quest Section
            Column(
              children: const [
                QuestCard(
                  title: 'RUN 5000M',
                  reward: '1000 R-PTS',
                  currentProgress: 4000,
                  totalProgress: 5000,
                  buttonColor: Color(0xFFF06A59),
                  titleGradient: LinearGradient(
                    colors: [Color(0xFFF99F3B), Color(0xFFE87A1C)],
                  ),
                  progressGradient: LinearGradient(
                    colors: [Color(0xFFF99F3B), Color(0xFFF06A59)],
                  ),
                ),
                QuestCard(
                  title: 'SQUEEZE 100TIMES',
                  reward: '50 R-PTS',
                  currentProgress: 40,
                  totalProgress: 100,
                  buttonColor: Color(0xFFF06A59),
                  titleGradient: LinearGradient(
                    colors: [Color(0xFF8827D7), Color(0xFFC882E4)],
                  ),
                  progressGradient: LinearGradient(
                    colors: [Color(0xFF8827D7), Color(0xFFC882E4)],
                  ),
                ),
                QuestCard(
                  title: 'POSE 100TIMES',
                  reward: '50 R-PTS',
                  currentProgress: 100,
                  totalProgress: 100,
                  buttonColor: Color(0xFF3CD663),
                  titleGradient: LinearGradient(
                    colors: [Color(0xFF8827D7), Color(0xFFC882E4)],
                  ),
                  progressGradient: LinearGradient(
                    colors: [Color(0xFF8827D7), Color(0xFF3CD663)],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Gameplay Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        rPoints += 500;
                        sPoints += 500;
                      });
                    },
                    child: Text(
                      'GAMEPLAY',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 22),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMode = GameplayMode.single;
                      _currentCarouselIndex = 0;
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: _selectedMode == GameplayMode.single
                          ? const LinearGradient(
                              colors: [Color(0xFFB94FFF), Color(0xFF63FF94)],
                            )
                          : null,
                      color: _selectedMode != GameplayMode.single
                          ? Colors.grey[300]
                          : null,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Center(
                      child: Text(
                        'Single',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: _selectedMode == GameplayMode.single
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMode = GameplayMode.multi;
                      _currentCarouselIndex = 0;
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: _selectedMode == GameplayMode.multi
                          ? const LinearGradient(
                              colors: [Color(0xFF18A4FF), Color(0xFF3CD663)],
                            )
                          : null,
                      color: _selectedMode != GameplayMode.multi
                          ? Colors.grey[300]
                          : null,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: Text(
                        'Multi',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          color: _selectedMode == GameplayMode.multi
                              ? Colors.white
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            CarouselSlider.builder(
              itemCount: currentList.length,
              itemBuilder: (context, index, realIndex) {
                final item = currentList[index];
                final bool isSelected = _currentCarouselIndex == index;

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 4)
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      item['path']!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text(
                              'Image\nnot found',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              options: CarouselOptions(
                height: 300,
                viewportFraction: 0.6,
                enlargeCenterPage: true,
                enableInfiniteScroll: false,
                onPageChanged: (index, reason) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
              ),
            ),

            GestureDetector(
              onTap: () {
                final activeList = _selectedMode == GameplayMode.single
                    ? singlePlayerItems
                    : multiPlayerItems;
                final selectedCardName =
                    activeList[_currentCarouselIndex]['name'];
                if (selectedCardName == "Squeeze") {

                  // sendStringToArduino(context, 'SS');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SqueezeStartLevel3(),
                    ),
                  );
                }
                if (selectedCardName == "Run") {

                  // sendStringToArduino(context, 'SS');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RunStartLevel3(),
                    ),
                  );
                }
                if (selectedCardName == "Race") {
                  // sendStringToArduino(context, 'RS');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RaceStartLevel3(),
                    ),
                  );
                }
                if (selectedCardName == "Pose") {

                  // sendStringToArduino(context, 'PS');

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PoseStartLevel3(),
                    ),
                  );
                }
                print('Start button clicked! Selected card: $selectedCardName');
              },
              child: Container(
                width: 186,
                height: 66,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3CD663), Color(0xFF63FF94)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF8827D7), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: StrokedText(
                    text: 'START!',
                    color: Colors.white,
                    fontSize: 28,
                    strokeWidth: 3,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // --- SHOP SECTION ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _purchasedThemes.clear();
                        _purchasedUpgrades.clear();
                      });
                    },
                    child: Text(
                      'SHOP',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: StrokedGradientText(
                      text: "THEME",
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFE5190), Color(0xFF8827D7)],
                      ),
                      fontSize: 20,
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShopItemCard(
                        size: 146,
                        label: 'PURPLE',
                        statusText: 'DEFAULT',
                        statusColor: const Color(0xFFFE5190),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC882E4), Color(0xFF8827D7)],
                        ),
                        isSelected: _selectedThemeIndex == 0,
                        selectedBorderColor: const Color(0xFF6A0DAD),
                        onTap: () => setState(() => _selectedThemeIndex = 0),
                      ),
                      const SizedBox(width: 20),
                      ShopItemCard(
                        size: 146,
                        label: 'PINK',
                        statusText: _purchasedThemes.contains(1)
                            ? 'PURCHASED'
                            : '1700 R-PTS',
                        statusColor: _purchasedThemes.contains(1)
                            ? const Color(0xFF8827D7)
                            : const Color(0xFFFE5190),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFC1E0), Color(0xFFFF86B5)],
                        ),
                        borderColor: const Color(0xFFE63984),
                        isSelected: _selectedThemeIndex == 1,
                        selectedBorderColor: const Color(0xFFE63984),
                        onTap: () {
                          if (_purchasedThemes.contains(1)) {
                            setState(() => _selectedThemeIndex = 1);
                          } else {
                            _showPurchaseDialog(
                              context,
                              'Pink Theme',
                              1700,
                              PointType.r,
                              1,
                              true,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: StrokedGradientText(
                      text: "UPGRADE",
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFE5190), Color(0xFF8827D7)],
                      ),
                      fontSize: 20,
                      strokeWidth: 4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ShopItemCard(
                        size: 100,
                        label: 'LV.1',
                        statusText: 'DEFAULT',
                        statusColor: const Color(0xFFFE5190),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC882E4), Color(0xFF8827D7)],
                        ),
                        borderColor: const Color(0xFFCD7F32),
                        isSelected: _selectedUpgradeIndex == 0,
                        selectedBorderColor: const Color(0xFF6A0DAD),
                        onTap: () => setState(() => _selectedUpgradeIndex = 0),
                      ),
                      const SizedBox(width: 16),
                      ShopItemCard(
                        size: 100,
                        label: 'LV.2',
                        statusText: _purchasedUpgrades.contains(1)
                            ? 'PURCHASED'
                            : '500 S-PTS',
                        statusColor: _purchasedUpgrades.contains(1)
                            ? const Color(0xFF8827D7)
                            : const Color(0xFFFE5190),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC882E4), Color(0xFF8827D7)],
                        ),
                        borderColor: const Color(0xFFC0C0C0),
                        isPurchased: _purchasedUpgrades.contains(1),
                        isSelected: _selectedUpgradeIndex == 1,
                        selectedBorderColor: const Color(0xFF6A0DAD),
                        onTap: () {
                          if (_purchasedUpgrades.contains(1)) {
                            setState(() => _selectedUpgradeIndex = 1);
                          } else {
                            _showPurchaseDialog(
                              context,
                              'Level 2',
                              500,
                              PointType.s,
                              1,
                              false,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      ShopItemCard(
                        size: 100,
                        label: 'LV.3',
                        statusText: _purchasedUpgrades.contains(2)
                            ? 'PURCHASED'
                            : '1000 S-PTS',
                        statusColor: _purchasedUpgrades.contains(2)
                            ? const Color(0xFF8827D7)
                            : const Color(0xFFFE5190),
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC882E4), Color(0xFF8827D7)],
                        ),
                        borderColor: const Color(0xFFFFD700),
                        isSelected: _selectedUpgradeIndex == 2,
                        selectedBorderColor: const Color(0xFF6A0DAD),
                        backgroundImage: 'assets/LV3Background.png',
                        onTap: () {
                          if (_purchasedUpgrades.contains(2)) {
                            setState(() => _selectedUpgradeIndex = 2);
                          } else {
                            _showPurchaseDialog(
                              context,
                              'Level 3',
                              1000,
                              PointType.s,
                              2,
                              false,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
