import 'package:flutter/material.dart';
import 'package:oi_coach/app/theme/app_colors.dart';
import 'package:oi_coach/app/theme/app_text_styles.dart';
import 'package:oi_coach/core/models/models.dart';

/// Bottom sheet for adding an extra activity.
/// Full implementation in Task 6.4.
class AddActivitySheet extends StatefulWidget {
  final void Function(ExtraActivity activity) onSave;

  const AddActivitySheet({super.key, required this.onSave});

  @override
  State<AddActivitySheet> createState() => _AddActivitySheetState();
}

class _AddActivitySheetState extends State<AddActivitySheet> {
  ActivityType? _selectedType;
  final _durationController = TextEditingController();

  bool get _canSave =>
      _selectedType != null &&
      (int.tryParse(_durationController.text) ?? 0) > 0;

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NOVA ATIVIDADE',
            style: AppTextStyles.monoLabel(color: AppColors.volt),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<ActivityType>(
            initialValue: _selectedType,
            dropdownColor: AppColors.surfaceElevated,
            decoration: const InputDecoration(
              labelText: 'Tipo de atividade',
              isDense: true,
            ),
            items: ActivityType.values.map((t) {
              return DropdownMenuItem(
                value: t,
                child: Text(_typeLabel(t), style: AppTextStyles.body()),
              );
            }).toList(),
            onChanged: (v) => setState(() => _selectedType = v),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _durationController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Duração (minutos)',
              isDense: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _canSave ? _save : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: _canSave ? AppColors.volt : AppColors.muted,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  'SALVAR',
                  style: AppTextStyles.button().copyWith(
                    color: _canSave
                        ? AppColors.primaryForeground
                        : AppColors.mutedForeground,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final activity = ExtraActivity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType!,
      durationMinutes: int.parse(_durationController.text),
      source: ActivitySource.manual,
      date: DateTime.now(),
    );
    widget.onSave(activity);
  }

  String _typeLabel(ActivityType type) => switch (type) {
    ActivityType.yoga => 'Yoga',
    ActivityType.corrida => 'Corrida',
    ActivityType.crossfit => 'Crossfit',
    ActivityType.natacao => 'Natação',
    ActivityType.tenisDeMesa => 'Tênis de Mesa',
  };
}
