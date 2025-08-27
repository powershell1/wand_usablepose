import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandquest/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //TextFields variable
  bool _obscurePassword = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, 
      body: Stack(
        children: [
          // Grey background
          Container(
            width: double.infinity,
            height: double.infinity,
            color: ColorsAsset.grey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 446),

                  // Email field
                  Container(
                    width: 318,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: emailController,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.email_outlined,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20),

                  // Password field
                  Container(
                    width: 318,
                    height: 50,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: "Password",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.black54,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.lock_outline,
                            color: Colors.black87,
                            size: 22,
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black87,
                              size: 22,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 40),
                  Text(
                    'Forgot Password?',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF868686),
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 76,),
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
                          boxShadow: [
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
                      
                      SizedBox(width: 14,),
                  
                      //Next Button
                      Container(
                        width: 166,
                        height: 63,
                        decoration: BoxDecoration(
                          gradient: ColorsAsset.purplebutton,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
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

                  SizedBox(height: 120), // spacing so last item isn’t hidden
                ],
              ),
            ),
          ),

          // Purple Big Circle
          Positioned(
            top: -538,
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
                  const SizedBox(height: 542),
                  Container(
                    width: 102,
                    height: 102,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
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
                        width: 82,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Login',
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
