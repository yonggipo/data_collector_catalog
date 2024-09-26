abstract class Serializable {
  factory Serializable.fromMap(Map<String, dynamic> map) {
    throw UnimplementedError("fromJson() must be implemented in subclasses");
  }

  Map<String, dynamic> toMap();
}
