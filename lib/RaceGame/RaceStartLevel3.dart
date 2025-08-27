import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wandquest/BluetoothPages.dart/WandQuestData.dart';
import 'package:wandquest/RaceGame/RacePlayingLevel3.dart';
import 'package:wandquest/colors.dart'; // Assuming this is where ColorsAsset.primary is.
import 'package:wandquest/Pages/HomePage.dart'; // Import your HomePage

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

// Enum to manage the different UI states
enum RaceStartState { initial, finding, preGame, countdown }

class RaceStartLevel3 extends StatefulWidget {
  const RaceStartLevel3({super.key});

  @override
  State<RaceStartLevel3> createState() => _RaceStartLevel3State();
}

class _RaceStartLevel3State extends State<RaceStartLevel3> {
  // State variables to control the UI
  RaceStartState _currentState = RaceStartState.initial;
  String _countdownDisplay = "3";
  int _countdownNumber = 3;
  Timer? _timer;

  // Function to start the main game countdown
  void _startGameCountdown() {
    setState(() {
      _currentState = RaceStartState.countdown;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNumber > 1) {
        setState(() {
          _countdownNumber--;
          _countdownDisplay = '$_countdownNumber';
        });
      } else if (_countdownNumber == 1) {
        setState(() {
          _countdownNumber--;
          _countdownDisplay = 'START!';
        });
      } else {
        timer.cancel();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const RacePlayingLevel3()),
        );
      }
    });
  }
  
  // Function to handle finding a player
  void _findPlayer() {
    setState(() {
      _currentState = RaceStartState.finding;
    });

    // Fake loading delay
    Timer(const Duration(seconds: 3), () {
      _showPlayerFoundDialog();
    });
  }
  
  // Player Found Dialog
  // Player Found Dialog
void _showPlayerFoundDialog() {
  int dialogCountdown = 3;
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      // Use a StatefulBuilder to update the dialog content
      return StatefulBuilder(
        builder: (context, setDialogState) {
          // Start a timer for the dialog's countdown
          Timer.periodic(const Duration(seconds: 1), (timer) {
            if (dialogCountdown > 1) {
              setDialogState(() {
                dialogCountdown--;
              });
            } else {
              timer.cancel();
              Navigator.of(context).pop(); // Close the dialog
              setState(() {
                _currentState = RaceStartState.preGame; // Switch to the pre-game menu
              });
            }
          });

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              decoration: BoxDecoration(
                gradient: ColorsAsset.primary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "PLAYER FOUND!",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      shadows: [
                        Shadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  Text(
                    "Starting in... $dialogCountdown",
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
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
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: screenWidth * 0.9,
                  height: screenHeight * 0.52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.59, 0.8, 1.0],
                      colors: [
                        const Color(0xFF5500FF).withOpacity(0.45),
                        const Color(0xFFF0009F).withOpacity(0.45),
                        const Color(0xFFFF0073).withOpacity(0.45),
                        const Color(0xFFFF0004).withOpacity(0.45),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: screenWidth * 0.85,
                  height: screenHeight * 0.5,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: _buildContentByState(context), // Dynamically build content
                ),
                Positioned(
                  top: screenHeight * -0.05,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.015,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCF6DFC),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: StrokedText(
                      text: _currentState == RaceStartState.finding ? "Finding Player..." : "RACE'S GAME",
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      strokeWidth: 0.8,
                      letterSpacing: 1.36,
                    ),
                  ),
                ),
                if (_currentState == RaceStartState.initial)
                  Positioned(
                    bottom: screenHeight * -0.022,
                    right: screenWidth * 0.016,
                    child: SizedBox(
                      width: screenWidth * 0.43,
                      height: screenWidth * 0.43,
                      child: Image.asset(
                        'assets/RaceIcon.png',
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.image_not_supported, color: Colors.purple, size: 124);
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to build content based on the current state
  Widget _buildContentByState(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    switch (_currentState) {
      case RaceStartState.finding:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 120),
            const CircularProgressIndicator(color: Color(0xFF8827D7)),
            const SizedBox(height: 40),
            const StrokedText(
              text: 'Please wait',
              color: Color(0xFF8827D7),
              fontSize: 24,
              fontWeight: FontWeight.w800,
              strokeWidth: 3,
              strokeColor: Colors.white,
            ),
            SizedBox(height: screenHeight * 0.15),
             Row(
              children: [
                SizedBox(width: screenWidth * 0.04),
                Container(
                  width: 142,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFF06A59), Color(0xFFE94057)]),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                  ),
                  child: const Center(
                    child: StrokedText(
                      text: 'RETURN',
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      strokeWidth: 0.6,
                      letterSpacing: 1,
                      strokeColor: Color(0xFF7B18B9),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case RaceStartState.preGame:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.08),
            Container(
              width: 206,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF8E2DE2), Color(0xFFEA4335)]),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: const Center(
                child: StrokedText(
                  text: 'LEADERBOARD',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  strokeWidth: 3.6,
                  letterSpacing: 1.6,
                  strokeColor: Color(0xFF7B18B9),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.04),
            GestureDetector(
              onTap: () {
                context.read<WandQuestData>().WandQuestWrite?.write(utf8.encode("RS"));
                _startGameCountdown();
              },
              child: Container(
                width: 232,
                height: 68,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF3CD663)]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Center(
                  child: StrokedText(
                    text: 'PLAY',
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    strokeWidth: 4.8,
                    letterSpacing: 1.8,
                    strokeColor: Color(0xFF7B18B9),
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.12),
            Row(
              children: [
                SizedBox(width: screenWidth * 0.06),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage())),
                  child: Container(
                    width: 142,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF06A59), Color(0xFFE94057)]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: StrokedText(
                        text: 'RETURN',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        strokeWidth: 0.6,
                        letterSpacing: 1,
                        strokeColor: Color(0xFF7B18B9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      case RaceStartState.countdown:
        return Center(
          child: StrokedGradientText(
            text: _countdownDisplay,
            fontSize: _countdownDisplay == 'START!' ? 68 : 200,
            strokeWidth: 12,
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: [0.0, 0.59, 1.0],
              colors: [Color(0xFF5500FF), Color(0xFFF0009F), Color(0xFFFF0073)],
            ),
            shadows: [Shadow(color: Colors.black.withOpacity(0.25), blurRadius: 20, offset: const Offset(4, 4))],
          ),
        );
      case RaceStartState.initial:
      default:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.098),
            Container(
              width: 220,
              height: 55,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFF99F3B), Color(0xFFE87A1C)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: const Center(
                child: StrokedText(
                  text: 'Search Name',
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  strokeWidth: 0.1,
                  letterSpacing: 1,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            GestureDetector(
              onTap: _findPlayer,
              child: Container(
                width: 220,
                height: 55,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00D2FF), Color(0xFF3CD663)]),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                ),
                child: const Center(
                  child: StrokedText(
                    text: 'Find Nearby Player',
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    strokeWidth: 0.1,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.14),
            Row(
              children: [
                SizedBox(width: screenWidth * 0.06),
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage())),
                  child: Container(
                    width: 142,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF06A59), Color(0xFFE94057)]),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))],
                    ),
                    child: const Center(
                      child: StrokedText(
                        text: 'RETURN',
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        strokeWidth: 0.6,
                        letterSpacing: 1,
                        strokeColor: Color(0xFF7B18B9),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }
}
