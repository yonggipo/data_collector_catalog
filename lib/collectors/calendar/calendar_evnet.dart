class CalendarEvent {
  CalendarEvent({
    this.title,
    this.description,
    this.startTime,
    this.endTime,
  });

  String? title;
  String? description;
  DateTime? startTime;
  DateTime? endTime;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '''
    CalendarEvent(
    title: $title, 
    description: $description
    startTime: $startTime,
    endTime: $startTime
    )
    ''';
  }
}
