enum WalkingType {
  walking,
  stopped,
  unknown;
}

class WalkingStatus {
  final WalkingType type;
  final DateTime dateTime;

  WalkingStatus({
    required this.type,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'walkingType': type.name,
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
