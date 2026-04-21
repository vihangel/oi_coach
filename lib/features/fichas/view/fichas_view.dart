import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/data/repositories/api_diet_plan_repository.dart';
import 'package:oi_coach/data/repositories/api_workout_plan_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

class FichasView extends StatefulWidget {
  const FichasView({super.key});

  @override
  State<FichasView> createState() => _FichasViewState();
}

class _FichasViewState extends State<FichasView> {
  late final ApiWorkoutPlanRepository _workoutPlanRepo;
  late final ApiDietPlanRepository _dietPlanRepo;

  bool _isLoading = true;
  List<WorkoutDay> _workoutDays = [];
  List<DietMeal> _dietMeals = [];

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient(TokenService());
    _workoutPlanRepo = ApiWorkoutPlanRepository(apiClient);
    _dietPlanRepo = ApiDietPlanRepository(apiClient);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _workoutPlanRepo.getWorkoutPlans(),
        _dietPlanRepo.getDietPlans(),
      ]);
      if (!mounted) return;
      setState(() {
        _workoutDays = _parseWorkoutDays(results[0]);
        _dietMeals = _parseDietMeals(results[1]);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<WorkoutDay> _parseWorkoutDays(List<dynamic> workoutPlans) {
    if (workoutPlans.isEmpty) return [];
    final plan = workoutPlans[0] as Map<String, dynamic>;
    final daysJson = plan['days'] as List<dynamic>? ?? [];
    return daysJson.map((d) {
      final dayMap = d as Map<String, dynamic>;
      final exercisesJson = dayMap['exercises'] as List<dynamic>? ?? [];
      return WorkoutDay(
        id: dayMap['id'] ?? '',
        name: dayMap['name'] ?? '',
        focus: dayMap['focus'] ?? '',
        day: dayMap['day'] ?? '',
        exercises: exercisesJson.map((e) {
          final exMap = e as Map<String, dynamic>;
          return Exercise(
            id: exMap['id'] ?? '',
            order: exMap['order'] ?? 0,
            name: exMap['name'] ?? '',
            targetSets: exMap['targetSets'] ?? 0,
            targetReps: (exMap['targetReps'] ?? '0').toString(),
            targetWeight: (exMap['targetWeight'] ?? 0).toDouble(),
          );
        }).toList(),
      );
    }).toList();
  }

  List<DietMeal> _parseDietMeals(List<dynamic> dietPlans) {
    if (dietPlans.isEmpty) return [];
    final plan = dietPlans[0] as Map<String, dynamic>;
    final mealsJson = plan['meals'] as List<dynamic>? ?? [];
    return mealsJson.map((m) {
      final mealMap = m as Map<String, dynamic>;
      return DietMeal(
        id: mealMap['id'] ?? '',
        name: mealMap['name'] ?? '',
        time: mealMap['time'] ?? '',
        description: mealMap['description'] ?? '',
        kcal: mealMap['kcal'] ?? 0,
      );
    }).toList();
  }

  bool get _isEmpty => _workoutDays.isEmpty && _dietMeals.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SafePage(child: Center(child: CircularProgressIndicator()));
    }

    return SafePage(
      child: ListView(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
              onPressed: () => context.go('/'),
              tooltip: 'Voltar ao dashboard',
            ),
          ),
          PageHeader(
            eyebrow: 'Repositório',
            title: 'Fichas anexadas',
            description:
                'Plano atual de treino e alimentação. Anexe novas fichas a qualquer momento.',
            action: ApexButton(label: '+ Anexar nova ficha'),
          ),

          if (_isEmpty)
            _buildEmptyState()
          else ...[
            // Workout section header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('FICHA DE TREINO', style: AppTextStyles.display(size: 20)),
                Text('CICLO 04 // 4 SEMANAS', style: AppTextStyles.monoLabel()),
              ],
            ),
            const SizedBox(height: 16),

            // Workout cards
            ..._workoutDays.map(
              (day) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ApexCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 3, color: AppColors.volt),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              day.day.toUpperCase(),
                              style: AppTextStyles.monoLabel(),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              day.name.toUpperCase(),
                              style: AppTextStyles.display(size: 22),
                            ),
                            Text(day.focus, style: AppTextStyles.bodySmall()),
                            const SizedBox(height: 16),
                            ...day.exercises.map(
                              (ex) => Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.background.withValues(
                                    alpha: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      ex.order.toString().padLeft(2, '0'),
                                      style: AppTextStyles.monoLabel(),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        ex.name,
                                        style: AppTextStyles.body(),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '${ex.targetSets}×${ex.targetReps}',
                                      style: AppTextStyles.bodySmall(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Diet section header
            if (_dietMeals.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'FICHA DE ALIMENTAÇÃO',
                    style: AppTextStyles.display(size: 20),
                  ),
                  Text(
                    '${_dietMeals.fold<int>(0, (s, m) => s + m.kcal)} KCAL TOTAIS',
                    style: AppTextStyles.monoLabel(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Diet card
              ApexCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: _dietMeals.asMap().entries.map((entry) {
                    final i = entry.key;
                    final meal = entry.value;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: i > 0
                            ? const Border(
                                top: BorderSide(color: AppColors.border),
                              )
                            : null,
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 72,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  meal.time,
                                  style: AppTextStyles.monoLabel(
                                    color: AppColors.volt,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  meal.name,
                                  style: AppTextStyles.bodySmall(),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              meal.description,
                              style: AppTextStyles.body(),
                              softWrap: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${meal.kcal}',
                                style: AppTextStyles.body().copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text('KCAL', style: AppTextStyles.monoLabel()),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            Text(
              'Nenhuma ficha anexada',
              style: AppTextStyles.body(color: AppColors.mutedForeground),
            ),
            const SizedBox(height: 16),
            ApexButton(label: '+ Anexar ficha'),
          ],
        ),
      ),
    );
  }
}
