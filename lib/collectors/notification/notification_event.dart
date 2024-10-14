import '../../common/serializable.dart';

final class NotificationEvent implements Serializable {
  int? id;
  bool? hasRemoved;
  String? packageName;
  String? title;
  String? content;

  NotificationEvent({
    this.id,
    this.hasRemoved,
    this.packageName,
    this.title,
    this.content,
  });

  NotificationEvent.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    hasRemoved = map['hasRemoved'];
    packageName = map['packageName'];
    title = map['title'];
    content = map['content'];
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'hasRemoved': hasRemoved,
      'packageName': packageName,
      'title': title,
      'content': content,
    };
  }

  @override
  String toString() {
    return '''
      NotificationEvent(
        id: $id
        hasRemoved: $hasRemoved
        title: $title
        content: $content
      )
      ''';
  }
}
