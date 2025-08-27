import 'dart:async'; // Required for the Timer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wandquest/BluetoothPages.dart/WandQuestData.dart';
import 'package:wandquest/SqueezeGame/SqueezePlayingLevel3.dart';
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

class SqueezeStartLevel3 extends StatefulWidget {
  const SqueezeStartLevel3({super.key});

  @override
  State<SqueezeStartLevel3> createState() => _SqueezeStartLevel3State();
}

class _SqueezeStartLevel3State extends State<SqueezeStartLevel3> {
  // State variables to control the UI
  bool _showCountdown = false;
  String _countdownDisplay = "3";
  int _countdownNumber = 3;
  Timer? _timer;

  // Function to start the countdown
  void _startCountdown() {
    setState(() {
      _showCountdown = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownNumber > 1) {
        setState(() {
          _countdownNumber--;
          _countdownDisplay = '$_countdownNumber';
        });
      } else if (_countdownNumber == 1) {
        setState(() {
          _countdownNumber--; // To stop this block from running again
          _countdownDisplay = 'START!';
        });
      } else {
        timer.cancel();
        // Navigate to HomePage after countdown finishes
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SqueezePlayingLevel3()),
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Important to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get device dimensions for responsive UI
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
                child: const Center(
                  child: Text(
                    'Background not found',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),

          // Main UI Content
          Center(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Gradient container behind the main card
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

                // Main white container
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
                      ),
                    ],
                  ),
                  // Conditionally show menu or countdown
                  child: _showCountdown
                      ? Center(
                          child: StrokedGradientText(
                            text: _countdownDisplay,
                            fontSize: _countdownDisplay == 'START!' ? 68 : 200,
                            strokeWidth: 12,
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [0.0, 0.59, 1.0],
                              colors: [
                                Color(0xFF5500FF),
                                Color(0xFFF0009F),
                                Color(0xFFFF0073),
                              ],
                            ),
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 20,
                                offset: const Offset(4, 4),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(height: screenHeight * 0.05),
                            // Leaderboard Button
                            Container(
                              width: 206,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF8E2DE2),
                                    Color(0xFFEA4335),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
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
                            // Play Button
                            GestureDetector(
                              onTap: () {
                                context.read<WandQuestData>().WandQuestWrite?.write(utf8.encode("SS"));
                                
                                _startCountdown();
                              },
                              child: Container(
                                width: 232,
                                height: 68,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF00D2FF),
                                      Color(0xFF3CD663),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
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
                            // Return Button
                            Row(
                              children: [
                                SizedBox(width: screenWidth * 0.06),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>  HomePage(),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    width: 142,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF06A59),
                                          Color(0xFFE94057),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
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
                        ),
                ),

                // Title
                Positioned(
                  top: screenHeight * -0.04,
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
                    child: const StrokedText(
                      text: "SQUEEZE'S GAME",
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      strokeWidth: 0.8,
                      letterSpacing: 1.36,
                    ),
                  ),
                ),

                // Character Image
                if (!_showCountdown) // Only show character on the menu screen
                  Positioned(
                    bottom: screenHeight * -0.006,
                    right: screenWidth * -0.038,
                    child: SizedBox(
                      width: screenWidth * 0.46,
                      height: screenWidth * 0.46,
                      child: Image.asset(
                        'assets/PurpleSqueezeIcon.png',
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.image_not_supported,
                            color: Colors.purple,
                            size: 124,
                          );
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
}
