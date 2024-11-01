// ignore: unused_import
import 'dart:developer' as dev;

import 'package:app_usage/app_usage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:notification_listener_service/notification_listener_service.dart';

import '../collectors/audio/audio_collector.dart';
import '../common/constants.dart';
import '../models/item.dart';
import '../models/permissions_getter.dart';
import '../views/animation_check.dart';
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
    final allGranted = await _requestAllPermission();
    dev.log('allGranted: $allGranted', name: _log);
    setState(() {});
  }

  Future<bool> _requestAllPermission() async {
    bool isNotiGranted;
    isNotiGranted = await NotificationListenerService.isPermissionGranted();
    if (!isNotiGranted)
      isNotiGranted = await NotificationListenerService.requestPermission();
    dev.log('isNotiGranted: $isNotiGranted', name: _log);

    bool isAppUsageGranted;
    isAppUsageGranted = await AppUsage.hasPermission();
    if (!isAppUsageGranted)
      isAppUsageGranted = await AppUsage.requestPermission();
    dev.log('isAppUsageGranted: $isAppUsageGranted', name: _log);

    bool isAudioGranted;
    isAudioGranted = await AudioCollector.shared.hasPermission();
    if (!isAudioGranted)
      isAudioGranted = await AudioCollector.shared.hasPermission();
    dev.log('isAudioGranted: $isAudioGranted', name: _log);

    final permissions = Item.values.expand((e) => e.permissions).toList();
    bool areGranted =
        (permissions.isEmpty) ? true : await permissions.requestRequired();
    dev.log('areGranted: $areGranted', name: _log);

    return (isNotiGranted && isAppUsageGranted && areGranted);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premission Setting',
          style: TextStyle(
            fontFamily: Constants.pretendard,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Column(
        children: [
          Gap(20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                itemCount: Item.values.length,
                itemBuilder: (context, index) {
                  final item = Item.values[index];
                  return SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        Gap(20),
                        FutureBuilder(
                          future: item.hasPermission,
                          builder: (context, snapshot) =>
                              (snapshot.data ?? false)
                                  ? Text(
                                      item.category,
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
                                      item.category,
                                      style: TextStyle(
                                        fontFamily: Constants.pretendard,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                        ),
                        Spacer(),
                        FutureBuilder(
                          future: item.hasPermission,
                          builder: (context, snapshot) =>
                              (snapshot.data ?? false)
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
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _requestRequiredPermissions,
                      child: Text(
                        '권한 재요청',
                        style: TextStyle(
                          fontFamily: Constants.pretendard,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(16),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: FilledButton.tonal(
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _moveToCollectStateScreen(context),
                      child: Text(
                        '데이터 수집',
                        style: TextStyle(
                          fontFamily: Constants.pretendard,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
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
