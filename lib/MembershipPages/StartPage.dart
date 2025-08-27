import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandquest/colors.dart';

class StartPage extends StatelessWidget {
  StartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //Background Part
          Container(
            width: double.infinity,
            height: double.infinity,
            color: ColorsAsset.grey,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.only(top: 492, bottom: 44),
                  child: Container(
                    width: 234,
                    height: 72,
                    child: Center(
                      child: Text(
                        'Log in',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      gradient: ColorsAsset.purplebutton,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 8),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 234,
                  height: 72,
                  child: Center(
                    child: Text(
                      'Register',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0, 8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                Spacer(),
                Text(
                  'Need help?',
                  style: GoogleFonts.poppins(
                    color: Color(0xFF868686),
                    fontWeight: FontWeight.w400,
                    fontSize: 20
                  ),
                ),
                SizedBox(height: 46,)
              ],
            ),
          ),

          //Purple Big Circle
          Positioned(
            top: -468,
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 452),
                  Container(
                    width: 156,
                    height: 156,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 8),
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/WandQuestLogo.png',
                        width: 124,
                      ),
                    ),
                  ),
                  SizedBox(height: 26),
                  Text(
                    'WAND QUEST',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
