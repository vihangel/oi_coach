import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/models.dart';
import 'package:oi_coach/features/auth/view_model/auth_view_model.dart';
import 'package:oi_coach/shared/widgets/widgets.dart';

const _integrations = <IntegrationAccount>[
  IntegrationAccount(
    id: 'garmin',
    name: 'Garmin Connect',
    description:
        'Importe automaticamente séries, reps e cargas dos seus treinos registrados.',
    status: IntegrationStatus.disconnected,
  ),
  IntegrationAccount(
    id: 'apple_health',
    name: 'Apple Health',
    description: 'Sincronize peso e medidas corporais.',
    status: IntegrationStatus.disconnected,
  ),
  IntegrationAccount(
    id: 'google_fit',
    name: 'Google Fit',
    description: 'Backup automático do histórico de treino.',
    status: IntegrationStatus.disconnected,
  ),
];

class ConfiguracoesView extends StatefulWidget {
  final AuthViewModel authViewModel;

  const ConfiguracoesView({super.key, required this.authViewModel});

  @override
  State<ConfiguracoesView> createState() => _ConfiguracoesViewState();
}

class _ConfiguracoesViewState extends State<ConfiguracoesView> {
  bool _autoCompare = true;
  bool _notifications = false;

  @override
  Widget build(BuildContext context) {
    return SafePage(
      child: ListView(
        children: [
          const PageHeader(
            eyebrow: 'Sistema',
            title: 'Configurações & Integrações',
            description:
                'Conecte dispositivos e ajuste preferências de comparação automática.',
          ),

          // Integrations
          ..._integrations.map(
            (acc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ApexCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            acc.name.toUpperCase(),
                            style: AppTextStyles.body().copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: acc.status == IntegrationStatus.connected
                              ? 'Conectado'
                              : 'Não conectado',
                          variant: acc.status == IntegrationStatus.connected
                              ? BadgeVariant.volt
                              : BadgeVariant.muted,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(acc.description, style: AppTextStyles.bodySmall()),
                    const SizedBox(height: 12),
                    ApexButton(
                      label: 'Conectar',
                      variant: ApexButtonVariant.outline,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('PREFERÊNCIAS', style: AppTextStyles.display(size: 20)),
          const SizedBox(height: 16),

          _ToggleRow(
            label: 'Comparação automática com semana anterior',
            description:
                'Mostra carga, reps e ordem da semana passada ao iniciar o treino.',
            value: _autoCompare,
            onChanged: (v) => setState(() => _autoCompare = v),
          ),
          const SizedBox(height: 12),
          _ToggleRow(
            label: 'Notificações de treino',
            description: 'Lembretes nos dias planejados.',
            value: _notifications,
            onChanged: (v) => setState(() => _notifications = v),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => widget.authViewModel.logout(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.destructive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.destructive.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'SAIR',
                  style: AppTextStyles.button().copyWith(
                    color: AppColors.destructive,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label, description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ApexCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body().copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodySmall()),
              ],
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                color: value ? AppColors.volt : AppColors.muted,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
