import 'package:flutter/material.dart';

/// Apex.OS color palette — dark-only theme
abstract final class AppColors {
  static const background = Color(0xFF1A1A1A);
  static const foreground = Color(0xFFE8E8EC);

  static const surface = Color(0xFF2A2A2A);
  static const surfaceElevated = Color(0xFF363636);

  static const volt = Color(0xFFD4F53C);
  static const voltDim = Color(0x26D4F53C); // 15% opacity

  static const primary = volt;
  static const primaryForeground = Color(0xFF1A1A1A);

  static const muted = Color(0xFF363636);
  static const mutedForeground = Color(0xFF8E8E99);

  static const border = Color(0x14FFFFFF); // 8% white
  static const input = Color(0x1FFFFFFF); // 12% white

  static const destructive = Color(0xFFE05252);
  static const destructiveForeground = Color(0xFFFAFAFA);

  static const warning = Color(0xFFE0A030);
  static const success = volt;
}
