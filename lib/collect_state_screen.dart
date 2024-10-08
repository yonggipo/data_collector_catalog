import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'collertor/collection_item.dart';
import 'collertor/collector_premission_state.dart';
import 'sensors/constants.dart';

class CollectStateScreen extends StatefulWidget {
  const CollectStateScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CollectStateScreenState();
  }
}

class _CollectStateScreenState extends State<CollectStateScreen> {
  static const logName = 'CollectStateScreen';
  // List<SensorUtil> sensors = [];

  List<CollectionItem> items = CollectionItem.values;

  @override
  void initState() {
    super.initState();

    // setupSensor();
    // startMonitoring();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('Data Collector Catalog'),
      ),
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _createCollectStateView(items[index]);
        },
      ),
    );
  }

  void setupSensor() {
    // sensors = [
    //   // LightSensorUtil(),
    //   NotiEventDetectorUtil(),
    //   MicrophoneUtil()

    //   //MicrophoneUtil(),

    //   // background type 변경

    //   // KeystrokeLogger(),
    // ];
  }

  // void startMonitoring() {
  //   dev.log('start monitoring.. sensors: ${sensors.length}');
  //   for (var sensor in sensors) {
  //     sensor.start();
  //     if (sensor.samplingInterval != SamplingInterval.event) {
  //       Timer.periodic(sensor.samplingInterval.duration, (Timer timer) {
  //         sensor.start();
  //       });
  //     }
  //   }
  // }
  Widget _createCollectStateView(CollectionItem item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.grey[200],
      ),
      width: 350,
      height: 100,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  item.name,
                  style: const TextStyle(fontSize: 18),
                ),
                Gap(4.0),
                Text(
                  item.unit,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            FutureBuilder<CollectorPermissionState>(
              future: item.permissionStatus,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  final status = snapshot.data ?? CollectorPermissionState.none;
                  return CupertinoButton(
                    color: status.indicatorColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 4.0),
                    minSize: 0,
                    onPressed: () async {
                      if (status == CollectorPermissionState.required) {
                        await item.requestRequiredPermissions();
                        setState(() {});
                      }
                    },
                    child: Text(
                      status.title,
                      style: TextStyle(
                        fontFamily: Constants.pretendard,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
