class HealthHistoryRecord {
  final String id;
  final DateTime timestamp;
  final int healthScore;
  final String title;
  final String description;
  final HealthEventType type;

  HealthHistoryRecord({
    required this.id,
    required this.timestamp,
    required this.healthScore,
    required this.title,
    required this.description,
    required this.type,
  });
}

enum HealthEventType {
  maintenance, // Green
  alert,       // Red/Amber
  scan,        // Neutral/Blue
}
