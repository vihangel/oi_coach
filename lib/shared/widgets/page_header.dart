import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';

class PageHeader extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? description;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.eyebrow,
    required this.title,
    this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.volt,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                eyebrow.toUpperCase(),
                style: AppTextStyles.monoLabel(color: AppColors.volt),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  title.toUpperCase(),
                  style: AppTextStyles.display(size: 28),
                ),
              ),
              ?action,
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: AppTextStyles.body(color: AppColors.mutedForeground),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
        ],
      ),
    );
  }
}
