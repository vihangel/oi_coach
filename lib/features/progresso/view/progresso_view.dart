import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/repositories/api_progress_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

class ProgressoView extends StatefulWidget {
  const ProgressoView({super.key});

  @override
  State<ProgressoView> createState() => _ProgressoViewState();
}

class _ProgressoViewState extends State<ProgressoView> {
  late final ApiProgressRepository _repo;
  List<ExerciseProgressEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repo = ApiProgressRepository(ApiClient(TokenService()));
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final apiEntries = await _repo.getProgress();
      setState(() {
        _entries = apiEntries;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _entries = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafePage(child: Center(child: CircularProgressIndicator()));
    }

    final entries = _entries;

    if (entries.isEmpty) {
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
                onPressed: _load,
              ),
            ),
            const SizedBox(height: 24),
            ApexCard(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(
                    'Nenhum dado de progresso disponível',
                    style: AppTextStyles.body(color: AppColors.mutedForeground),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

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
              onPressed: _load,
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
