import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/data/mock_data.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

class FichasView extends StatelessWidget {
  const FichasView({super.key});

  @override
  Widget build(BuildContext context) {
    final totalKcal = dietPlan.fold<int>(0, (s, m) => s + m.kcal);

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
          ...workoutPlan.map(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'FICHA DE ALIMENTAÇÃO',
                style: AppTextStyles.display(size: 20),
              ),
              Text('$totalKcal KCAL TOTAIS', style: AppTextStyles.monoLabel()),
            ],
          ),
          const SizedBox(height: 16),

          // Diet card
          ApexCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: dietPlan.asMap().entries.map((entry) {
                final i = entry.key;
                final meal = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    border: i > 0
                        ? const Border(top: BorderSide(color: AppColors.border))
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
                            Text(meal.name, style: AppTextStyles.bodySmall()),
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
      ),
    );
  }
}
