import "package:flutter/material.dart";

class ColorsAsset {
  static const grey = Color(0xFFF4F4F4);
  static const darkGrey = Color(0xFFA3A3A3);
  static const red = Color(0xFFFF7A7A);
  static const primary = LinearGradient(
    begin: Alignment.topLeft, // Light color starts here
    end: Alignment.bottomRight, // Dark color ends here
    colors: [
      Color(0xFFBA4AF4), // Light violet
      Color(0xFF6F338C), // Dark purple
    ],
    stops: [-0.1, 0.9], // 0% to 100%
  );
  static const purplebutton = LinearGradient(
    begin: Alignment.topLeft, // Light color starts here
    end: Alignment.bottomRight, // Dark color ends here
    colors: [
      Color(0xFF911CD9), // Light violet
      Color(0xFF4D0F73), // Dark purple
    ],
    stops: [0.1, 0.9], // 0% to 100%
  );
}
