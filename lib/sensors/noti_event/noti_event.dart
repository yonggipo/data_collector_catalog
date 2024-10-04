import 'dart:typed_data';

final class NotiEvent {
  int? id;
  bool? canReply;
  bool? haveExtraPicture;
  bool? hasRemoved;
  Uint8List? extrasPicture;
  String? packageName;
  String? title;
  Uint8List? appIcon;
  Uint8List? largeIcon;
  String? content;

  NotiEvent({
    this.id,
    this.canReply,
    this.haveExtraPicture,
    this.hasRemoved,
    this.extrasPicture,
    this.packageName,
    this.title,
    this.appIcon,
    this.largeIcon,
    this.content,
  });

  NotiEvent.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    canReply = map['canReply'];
    haveExtraPicture = map['haveExtraPicture'];
    hasRemoved = map['hasRemoved'];
    extrasPicture = map['notificationExtrasPicture'];
    packageName = map['packageName'];
    title = map['title'];
    appIcon = map['appIcon'];
    largeIcon = map['largeIcon'];
    content = map['content'];
  }

  @override
  String toString() {
    return '''
      NotificationEvent(
        id: $id
        canReply: $canReply
        haveExtraPicture: $haveExtraPicture
        hasRemoved: $hasRemoved
        extrasPicture: $extrasPicture
        title: $title
        appIcon: $appIcon
        largeIcon: $largeIcon
        content: $content
      )
      ''';
  }
}
