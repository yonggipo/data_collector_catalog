// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:gap/gap.dart';

import '../common/local_db_service.dart';
import '../main.dart';
import '../models/collector.dart';
import '../common/constants.dart';

class CollectingStateScreen extends StatefulWidget {
  const CollectingStateScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CollectingStateScreenState();
  }
}

class _CollectingStateScreenState extends State<CollectingStateScreen> {
  // ignore: unused_field
  static const _log = 'CollectingStateScreen';

  @override
  void initState() {
    super.initState();
    _initializeAsyncTasks();
  }

  void _initializeAsyncTasks() async {
    dev.log('${Isolate.current.hashCode} Register message port', name: _log);
    LocalDbService.registerBackgroundMessagePort();
    for (var e in collectors) {
      await e.registerMessagePort();
    }
    dev.log('${Isolate.current.hashCode} Run flutter background service',
        name: _log);
    final service = FlutterBackgroundService();
    service.isRunning().then((isRunning) {
      dev.log('Is service running: $isRunning', name: _log);
      if (!isRunning) {
        service.startService().then((isStart) {
          dev.log('Is service start: $isStart', name: _log);
        });
      }
    });
  }

  void _uploadData() async {
    dev.log('${Isolate.current.hashCode} upload button taps', name: _log);
    for (var e in collectors) {
      for (var p in e.item.paths) {
        await LocalDbService.upload(p);
      }
      setState(() {
        e.valueNotifier.value = 'All data sent waiting collect..';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: collectors.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _createCollectStateView(collectors[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _uploadData,
        label: const Text('Send Data'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _createCollectStateView(Collector2 collector) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Color(0xFFF2F3FD),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: Column(
          children: [
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: collector.progressNotifier,
                  builder:
                      (BuildContext context, dynamic value, Widget? child) =>
                          SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      value: value,
                      semanticsLabel: 'Circular progress indicator',
                    ),
                  ),
                ),
                Gap(16),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          collector.item.category,
                          style: TextStyle(
                            fontFamily: Constants.pretendard,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Gap(4.0),
                        Text(
                          '(${collector.item.description} · ${collector.samplingInterval.name})',
                          style: TextStyle(
                            fontFamily: Constants.pretendard,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    ValueListenableBuilder(
                      valueListenable: collector.valueNotifier,
                      builder: (context, value, child) => Text(value ?? ''),
                    ),
                  ],
                ),
                Spacer(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
