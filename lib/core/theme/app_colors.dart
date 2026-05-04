import 'package:flutter/material.dart';

abstract class AppColors {
  // Dark Theme (Primary - MangaDex default)
  static const background = Color(0xFF1C1C1C);
  static const surface = Color(0xFF2C2C2C);
  static const surfaceAlt = Color(0xFF363636);
  static const primary = Color(0xFFFF6740);
  static const primaryDark = Color(0xFFE85D39);
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA0A0A0);
  static const divider = Color(0xFF3D3D3D);
  static const tagBg = Color(0xFF404040);
  static const statusGreen = Color(0xFF2EA44F);
  static const statusBlue = Color(0xFF3B82F6);
  static const ratingYellow = Color(0xFFFBBF24);
  static const error = Color(0xFFEF4444);

  // Light Theme
  static const bgLight = Color(0xFFF9F9F9);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textLight = Color(0xFF1C1C1C);
  static const textSecondaryLight = Color(0xFF6B7280);
  static const dividerLight = Color(0xFFE5E7EB);
  static const tagBgLight = Color(0xFFF3F4F6);

  // Semantic colors (same for both themes)
  static const success = statusGreen;
  static const info = statusBlue;
  static const warning = Color(0xFFF59E0B);
}
