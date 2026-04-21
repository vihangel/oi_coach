import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get _base => GoogleFonts.spaceGrotesk();

  /// Large display headings — uppercase, tight tracking
  static TextStyle display({double size = 32, Color? color}) => _base.copyWith(
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.04 * size,
    height: 0.95,
    color: color ?? AppColors.foreground,
  );

  /// Small mono-style labels — uppercase, wide tracking
  static TextStyle monoLabel({Color? color}) => _base.copyWith(
    fontSize: 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.0,
    color: color ?? AppColors.mutedForeground,
  );

  static TextStyle body({Color? color}) => _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.foreground,
  );

  static TextStyle bodySmall({Color? color}) => _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: color ?? AppColors.mutedForeground,
  );

  static TextStyle button() => _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 2.4,
    color: AppColors.primaryForeground,
  );

  static TextStyle metric({double size = 30, Color? color}) => _base.copyWith(
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
    color: color ?? AppColors.foreground,
    fontFeatures: const [FontFeature.tabularFigures()],
  );
}
