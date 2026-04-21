import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/features/dashboard/view_model/dashboard_view_model.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.isLoading) {
      return const SafePage(child: Center(child: CircularProgressIndicator()));
    }

    final today = _viewModel.todayWorkout;

    return SafePage(
      child: ListView(
        children: [
          PageHeader(
            eyebrow: 'Sessão de hoje',
            title: 'Boa noite, atleta.',
            description:
                'Você está na semana 4 do ciclo. Foco em sobrecarga progressiva — sem regressões.',
            action: ApexButton(
              label: 'Iniciar rotina →',
              onPressed: () => context.go('/rotina'),
            ),
          ),
          if (today != null)
            MetricCard(
              label: 'Treino de hoje',
              value: today.focus,
              sub: '${today.exercises.length} exercícios',
              highlight: true,
            )
          else
            const MetricCard(
              label: 'Treino de hoje',
              value: '—',
              sub: 'Nenhum treino planejado para hoje',
              highlight: false,
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Expanded(
                child: MetricCard(
                  label: 'Dieta semanal',
                  value: '—',
                  sub: 'Aderência',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Peso jejum',
                  value: _viewModel.currentWeight != null
                      ? '${_viewModel.currentWeight}kg'
                      : '—',
                  sub: _viewModel.currentWeight != null
                      ? 'Último registro'
                      : 'Sem registro',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          ...[
            _NavItem(
              '/relatorio',
              'Relatório',
              'Gere o resumo semanal pronto para copiar.',
            ),
            _NavItem(
              '/fichas',
              'Fichas',
              'Anexe e gerencie seus planos de treino e dieta.',
            ),
          ].map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ApexCard(
                onTap: () => context.go(item.path),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.toUpperCase(),
                      style: AppTextStyles.monoLabel(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.desc,
                      style: AppTextStyles.body(),
                      softWrap: true,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ABRIR →',
                      style: AppTextStyles.monoLabel(color: AppColors.volt),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem {
  final String path, title, desc;
  const _NavItem(this.path, this.title, this.desc);
}
