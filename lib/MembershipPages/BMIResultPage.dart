import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandquest/colors.dart';

class BMIResultPage extends StatefulWidget {
  const BMIResultPage({super.key});

  @override
  State<BMIResultPage> createState() => _BMIResultPageState();
}

class _BMIResultPageState extends State<BMIResultPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Set the background color here for a cleaner layout
      backgroundColor: ColorsAsset.grey,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // This SingleChildScrollView now sits on the Scaffold's background
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 744),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Back button
                    Container(
                      width: 166,
                      height: 63,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow:  [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Back',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    //Next Button
                    Container(
                      width: 166,
                      height: 63,
                      decoration: BoxDecoration(
                        gradient: ColorsAsset.purplebutton,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            offset: Offset(0, 8),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'Next',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),

          // Purple Big Circle (Drawn before the white container)
          Positioned(
            top: -464,
            left: -200,
            right: -200,
            child: Container(
              height: 880,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(900),
                gradient: ColorsAsset.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 486),
                  Container(
                    width: 174,
                    height: 174,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(31, 178, 172, 172),
                          offset: Offset(0, 8),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/WandQuestLogo.png',
                        width: 140,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Wand Quest',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- FIXES APPLIED HERE ---
          // White information container (NOW THE LAST CHILD, SO IT'S ON TOP)
          Positioned(
            top: 374, // MOVED DOWN by increasing the top value
            left: 0,  // Added to help with centering
            right: 0, // Added to help with centering
            child: Center( // Center widget correctly used to center the container
              child: Container(
                width: 315,
                height: 240, // INCREASED HEIGHT to fix overflow
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(31, 178, 172, 172),
                      offset: Offset(0, 4),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // Changed for better spacing
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Your BMI is:',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF404040),
                          fontWeight: FontWeight.w600,
                          fontSize: 22),
                    ),
                    Text(
                      '20',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF404040),
                          fontWeight: FontWeight.w800,
                          fontSize: 96,
                          height: 1.22
                          ),
                    ),
                    Text(
                      'Normal',
                      style: GoogleFonts.poppins(
                          color: const Color(0xFF00FF2F),
                          fontWeight: FontWeight.w800,
                          fontSize: 30),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}