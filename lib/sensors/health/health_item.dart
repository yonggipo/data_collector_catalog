enum ActivityType {
  vehicle,
  bicycle,
  running,
  still,
  walking,
  unknown;

  @override
  String toString() {
    switch (this) {
      case ActivityType.vehicle:
        return 'IN_VEHICLE';
      case ActivityType.bicycle:
        return 'ON_BICYCLE';
      case ActivityType.running:
        return 'RUNNING';
      case ActivityType.still:
        return 'STILL';
      case ActivityType.walking:
        return 'WALKING';
      case ActivityType.unknown:
        return 'UNKNOWN';
    }
  }
}

class HealthItem {
  HealthItem({
    required this.type,
    required this.confidence,
    required this.dateTime,
  });

  factory HealthItem.fromMap(Map<String, dynamic> map) {
    return HealthItem(
      type: ActivityType.values.firstWhere((e) => e.toString() == map['type']),
      confidence: map['confidence'],
      dateTime: DateTime.now(),
    );
  }

  final ActivityType type;
  final String confidence;
  final DateTime dateTime;

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString(),
      'confidence': confidence,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
