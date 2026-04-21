import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/extra_activity.dart';
import 'package:oi_coach/data/repositories/api_activity_repository.dart';
import 'package:oi_coach/data/repositories/api_weight_repository.dart';
import 'package:oi_coach/data/repositories/weight_repository.dart';
import 'package:oi_coach/data/services/api_client.dart';
import 'package:oi_coach/data/services/token_service.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

class RelatorioView extends StatefulWidget {
  const RelatorioView({super.key});

  @override
  State<RelatorioView> createState() => _RelatorioViewState();
}

class _RelatorioViewState extends State<RelatorioView> {
  bool _copied = false;
  bool _isLoading = true;
  final _weightController = TextEditingController();
  final _weightFormKey = GlobalKey<FormState>();
  final _localWeightRepo = WeightRepository();
  late final ApiWeightRepository _apiWeightRepo;
  late final ApiActivityRepository _apiActivityRepo;

  double? _currentWeight;
  double? _previousWeight;
  String? _weightError;
  List<ExtraActivity> _extraActivities = [];

  @override
  void initState() {
    super.initState();
    final client = ApiClient(TokenService());
    _apiWeightRepo = ApiWeightRepository(client);
    _apiActivityRepo = ApiActivityRepository(client);
    _loadData();
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadWeight(), _loadActivities()]);
    setState(() => _isLoading = false);
  }

  Future<void> _loadWeight() async {
    try {
      // Try API first
      final apiData = await _apiWeightRepo.getLatest();
      setState(() {
        _currentWeight = apiData.current;
        _previousWeight = apiData.previous;
        if (apiData.current != null) {
          _weightController.text = apiData.current!.toStringAsFixed(1);
        }
      });
    } catch (_) {
      // Fallback to local
      final current = await _localWeightRepo.loadWeight();
      final previous = await _localWeightRepo.loadPreviousWeight();
      setState(() {
        _currentWeight = current;
        _previousWeight = previous;
        if (current != null) {
          _weightController.text = current.toStringAsFixed(1);
        }
      });
    }
  }

  Future<void> _loadActivities() async {
    try {
      final data = await _apiActivityRepo.getActivitiesForDay(DateTime.now());
      setState(() {
        _extraActivities = data
            .map(
              (item) => ExtraActivity(
                id: item['_id'] ?? item['id'] ?? '',
                type: ActivityType.values.byName(item['type']),
                durationMinutes: item['durationMinutes'],
                source: ActivitySource.values.byName(
                  item['source'] ?? 'manual',
                ),
                date: DateTime.parse(item['date']),
              ),
            )
            .toList();
      });
    } catch (_) {
      setState(() => _extraActivities = []);
    }
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
    // Save to both local and API
    await _localWeightRepo.saveWeight(value!);
    _apiWeightRepo.saveWeight(value);
    final previous = await _localWeightRepo.loadPreviousWeight();
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

  /// Whether we have enough data to generate a meaningful report.
  bool get _hasReportData => _currentWeight != null;

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
    final weightStr = _currentWeight != null
        ? '${_currentWeight!.toStringAsFixed(1)} kg'
        : '—';
    return '''📊 RELATÓRIO SEMANAL

⚖️  Peso em jejum: $weightStr
🍽️  Dieta: —
🍕 Refeição livre: —
🏋️  Treinos realizados: —$_activitiesText

Próxima meta: manter sobrecarga progressiva e fechar os treinos.''';
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
              onPressed: _hasReportData ? _copy : null,
            ),
          ),

          // Weight input card
          _buildWeightInputCard(),

          const SizedBox(height: 16),

          // Loading state
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(
                child: CircularProgressIndicator(color: AppColors.volt),
              ),
            )
          // Empty state — insufficient data
          else if (!_hasReportData)
            _buildEmptyState()
          // Report content
          else ...[
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
                    value: _currentWeight != null
                        ? '${_currentWeight!.toStringAsFixed(1)} kg'
                        : '—',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(label: 'Aderência dieta', value: '—'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: MetricCard(label: 'Treinos', value: '—'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: 'Exercícios PR',
                    value: '—',
                    highlight: true,
                  ),
                ),
              ],
            ),
          ],

          // Extra activities section
          if (!_isLoading && _extraActivities.isNotEmpty) ...[
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

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: ApexCard(
        child: Column(
          children: [
            const Icon(
              Icons.insert_chart_outlined,
              color: AppColors.mutedForeground,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Dados insuficientes para gerar o relatório',
              style: AppTextStyles.body(color: AppColors.foreground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Registre seu peso em jejum acima para começar.',
              style: AppTextStyles.bodySmall(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
