import 'package:flutter/material.dart';

class AppColors {

  static const Color black = Color(0xFF0B0B0B);
  static const Color white = Color(0xFFFFFFFF);
  static const Color purple = Color(0xFF8000AA); 
  static const LinearGradient brandGradient = LinearGradient(
    colors: [
      Color(0xFFAE0EFF),
      Color(0xFFFC1D22),
      Color(0xFFFFA523),
    ],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );


  static const Color success = Color(0xFF13E800);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF3333);


  static const Color grey900 = Color(0xFF0C0C0C);
  static const Color grey600 = Color(0xFF484848);
  static const Color grey400 = Color(0xFF8D8D8D);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color description = Color(0xFF767676);
  static const Color stroke = Color(0xFFB0B0B0);


  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
}
