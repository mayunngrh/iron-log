import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  static TextStyle get brandName => GoogleFonts.oswald(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontStyle: FontStyle.italic,
        letterSpacing: 3.0,
      );

  static TextStyle get tagline => GoogleFonts.oswald(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 3.5,
      );

  static TextStyle get screenTitle => GoogleFonts.oswald(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        fontStyle: FontStyle.italic,
        letterSpacing: 2.5,
      );

  static TextStyle get sectionTitle => GoogleFonts.oswald(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get heroHeading => GoogleFonts.oswald(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );

  static TextStyle get heroSubtitle => GoogleFonts.oswald(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        letterSpacing: 3.0,
      );

  static TextStyle get label => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 1.8,
      );

  static TextStyle get forgotText => const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 1.5,
      );

  static TextStyle get buttonText => GoogleFonts.oswald(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 2.5,
      );

  static TextStyle get body => const TextStyle(
        fontSize: 13,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyBold => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get footerLink => const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 1.2,
      );

  static TextStyle get googleButtonLabel => const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.5,
      );
}
