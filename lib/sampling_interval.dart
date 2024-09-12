enum SamplingInterval {
  event,
  fiveMinutes,
  fifteenMinutes,
  fourHours,
}

extension SamplingIntervalExt on SamplingInterval {
  Duration get duration {
    switch (this) {
      case SamplingInterval.event:
        return const Duration(seconds: 1);
      case SamplingInterval.fiveMinutes:
        return const Duration(minutes: 5);
      case SamplingInterval.fifteenMinutes:
        return const Duration(minutes: 15);
      case SamplingInterval.fourHours:
        return const Duration(hours: 4);
    }
  }
}
