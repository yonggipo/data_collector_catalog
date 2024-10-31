// ignore: unused_import
import 'dart:developer' as dev;

import 'package:firebase_database/firebase_database.dart';
import 'package:hive/hive.dart';

class FirebaseService {
  FirebaseService._() : super();
  static final FirebaseService shared = FirebaseService._();
  factory FirebaseService() => shared;

  static const _log = 'FirebaseService';
  static final _ref = FirebaseDatabase.instance.ref();

  // save root path
  Future<bool> setRoot(String root) async {
    final box = await Hive.openBox("user");
    box.put('root', root);
    final username = box.get('root');
    return (username != null);
  }

  // load root
  Future<String> _loadRoot() async {
    final box = await Hive.openBox("user");
    return box.get('root', defaultValue: "android_default_path");
  }

  // upload map data to firebase with path
  Future<void> upload({required String path, required Map map}) async {
    final root = await _loadRoot();
    // map['timestamp'] = (DateTime.now().millisecondsSinceEpoch ~/ 1000);
    return await _ref.child(root).child(path).push().set(map).catchError((e) {
      dev.log("error: $e", name: _log);
    });
  }

  // clear root path
  Future<void> clear() async {
    final root = await _loadRoot();
    // dev.log("Clear $root data", name: _log);
    // await _ref.remove();
    var snapshot = await _ref.child("acc").limitToLast(100).get();
    while (snapshot.exists) {
      for (var child in snapshot.children) {
        await _ref.child(child.key!).remove();
      }
      dev.log("remove 5 data", name: _log);
      snapshot = await _ref.child("acc").limitToLast(100).get();
    }
    dev.log("Clear All data", name: _log);

    // return await _ref.child(root).remove().catchError((e) {
    //   dev.log("error: $e", name: _log);
    // });
  }
}
