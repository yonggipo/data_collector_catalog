enum SamplingInterval {
  test, event, min5, min15, h4;

  @override
  String toString() {
    switch (this) {
      case SamplingInterval.test: return 'test';
      case SamplingInterval.event: return 'event';
      case SamplingInterval.min5: return '5분';
      case SamplingInterval.min15: return '15분';
      case SamplingInterval.h4: return '4시간';
    }
  }
}

extension SamplingIntervalGetters on SamplingInterval {
  Duration get duration {
    switch (this) {
      case SamplingInterval.test: return const Duration(seconds: 10);
      case SamplingInterval.event: return const Duration(seconds: 1);
      case SamplingInterval.min5: return const Duration(minutes: 5);
      case SamplingInterval.min15: return const Duration(minutes: 15);
      case SamplingInterval.h4: return const Duration(hours: 4);
    }
  }
}
