/// Tipos de atividade extra suportados pelo app.
enum ActivityType { yoga, corrida, crossfit, natacao, tenisDeMesa }

/// Fonte de registro da atividade.
enum ActivitySource { manual, garmin }

/// Modelo de atividade extra complementar ao treino de musculação.
class ExtraActivity {
  final String id;
  final ActivityType type;
  final int durationMinutes; // duração em minutos, > 0
  final ActivitySource source;
  final DateTime date;

  const ExtraActivity({
    required this.id,
    required this.type,
    required this.durationMinutes,
    required this.source,
    required this.date,
  });

  /// Serializes this activity to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'durationMinutes': durationMinutes,
    'source': source.name,
    'date': date.toIso8601String(),
  };

  /// Deserializes an activity from a JSON-compatible map.
  factory ExtraActivity.fromJson(Map<String, dynamic> json) => ExtraActivity(
    id: json['id'] as String,
    type: ActivityType.values.byName(json['type'] as String),
    durationMinutes: json['durationMinutes'] as int,
    source: ActivitySource.values.byName(json['source'] as String),
    date: DateTime.parse(json['date'] as String),
  );
}
