// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/models/collector_premission_state.dart';
import 'package:data_collector_catalog/screens/data_collection_screen.dart';
import 'package:data_collector_catalog/views/animation_check.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../common/constants.dart';
import '../models/collection_item.dart';
import 'collecting_state_screen.dart';

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

  void _moveToCollectStateScreen(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CollectingStateScreen(),
      ),
    );
  }

  void _requestRequiredPermissions() async {
    final items = CollectionItem.values;
    for (var item in items) {
      await item.requestRequired();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text(
          '권한 설정',
          style: TextStyle(
            fontFamily: Constants.pretendard,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      child: Column(
        children: [
          Gap(20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: CollectionItem.values.length,
                itemBuilder: (context, index) {
                  final item = CollectionItem.values[index];
                  return SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Gap(20),
                        FutureBuilder(
                          future: item.permissionStatus,
                          builder: (context, snapshot) =>
                              (snapshot.data?.isValid ?? false)
                                  ? Text(
                                      item.korean,
                                      style: TextStyle(
                                        fontFamily: Constants.pretendard,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0x993C3C43),
                                        decoration: TextDecoration
                                            .lineThrough, // 취소선 추가
                                      ),
                                    )
                                  : Text(
                                      item.korean,
                                      style: TextStyle(
                                        fontFamily: Constants.pretendard,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                        ),
                        Spacer(),
                        FutureBuilder(
                          future: item.permissionStatus,
                          builder: (context, snapshot) =>
                              (snapshot.data?.isValid ?? false)
                                  ? SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: AnimatedCheck(),
                                    )
                                  : SizedBox.shrink(),
                        ),
                        Gap(20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          Gap(20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: CupertinoButton(
                      onPressed: _requestRequiredPermissions,
                      color: Color(0xFF4C71F5),
                      padding: EdgeInsets.zero,
                      child: Text(
                        '권한 재요청',
                        style: TextStyle(
                          fontFamily: Constants.pretendard,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(8.0),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: CupertinoButton(
                      onPressed: () => _moveToCollectStateScreen(context),
                      color: Color(0xFF4C71F5),
                      padding: EdgeInsets.zero,
                      child: Text(
                        '데이터 수집',
                        style: TextStyle(
                          fontFamily: Constants.pretendard,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Gap(20),
        ],
      ),
    );
  }
}

// FutureBuilder(
//         future: _getPermissionRequiredItems(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const CircularProgressIndicator();
//           } else {
//             final items = snapshot.data ?? [];
//             return ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (BuildContext context, int index) {
//                 final item = items[index];
//                 return Text(item.name);
//               },
//             );
//           }
//         },
//       )
