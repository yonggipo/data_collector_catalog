import 'dart:typed_data';

final class NotificationEvent {
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

  NotificationEvent({
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

  NotificationEvent.fromMap(Map<String, dynamic> map) {
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

  /// send a direct message reply to the incoming notification
  Future<bool> sendReply(String message) async {
    if (!(canReply ?? false))
      throw Exception("The notification is not replyable");
    try {
      // return await methodeChannel.invokeMethod<bool>("sendReply", {
      //       'message': message,
      //       'notificationId': id,
      //     }) ??
      //     false;
      return false;
    } catch (e) {
      rethrow;
    }
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
