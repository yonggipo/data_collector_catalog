enum ScreenState {
  on,
  off,
  lock;

  static ScreenState fromString(String value) {
    switch (value) {
      case 'on':
        return ScreenState.on;
      case 'off':
        return ScreenState.off;
      case 'lock':
        return ScreenState.lock;
      default:
        throw ArgumentError('Invalid screen state: $value');
    }
  }

  @override
  String toString() => super.toString().split('.').last;
}
