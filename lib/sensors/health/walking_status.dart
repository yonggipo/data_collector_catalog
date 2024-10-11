enum WalkingType {
  walking,
  stopped,
  unknown;

  @override
  String toString() => super.toString().split('.').last;
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
      'walkingType': type.toString(),
      'dateTime': dateTime.toIso8601String(),
    };
  }
}
