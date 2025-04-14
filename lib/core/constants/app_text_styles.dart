import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_fonts.dart';

class AppTextStyle {
  static const TextStyle headline = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: AppFonts.poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );
  static const TextStyle reciplyLogo = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    fontFamily: 'DancingScript',
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );
  static const TextStyle stylish = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    fontFamily: 'DancingScript',
  );
}
