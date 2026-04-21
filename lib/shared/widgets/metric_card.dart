import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';

import 'apex_card.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final bool highlight;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    this.sub,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return ApexCard(
      accentLeft: highlight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.monoLabel()),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.metric(
              color: highlight ? AppColors.volt : AppColors.foreground,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub!, style: AppTextStyles.bodySmall()),
          ],
        ],
      ),
    );
  }
}
