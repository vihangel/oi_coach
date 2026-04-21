import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/mock_data.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

import '../view_model/rotina_view_model.dart';

class RotinaView extends StatefulWidget {
  const RotinaView({super.key});

  @override
  State<RotinaView> createState() => _RotinaViewState();
}

class _RotinaViewState extends State<RotinaView> {
  late final RotinaViewModel _vm;

  @override
  void initState() {
    super.initState();
    _vm = RotinaViewModel();
    _vm.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _vm.removeListener(_onChanged);
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafePage(
      child: ListView(
        children: [
          PageHeader(
            eyebrow: 'Rotina diária',
            title: '${_vm.day.name} — ${_vm.day.focus}',
            description:
                'Treino, dieta e atividades extras em um só lugar. Complete tudo para fechar o dia.',
          ),

          // Completion indicator
          if (_vm.isDailyRoutineComplete) _buildCompletionBanner(),

          // --- TRAINING SECTION ---
          _buildSectionTitle('TREINO'),
          const SizedBox(height: 12),
          ..._vm.day.exercises.map(_buildExerciseCard),

          const SizedBox(height: 32),

          // --- DIET SECTION ---
          _buildSectionTitle('DIETA'),
          const SizedBox(height: 12),
          ...dietPlan.map(_buildMealCard),
          const SizedBox(height: 16),
          _buildFreeMealsSection(),
          const SizedBox(height: 16),
          _buildCheatSection(),
          const SizedBox(height: 12),
          _buildWeightCard(),

          const SizedBox(height: 32),

          // --- EXTRA ACTIVITIES SECTION ---
          _buildSectionTitle('ATIVIDADES EXTRAS'),
          const SizedBox(height: 12),
          ..._vm.extraActivities.map(_buildActivityCard),
          const SizedBox(height: 12),
          _buildAddActivityButton(),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // --- Completion Banner ---

  Widget _buildCompletionBanner() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.voltDim,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.volt.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.volt, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Rotina do dia completa!',
                style: AppTextStyles.body().copyWith(
                  color: AppColors.volt,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Section Title ---

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.monoLabel(color: AppColors.volt));
  }

  // --- Training Section ---

  Widget _buildExerciseCard(Exercise ex) {
    final confirmed = _vm.isConfirmed(ex.id);
    final sets = _vm.setsFor(ex.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ApexCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(
                  'EX ${ex.order.toString().padLeft(2, '0')}',
                  style: AppTextStyles.monoLabel(),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label: confirmed ? 'Mapeado ✓' : 'Verificar',
                  variant: confirmed ? BadgeVariant.volt : BadgeVariant.warning,
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('SEMANA ANTERIOR', style: AppTextStyles.monoLabel()),
                    const SizedBox(height: 4),
                    Text(
                      _vm.lastWeekSummary(ex.id),
                      style: AppTextStyles.body().copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ex.name.toUpperCase(),
              style: AppTextStyles.display(size: 22),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              'Meta: ${ex.targetSets}×${ex.targetReps} @ ${ex.targetWeight}kg',
              style: AppTextStyles.bodySmall(),
            ),
            const SizedBox(height: 16),

            // Sets
            ...List.generate(sets.length, (i) {
              final s = sets[i];
              final progressed = _vm.isProgressed(ex.id, i);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 60,
                      child: Text(
                        'SÉRIE ${i + 1}',
                        style: AppTextStyles.monoLabel(),
                      ),
                    ),
                    Expanded(
                      child: _NumField(value: s.weight, accent: progressed),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _NumField(value: s.reps.toDouble())),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: progressed ? '↗ +' : '=',
                      variant: progressed
                          ? BadgeVariant.volt
                          : BadgeVariant.muted,
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => _vm.toggleExerciseConfirmed(ex.id),
              child: Row(
                children: [
                  Icon(
                    confirmed ? Icons.check_box : Icons.check_box_outline_blank,
                    size: 18,
                    color: confirmed
                        ? AppColors.volt
                        : AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Exercício corresponde ao da ficha (mapeamento correto)',
                      style: AppTextStyles.bodySmall(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Diet Section ---

  Widget _buildMealCard(DietMeal meal) {
    final checkIn = _vm.checkInFor(meal.id);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ApexCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            meal.time,
                            style: AppTextStyles.monoLabel(
                              color: AppColors.volt,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              '${meal.kcal} KCAL',
                              style: AppTextStyles.monoLabel(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        meal.name.toUpperCase(),
                        style: AppTextStyles.display(size: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(meal.description, style: AppTextStyles.bodySmall()),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: MealStatus.values.map((s) {
                    final active = checkIn.status == s;
                    return Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: _StatusChip(
                        label: _statusLabel(s),
                        active: active,
                        variant: s,
                        onTap: () => _vm.setMealStatus(meal.id, s),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
            if (checkIn.status == MealStatus.ajustou) ...[
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => _vm.setMealNote(meal.id, v),
                decoration: const InputDecoration(
                  hintText: 'Observação (ex: troquei arroz por batata)',
                  hintStyle: TextStyle(
                    color: AppColors.mutedForeground,
                    fontSize: 13,
                  ),
                  isDense: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFreeMealsSection() {
    return ApexCard(
      accentLeft: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'REFEIÇÕES LIVRES DA SEMANA',
                  style: AppTextStyles.monoLabel(color: AppColors.volt),
                ),
              ),
              GestureDetector(
                onTap: _vm.addFreeMeal,
                child: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.volt,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(_vm.freeMeals.length, (i) {
            final meal = _vm.freeMeals[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        TextField(
                          controller: TextEditingController(text: meal.day),
                          onChanged: (v) => _vm.updateFreeMealDay(i, v),
                          style: AppTextStyles.body().copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Dia (ex: Domingo)',
                            hintStyle: AppTextStyles.bodySmall(
                              color: AppColors.mutedForeground,
                            ),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: TextEditingController(
                            text: meal.description,
                          ),
                          onChanged: (v) => _vm.updateFreeMealDesc(i, v),
                          style: AppTextStyles.body(),
                          decoration: InputDecoration(
                            hintText: 'O que comeu?',
                            hintStyle: AppTextStyles.bodySmall(
                              color: AppColors.mutedForeground,
                            ),
                            isDense: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_vm.freeMeals.length > 1) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _vm.removeFreeMeal(i),
                      child: const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Icon(
                          Icons.close,
                          color: AppColors.mutedForeground,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCheatSection() {
    return ApexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.destructive,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'CHUTEI O BALDE',
                  style: AppTextStyles.monoLabel(color: AppColors.destructive),
                ),
              ),
              GestureDetector(
                onTap: _vm.addCheatEntry,
                child: const Icon(
                  Icons.add_circle_outline,
                  color: AppColors.destructive,
                  size: 20,
                ),
              ),
            ],
          ),
          if (_vm.cheatEntries.isEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Nenhum registro — toque + para adicionar',
              style: AppTextStyles.bodySmall(color: AppColors.mutedForeground),
            ),
          ],
          if (_vm.cheatEntries.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...List.generate(_vm.cheatEntries.length, (i) {
              final entry = _vm.cheatEntries[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: entry.description,
                        ),
                        onChanged: (v) => _vm.updateCheatEntry(i, v),
                        style: AppTextStyles.body(),
                        decoration: InputDecoration(
                          hintText: 'O que aconteceu? (ex: comi 2 pizzas)',
                          hintStyle: AppTextStyles.bodySmall(
                            color: AppColors.mutedForeground,
                          ),
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => _vm.removeCheatEntry(i),
                      child: const Icon(
                        Icons.close,
                        color: AppColors.mutedForeground,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightCard() {
    return ApexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PESO ATUAL (JEJUM)', style: AppTextStyles.monoLabel()),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _vm.currentWeight.toString(),
                style: AppTextStyles.metric(size: 36),
              ),
              const SizedBox(width: 8),
              Text(
                'kg',
                style: AppTextStyles.body(color: AppColors.mutedForeground),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.bodySmall(),
              children: [
                TextSpan(text: 'Anterior: ${_vm.previousWeight} kg  '),
                TextSpan(
                  text:
                      '${_vm.weightDelta >= 0 ? '+' : ''}${_vm.weightDelta.toStringAsFixed(1)} kg',
                  style: TextStyle(
                    color: _vm.weightDelta <= 0
                        ? AppColors.volt
                        : AppColors.destructive,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Extra Activities Section ---

  Widget _buildActivityCard(ExtraActivity activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ActivityLogCard(activity: activity),
    );
  }

  Widget _buildAddActivityButton() {
    return GestureDetector(
      onTap: () => _showAddActivitySheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.volt, size: 18),
            const SizedBox(width: 8),
            Text(
              'ADICIONAR ATIVIDADE',
              style: AppTextStyles.monoLabel(color: AppColors.volt),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddActivitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => AddActivitySheet(
        onSave: (activity) {
          _vm.addExtraActivity(activity);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // --- Helpers ---

  String _statusLabel(MealStatus s) => switch (s) {
    MealStatus.seguiu => 'Seguiu',
    MealStatus.ajustou => 'Ajustou',
    MealStatus.nao => 'Não',
  };
}

// --- Private Widgets ---

class _NumField extends StatelessWidget {
  final double value;
  final bool accent;

  const _NumField({required this.value, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: accent
              ? AppColors.volt.withValues(alpha: 0.4)
              : AppColors.border,
        ),
      ),
      child: Text(
        value % 1 == 0 ? value.toInt().toString() : value.toString(),
        style: AppTextStyles.body().copyWith(
          fontWeight: FontWeight.w700,
          color: accent ? AppColors.volt : AppColors.foreground,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final bool active;
  final MealStatus variant;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.active,
    required this.variant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg, fg;
    if (!active) {
      bg = AppColors.background;
      fg = AppColors.mutedForeground;
    } else {
      switch (variant) {
        case MealStatus.seguiu:
          bg = AppColors.volt;
          fg = AppColors.primaryForeground;
        case MealStatus.ajustou:
          bg = AppColors.warning.withValues(alpha: 0.2);
          fg = AppColors.warning;
        case MealStatus.nao:
          bg = AppColors.destructive.withValues(alpha: 0.2);
          fg = AppColors.destructive;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(6),
          border: active ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label.toUpperCase(),
          style: AppTextStyles.monoLabel(color: fg).copyWith(fontSize: 9),
        ),
      ),
    );
  }
}
