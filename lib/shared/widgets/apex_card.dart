import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';

class ApexCard extends StatelessWidget {
  final Widget child;
  final bool accentLeft;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const ApexCard({
    super.key,
    required this.child,
    this.accentLeft = false,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Row(
          children: [
            if (accentLeft) Container(width: 2, color: AppColors.volt),
            Expanded(
              child: Padding(padding: padding, child: child),
            ),
          ],
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }
    return card;
  }
}
