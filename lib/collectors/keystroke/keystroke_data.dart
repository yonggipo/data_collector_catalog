final class KeystrokeLog {
  KeystrokeLog({
    required this.text,
    required this.focusDuration,
    required this.keyboardEvents,
  });

  String text;
  Duration? focusDuration;
  List<KeyboardEvent> keyboardEvents;

  @override
  String toString() {
    return 'KeystrokeLog {\n'
        '  text: $text,\n'
        '  focusDuration: $focusDuration,\n'
        '  keyboardEvents: $keyboardEvents\n'
        '}';
  }
}

final class KeyboardEvent {
  KeyboardEvent({
    required this.keyLabel,
    required this.character,
    required this.timeStamp,
  });

  final String keyLabel;
  final String? character;
  final DateTime timeStamp;

  @override
  String toString() {
    return 'KeyboardEvent {\n'
        '  keyLabel: $keyLabel,\n'
        '  character: ${character == '\n' ? "\\n" : character},\n'
        '  timeStamp: $timeStamp\n'
        '}';
  }
}
