class LuxEvent {
  final int lux;
  final String timeStamp;

  LuxEvent({required this.lux, required this.timeStamp});

  Map<String, dynamic> toMap() => {
        'lux': lux,
        'timeStamp': timeStamp,
      };
}
