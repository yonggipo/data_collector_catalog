enum CollectorState {
  collecting,
  waiting,
  waitingPermission;

  @override
  String toString() {
    switch (this) {
      case CollectorState.collecting:
        return '수집중..';
      case CollectorState.waiting:
        return '수집 대기중..';
      case CollectorState.waitingPermission:
        return '권한 대기중..';
    }
  }
}
