import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.light(
          primary: AppColors.plum,
          onPrimary: AppColors.surface,
          secondary: AppColors.cyan,
          onSecondary: AppColors.surface,
          surface: AppColors.surface,
          onSurface: AppColors.primaryText,
          outline: AppColors.border,
          error: AppColors.incorrect,
        ),
        textTheme: GoogleFonts.interTextTheme().copyWith(
          bodyLarge: TextStyle(color: AppColors.primaryText),
          bodyMedium: TextStyle(color: AppColors.primaryText),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primaryText,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: false,
        ),
        dividerTheme: const DividerThemeData(
          color: AppColors.border,
          thickness: 1,
          space: 1,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.plum,
            foregroundColor: AppColors.surface,
            minimumSize: const Size(double.infinity, 52),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
        ),
      );
}
