import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';

enum BadgeVariant { volt, warning, destructive, muted }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.muted,
  });

  Color get _bg => switch (variant) {
    BadgeVariant.volt => AppColors.voltDim,
    BadgeVariant.warning => AppColors.warning.withValues(alpha: 0.15),
    BadgeVariant.destructive => AppColors.destructive.withValues(alpha: 0.15),
    BadgeVariant.muted => AppColors.muted,
  };

  Color get _fg => switch (variant) {
    BadgeVariant.volt => AppColors.volt,
    BadgeVariant.warning => AppColors.warning,
    BadgeVariant.destructive => AppColors.destructive,
    BadgeVariant.muted => AppColors.mutedForeground,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.monoLabel(color: _fg),
      ),
    );
  }
}
