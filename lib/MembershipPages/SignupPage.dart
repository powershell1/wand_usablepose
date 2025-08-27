import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wandquest/colors.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // controllers / state
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  final ageController = TextEditingController();
  String? gender; // 'Male' or 'Female'
  bool _obscurePassword = true;

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    weightController.dispose();
    heightController.dispose();
    ageController.dispose();
    super.dispose();
  }

  // common decoration (no prefix icon version)
  InputDecoration _decoration(String hint, {Widget? suffix, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        color: Colors.black54,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      prefixIcon: prefix,
      suffixIcon: suffix,
    );
  }

  BoxDecoration get _fieldShadow => BoxDecoration(
    boxShadow: const [
      BoxShadow(color: Colors.black12, offset: Offset(0, 4), blurRadius: 8),
    ],
  );

  TextStyle get _textStyle => GoogleFonts.poppins(
    color: Colors.black,
    fontWeight: FontWeight.w600,
    fontSize: 16,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // grey background + form
          Container(
            width: double.infinity,
            height: double.infinity,
            color: ColorsAsset.grey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 318),

                  // Full name
                  Container(
                    width: 318,
                    height: 50,
                    decoration: _fieldShadow,
                    child: TextField(
                      controller: fullNameController,
                      style: _textStyle,
                      decoration: _decoration("Full name"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  Container(
                    width: 318,
                    height: 50,
                    decoration: _fieldShadow,
                    child: TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: _textStyle,
                      decoration: _decoration("Email"),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Password (show/hide)
                  Container(
                    width: 318,
                    height: 50,
                    decoration: _fieldShadow,
                    child: TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: _textStyle,
                      decoration: _decoration(
                        "Password",
                        suffix: IconButton(
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
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Weight (kg)
                  Container(
                    width: 318,
                    height: 50,
                    decoration: _fieldShadow,
                    child: TextField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      style: _textStyle,
                      decoration: _decoration(
                        "Weight",
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 14,top: 12),
                          child: Text(
                            "kg",
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Height (m)
                  Container(
                    width: 318,
                    height: 50,
                    decoration: _fieldShadow,
                    child: TextField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      style: _textStyle,
                      decoration: _decoration(
                        "Height",
                        suffix: Padding(
                          padding: const EdgeInsets.only(right: 14, top: 12),
                          child: Text(
                            "m",
                            style: GoogleFonts.poppins(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gender + Age row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Gender dropdown
                      Container(
                        width: 152,
                        height: 50,
                        decoration: _fieldShadow,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: gender,
                                hint: Text(
                                  "Gender",
                                  style: GoogleFonts.poppins(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                style: _textStyle,
                                items: const [
                                  DropdownMenuItem(
                                    value: "Male",
                                    child: Text("Male"),
                                  ),
                                  DropdownMenuItem(
                                    value: "Female",
                                    child: Text("Female"),
                                  ),
                                ],
                                onChanged: (v) => setState(() => gender = v),
                                icon: const Icon(Icons.keyboard_arrow_down),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Age
                      Container(
                        width: 152,
                        height: 50,
                        decoration: _fieldShadow,
                        child: TextField(
                          controller: ageController,
                          keyboardType: TextInputType.number,
                          style: _textStyle,
                          decoration: _decoration("Age"),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 46),

                  // Back / Next
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 166,
                        height: 63,
                        decoration: BoxDecoration(
                          color: Colors.white,
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
          ),

          // purple big circle (moved further up)
          Positioned(
            top: -614, // higher = less of the circle is visible
            left: -200,
            right: -200,
            child: Container(
              height: 880,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(900),
                gradient: ColorsAsset.primary,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 666), // adjust header placement
                  Container(
                    width: 102,
                    height: 102,
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
                      child: Image.asset('assets/WandQuestLogo.png', width: 82),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Sign up',
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
