// ignore: unused_import
import 'dart:developer' as dev;

import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  FirebaseService._() : super();
  static final FirebaseService shared = FirebaseService._();
  factory FirebaseService() => shared;

  static const _log = 'FirebaseService';
  static final _ref = FirebaseDatabase.instance.ref();

  Future<void> upload({required String path, required Map map}) async {
    return await _ref
        .child("android")
        .child(path)
        .push()
        .set(map)
        .catchError((e) {
      dev.log("error: $e", name: _log);
    });
  }
}
