import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';

enum ApexButtonVariant { primary, outline }

class ApexButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ApexButtonVariant variant;

  const ApexButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ApexButtonVariant.primary,
  });

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == ApexButtonVariant.primary;
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.volt : AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: isPrimary ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.button().copyWith(
            color: isPrimary
                ? AppColors.primaryForeground
                : AppColors.foreground,
          ),
        ),
      ),
    );
  }
}
