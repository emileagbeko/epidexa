import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyles {
  // Inter — UI labels, headings, options
  static TextStyle get heading => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
        height: 1.3,
      );

  static TextStyle get subheading => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
        height: 1.4,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
        height: 1.6,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.mutedText,
        letterSpacing: 0.6,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.mutedText,
        height: 1.5,
      );

  static TextStyle get optionText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
        height: 1.4,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.surface,
        letterSpacing: 0.2,
      );

  static TextStyle get buttonTextSecondary => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryText,
        letterSpacing: 0.2,
      );

  // Source Serif 4 — clinical note / patient presentation text
  static TextStyle get clinicalNote => GoogleFonts.sourceSerif4(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.primaryText,
        height: 1.7,
      );

  static TextStyle get clinicalNoteLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.mutedText,
        letterSpacing: 1.0,
      );

  static TextStyle get cueChip => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.gold,
      );

  static TextStyle get heroTitle => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.surface,
        height: 1.2,
      );

  static TextStyle get heroBody => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Color(0xCCFFFFFF),
        height: 1.5,
      );

  static TextStyle get heroMeta => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: const Color(0xAAFFFFFF),
      );
  
  static TextStyle get logo => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.plum,
        letterSpacing: -0.5,
      );
}
