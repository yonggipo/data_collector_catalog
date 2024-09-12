enum SamplingInterval {
  event,
  min5,
  min15,
  h4,
}

extension SamplingIntervalExt on SamplingInterval {
  Duration get duration {
    switch (this) {
      case SamplingInterval.event:
        return const Duration(seconds: 1);
      case SamplingInterval.min5:
        return const Duration(minutes: 5);
      case SamplingInterval.min15:
        return const Duration(minutes: 15);
      case SamplingInterval.h4:
        return const Duration(hours: 4);
    }
  }
}
