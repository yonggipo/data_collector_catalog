// ignore: unused_import
import 'dart:developer' as dev;
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:gap/gap.dart';

import '../common/local_db_service.dart';
import '../common/svg_image.dart';
import '../main.dart';
import '../models/collection_item.dart';
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
    dev.log('[${Isolate.current.hashCode}] Register message port', name: _log);
    LocalDbService.registerBackgroundMessagePort();
    for (var e in collectors) {
      await e.registerMessagePort();
    }
    dev.log('[${Isolate.current.hashCode}] Run flutter background service',
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
    final names = [
      'user_accelerometer',
      'accelerometer',
      'gyroscope',
      'magnetometer'
    ]; // CollectionItem.values.map((item) => item.name);
    for (var path in names) {
      LocalDbService.sendMessageToUploadPort(path);
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
                          CircularProgressIndicator(
                    value: value,
                    semanticsLabel: 'Circular progress indicator',
                  ),
                ),
                Gap(8.0),
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
                          '(${collector.item.description})',
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
                    // Text(
                    //   ' · 주기: ${item.samplingInterval.toString()}',
                    //   style: TextStyle(
                    //     fontFamily: Constants.pretendard,
                    //     fontSize: 13,
                    //     fontWeight: FontWeight.w400,
                    //   ),
                    // ),
                    // Gap(8.0),
                    // FutureBuilder<CollectorPermissionState>(
                    //   future: item.permissionStatus,
                    //   builder: (context, snapshot) {
                    //     final status =
                    //         snapshot.data ?? CollectorPermissionState.required;
                    //     return SizedBox(
                    //       width: 160,
                    //       child: ValueListenableBuilder<double>(
                    //         valueListenable: item.collector?.progressNotifier ??
                    //             ValueNotifier(0),
                    //         builder: (BuildContext context, dynamic value,
                    //             Widget? child) {
                    //           return Visibility(
                    //             visible: ((status !=
                    //                     CollectorPermissionState.required) &&
                    //                 item.samplingInterval !=
                    //                     SamplingInterval.event),
                    //             child: LinearProgressIndicator(
                    //               value: value,
                    //               backgroundColor: Colors.white,
                    //               color: Color(0xFF4C71F5),
                    //               borderRadius: BorderRadius.circular(2.0),
                    //             ),
                    //           );
                    //         },
                    //       ),
                    //     );
                    //   },
                    // )
                  ],
                ),
                Spacer(),
                // FutureBuilder<CollectorPermissionState>(
                //   future: item.permissionStatus,
                //   builder: (context, snapshot) {
                //     if (snapshot.connectionState == ConnectionState.waiting) {
                //       return const CircularProgressIndicator();
                //     } else {
                //       final state =
                //           snapshot.data ?? CollectorPermissionState.none;
                //       return CupertinoButton(
                //         color: state.indicatorColor,
                //         padding:
                //             EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
                //         minSize: 0,
                //         onPressed: () async {
                //           if (state == CollectorPermissionState.required) {
                //             final isGranted = await item.requestRequired();
                //             if (isGranted) item.collector?.onCollectStart();
                //             setState(() {});
                //           }
                //         },
                //         child: Text(
                //           state.title,
                //           style: TextStyle(
                //             fontFamily: Constants.pretendard,
                //             fontSize: 14,
                //             fontWeight: FontWeight.w500,
                //             color: Colors.white,
                //           ),
                //         ),
                //       );
                //     }
                //   },
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
