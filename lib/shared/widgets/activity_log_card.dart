import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/models.dart';

/// Card for displaying a logged extra activity.
/// Full implementation in Task 6.3.
class ActivityLogCard extends StatelessWidget {
  final ExtraActivity activity;

  const ActivityLogCard({super.key, required this.activity});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _activityLabel(activity.type).toUpperCase(),
                  style: AppTextStyles.display(size: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.durationMinutes} min',
                  style: AppTextStyles.bodySmall(),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: activity.source == ActivitySource.garmin
                  ? AppColors.voltDim
                  : AppColors.muted,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              activity.source == ActivitySource.garmin ? 'GARMIN' : 'MANUAL',
              style: AppTextStyles.monoLabel(
                color: activity.source == ActivitySource.garmin
                    ? AppColors.volt
                    : AppColors.mutedForeground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _activityLabel(ActivityType type) => switch (type) {
    ActivityType.yoga => 'Yoga',
    ActivityType.corrida => 'Corrida',
    ActivityType.crossfit => 'Crossfit',
    ActivityType.natacao => 'Natação',
    ActivityType.tenisDeMesa => 'Tênis de Mesa',
  };
}
