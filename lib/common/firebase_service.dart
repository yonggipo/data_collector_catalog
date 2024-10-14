// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/common/serializable.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  FirebaseService._() : super();
  static final FirebaseService shared = FirebaseService._();
  factory FirebaseService() => shared;

  static const _log = 'FirebaseService';
  static final _ref = FirebaseDatabase.instance.ref();

  Future<void> upload(
      {required String path, required Serializable serializable}) async {
    return await _ref
        .child(path)
        .push()
        .set(serializable.toMap)
        .catchError((e) {
      dev.log("error: $e", name: _log);
    });
  }
}
