enum ScreenState {
  on,
  off,
  unlocked;

  static ScreenState fromString(String value) {
    switch (value) {
      case 'on':
        return ScreenState.on;
      case 'off':
        return ScreenState.off;
      case 'unlocked':
        return ScreenState.unlocked;
      default:
        throw ArgumentError('Invalid screen state: $value');
    }
  }
}
