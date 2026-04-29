import 'package:flutter/material.dart';

abstract final class AppColors {
  // Backgrounds
  static const background = Color(0xFFFAF8FC);  // warm lavender-white
  static const backgroundSubtle = Color(0xFFF5F1F7);
  static const surface = Color(0xFFFFFFFF);
  static const muted = Color(0xFFE8E8F0);

  // Brand
  static const plum = Color(0xFF8B5A7C);         // primary CTA, brand
  static const plumLight = Color(0xFFF3EAF0);
  static const cyan = Color(0xFF5AB4B4);          // progress, success
  static const cyanLight = Color(0xFFE4F4F4);
  static const gold = Color(0xFFD4A45A);          // highlights, badges
  static const goldLight = Color(0xFFF7EDD8);

  // Text hierarchy
  static const primaryText = Color(0xFF2D2433);
  static const secondaryText = Color(0xFF6C4D63);
  static const mutedText = Color(0xFF8A7A91);
  static const disabledText = Color(0xFFB9B3C2);

  // Semantic states
  static const correct = Color(0xFF4A9E9E);       // deep cyan
  static const correctLight = Color(0xFFE0F4F4);
  static const incorrect = Color(0xFFB34A5A);     // deep rose
  static const incorrectLight = Color(0xFFF7E0E4);
  static const warning = Color(0xFFC4923A);
  static const warningLight = Color(0xFFF7EDD8);

  // Border
  static const border = Color(0xFFE8E8F0);
  static const borderStrong = Color(0xFFD4C8DC);

  // Gradient stop colours (hero card)
  static const gradientStart = Color(0xFF6B3F5E);
  static const gradientEnd = Color(0xFF3D8E8E);
}
