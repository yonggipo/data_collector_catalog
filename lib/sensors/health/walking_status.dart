enum WalkingType {
  walking,
  stopped,
  unknown;

  @override
  String toString() => toString().split('.').last;
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
      'type': type.toString(),
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
