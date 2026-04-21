import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

/// Builds mock ExerciseProgressEntry list from existing mock data.
/// Simulates current week = previous + small delta for demonstration.
List<ExerciseProgressEntry> _buildMockProgressEntries() {
  final allExercises = workoutPlan.expand((d) => d.exercises).toList();
  final entries = <ExerciseProgressEntry>[];

  for (final ex in allExercises) {
    if (!lastWeekResults.containsKey(ex.id)) continue;

    final sets = lastWeekResults[ex.id]!;
    final previousWeight = sets
        .map((s) => s.weight)
        .reduce((a, b) => a > b ? a : b);
    final previousReps = sets
        .map((s) => s.reps)
        .reduce((a, b) => a > b ? a : b);

    // Simulate current week with varied deltas
    final double weightDelta;
    final int repsDelta;
    switch (ex.id) {
      case 'a1':
        weightDelta = 2.5;
        repsDelta = 1;
      case 'a2':
        weightDelta = 2.0;
        repsDelta = 0;
      case 'a3':
        weightDelta = 0;
        repsDelta = 2;
      case 'a4':
        weightDelta = 0;
        repsDelta = 1;
      case 'b1':
        weightDelta = 5.0;
        repsDelta = 0;
      case 'b2':
        weightDelta = -2.5;
        repsDelta = -1;
      case 'b3':
        weightDelta = 0;
        repsDelta = 1;
      case 'c1':
        weightDelta = 5.0;
        repsDelta = 1;
      case 'c2':
        weightDelta = 10.0;
        repsDelta = 0;
      case 'c3':
        weightDelta = -5.0;
        repsDelta = -2;
      case 'c4':
        weightDelta = 5.0;
        repsDelta = 0;
      default:
        weightDelta = 2.5;
        repsDelta = 0;
    }

    entries.add(
      ExerciseProgressEntry(
        exerciseId: ex.id,
        exerciseName: ex.name,
        previousWeight: previousWeight,
        previousReps: previousReps,
        currentWeight: previousWeight + weightDelta,
        currentReps: previousReps + repsDelta,
      ),
    );
  }

  return entries;
}

class ProgressoView extends StatelessWidget {
  const ProgressoView({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = _buildMockProgressEntries();
    final weightProgressionCount = entries
        .where((e) => e.weightDelta > 0)
        .length;
    final repsProgressionCount = entries.where((e) => e.repsDelta > 0).length;

    return SafePage(
      child: ListView(
        children: [
          PageHeader(
            eyebrow: 'Comparativo semanal',
            title: 'Progresso de carga + reps',
            description:
                'Cada exercício é comparado com a semana anterior. Verde = progressão (carga OU reps). Vermelho = regressão (ambos).',
            action: ApexButton(
              label: '↻ Atualizar',
              variant: ApexButtonVariant.outline,
            ),
          ),

          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Carga ↑',
                  value: '$weightProgressionCount / ${entries.length}',
                  delta: '$weightProgressionCount exercícios',
                  positive: weightProgressionCount > 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Reps ↑',
                  value: '$repsProgressionCount / ${entries.length}',
                  delta: '$repsProgressionCount exercícios',
                  positive: repsProgressionCount > 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatCard(label: 'Aderência', value: '100%', delta: '3 de 3 dias'),
          const SizedBox(height: 24),

          // Table
          ApexCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          'EXERCÍCIO',
                          style: AppTextStyles.monoLabel(),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'CARGA',
                          style: AppTextStyles.monoLabel(),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          'REPS',
                          style: AppTextStyles.monoLabel(),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                ...entries.map((entry) => _ProgressRow(entry: entry)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final ExerciseProgressEntry entry;

  const _ProgressRow({required this.entry});

  Color _deltaColor(num delta) => delta > 0
      ? AppColors.volt
      : delta < 0
      ? AppColors.destructive
      : AppColors.mutedForeground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Exercise name
          Expanded(
            flex: 3,
            child: Text(
              entry.exerciseName,
              style: AppTextStyles.body(),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Carga: current bold + previous muted below
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.currentWeight % 1 == 0 ? entry.currentWeight.toInt() : entry.currentWeight}kg',
                      style: AppTextStyles.body().copyWith(
                        fontWeight: FontWeight.w700,
                        color: _deltaColor(entry.weightDelta),
                      ),
                    ),
                    if (entry.weightDelta != 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        entry.weightDelta > 0 ? '↑' : '↓',
                        style: TextStyle(
                          fontSize: 10,
                          color: _deltaColor(entry.weightDelta),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.previousWeight % 1 == 0 ? entry.previousWeight.toInt() : entry.previousWeight}kg',
                  style: AppTextStyles.monoLabel(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
          // Reps: current bold + previous muted below
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.currentReps}',
                      style: AppTextStyles.body().copyWith(
                        fontWeight: FontWeight.w700,
                        color: _deltaColor(entry.repsDelta),
                      ),
                    ),
                    if (entry.repsDelta != 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        entry.repsDelta > 0 ? '↑' : '↓',
                        style: TextStyle(
                          fontSize: 10,
                          color: _deltaColor(entry.repsDelta),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.previousReps}',
                  style: AppTextStyles.monoLabel(
                    color: AppColors.mutedForeground,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label, value, delta;
  final bool positive;

  const _StatCard({
    required this.label,
    required this.value,
    required this.delta,
    this.positive = false,
  });

  @override
  Widget build(BuildContext context) {
    return ApexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTextStyles.monoLabel()),
          const SizedBox(height: 8),
          Text(value, style: AppTextStyles.metric(size: 28)),
          const SizedBox(height: 8),
          StatusBadge(
            label: delta,
            variant: positive ? BadgeVariant.volt : BadgeVariant.muted,
          ),
        ],
      ),
    );
  }
}
