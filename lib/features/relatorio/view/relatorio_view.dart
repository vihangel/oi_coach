import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/extra_activity.dart';
import 'package:oi_coach/data/mock_data.dart';
import 'package:oi_coach/data/repositories/activity_repository.dart';
import 'package:oi_coach/data/repositories/weight_repository.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

class RelatorioView extends StatefulWidget {
  const RelatorioView({super.key});

  @override
  State<RelatorioView> createState() => _RelatorioViewState();
}

class _RelatorioViewState extends State<RelatorioView> {
  bool _copied = false;
  final _weightController = TextEditingController();
  final _weightFormKey = GlobalKey<FormState>();
  final _weightRepo = WeightRepository();
  final _activityRepo = ActivityRepository();

  double? _currentWeight;
  double? _previousWeight;
  String? _weightError;
  List<ExtraActivity> _extraActivities = [];

  @override
  void initState() {
    super.initState();
    _loadWeight();
    _loadActivities();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadWeight() async {
    final current = await _weightRepo.loadWeight();
    final previous = await _weightRepo.loadPreviousWeight();
    setState(() {
      _currentWeight = current;
      _previousWeight = previous;
      if (current != null) {
        _weightController.text = current.toStringAsFixed(1);
      }
    });
  }

  Future<void> _loadActivities() async {
    final activities = await _activityRepo.getActivitiesForDay(DateTime.now());
    setState(() {
      _extraActivities = activities;
    });
  }

  Future<void> _submitWeight() async {
    final text = _weightController.text.trim();
    final value = double.tryParse(text);
    final error = WeightValidator.validate(value);

    if (error != null) {
      setState(() => _weightError = error);
      return;
    }

    setState(() => _weightError = null);
    await _weightRepo.saveWeight(value!);
    final previous = await _weightRepo.loadPreviousWeight();
    setState(() {
      _previousWeight = previous;
      _currentWeight = value;
    });
  }

  double? get _weightDelta {
    if (_currentWeight != null && _previousWeight != null) {
      return _currentWeight! - _previousWeight!;
    }
    return null;
  }

  String get _activitiesText {
    if (_extraActivities.isEmpty) return '';
    final lines = _extraActivities
        .map(
          (a) =>
              '  • ${a.type.name}: ${a.durationMinutes} min (${a.source.name})',
        )
        .join('\n');
    return '\n\n🏃 Atividades extras:\n$lines';
  }

  String get _report {
    final displayWeight = _currentWeight ?? weeklySummary.weightFasted;
    final progressLines = weeklySummary.progress
        .map((p) => '  • ${p.exercise}: ${p.from} → ${p.to}')
        .join('\n');
    return '''📊 RELATÓRIO SEMANAL — Semana 4

⚖️  Peso em jejum: $displayWeight kg
🍽️  Dieta: ${weeklySummary.dietAdherence}% seguida
🍕 Refeição livre: ${weeklySummary.freeMeal.day} (${weeklySummary.freeMeal.description})
🏋️  Treinos realizados: ${weeklySummary.trainingsDone} de ${weeklySummary.trainingsPlanned} dias

📈 Progresso de carga:
$progressLines$_activitiesText

Próxima meta: manter sobrecarga progressiva e fechar 4/4 treinos.''';
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _report));
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
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
            eyebrow: 'Resumo semanal',
            title: 'Relatório gerado',
            description:
                'Texto pronto para copiar e enviar. Atualizado automaticamente com base nos seus registros.',
            action: ApexButton(
              label: _copied ? '✓ Copiado' : 'Copiar relatório',
              onPressed: _copy,
            ),
          ),

          // Weight input card
          _buildWeightInputCard(),

          const SizedBox(height: 16),

          // Report card
          ApexCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 3, color: AppColors.volt),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    _report,
                    style: AppTextStyles.body().copyWith(height: 1.6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Metrics
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Peso jejum',
                  value: '${_currentWeight ?? weeklySummary.weightFasted} kg',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Aderência dieta',
                  value: '${weeklySummary.dietAdherence}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Treinos',
                  value:
                      '${weeklySummary.trainingsDone}/${weeklySummary.trainingsPlanned}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Exercícios PR',
                  value: '${weeklySummary.progress.length}',
                  highlight: true,
                ),
              ),
            ],
          ),

          // Extra activities section
          if (_extraActivities.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text('ATIVIDADES EXTRAS', style: AppTextStyles.monoLabel()),
            const SizedBox(height: 12),
            ..._extraActivities.map(
              (activity) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ActivityLogCard(activity: activity),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeightInputCard() {
    return ApexCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PESO EM JEJUM', style: AppTextStyles.monoLabel()),
          const SizedBox(height: 12),
          Form(
            key: _weightFormKey,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: AppTextStyles.body(),
                    decoration: InputDecoration(
                      hintText: 'Ex: 58.5',
                      hintStyle: AppTextStyles.body(
                        color: AppColors.mutedForeground,
                      ),
                      suffixText: 'kg',
                      suffixStyle: AppTextStyles.body(
                        color: AppColors.mutedForeground,
                      ),
                      errorText: _weightError,
                      errorStyle: AppTextStyles.bodySmall(
                        color: AppColors.destructive,
                      ),
                      filled: true,
                      fillColor: AppColors.input,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    onFieldSubmitted: (_) => _submitWeight(),
                  ),
                ),
                const SizedBox(width: 12),
                ApexButton(label: 'Salvar', onPressed: _submitWeight),
              ],
            ),
          ),
          if (_weightDelta != null) ...[
            const SizedBox(height: 8),
            Text(
              'Delta: ${_weightDelta! >= 0 ? '+' : ''}${_weightDelta!.toStringAsFixed(1)} kg',
              style: AppTextStyles.bodySmall(
                color: _weightDelta! >= 0
                    ? AppColors.volt
                    : AppColors.destructive,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
