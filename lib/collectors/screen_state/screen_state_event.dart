import '../../common/serializable.dart';
import 'screen_state.dart';

class ScreenStateEvent implements Serializable {
  ScreenStateEvent({this.screenState, this.timeStamp});

  ScreenState? screenState;
  DateTime? timeStamp;

  factory ScreenStateEvent.fromMap(Map<String, dynamic> map) {
    return ScreenStateEvent(
      screenState: map['screenState'] != null
          ? ScreenState.fromString(map['screenState'])
          : null,
      timeStamp:
          map['timeStamp'] != null ? DateTime.tryParse(map['timeStamp']) : null,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'screenState': screenState?.toString(),
      'timeStamp': timeStamp?.toIso8601String(),
    };
  }
}
