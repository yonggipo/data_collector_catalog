import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/collection_item.dart';
import '../models/collector_premission_state.dart';

class PermissionStateScreen extends StatefulWidget {
  const PermissionStateScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _PermissionStateScreenState();
  }
}

class _PermissionStateScreenState extends State<PermissionStateScreen> {
  // ignore: unused_field
  static const _log = '_PermissionStateScreenState';

  Future<List<CollectionItem>> _getPermissionRequiredItems() async {
    return await Stream.fromIterable(CollectionItem.values)
        .asyncMap((item) async {
          final status = await item.permissionStatus;
          return status.isValid ? null : item;
        })
        .where((item) => item != null)
        .cast<CollectionItem>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('권한 설정'),
      ),
      child: FutureBuilder(
        future: _getPermissionRequiredItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else {
            final items = snapshot.data ?? [];
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (BuildContext context, int index) {
                final item = items[index];
                return Text(item.name);
              },
            );
          }
        },
      ),
    );
  }
}
