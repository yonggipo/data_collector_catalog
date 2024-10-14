class WalkingEvent {
  final int stepCount;
  final DateTime dateTime;

  WalkingEvent({
    required this.stepCount,
    required this.dateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'stepCount': stepCount.toString(),
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
