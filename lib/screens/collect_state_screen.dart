// ignore: unused_import
import 'dart:developer' as dev;

import 'package:data_collector_catalog/models/sampling_interval.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../common/svg_image.dart';
import '../models/collection_item.dart';
import '../models/collector_premission_state.dart';
import '../common/constants.dart';

class CollectStateScreen extends StatefulWidget {
  const CollectStateScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _CollectStateScreenState();
  }
}

class _CollectStateScreenState extends State<CollectStateScreen> {
  // ignore: unused_field
  static const logName = 'CollectStateScreen';

  List<CollectionItem> items = CollectionItem.values;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('Data Collector Catalog'),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _createCollectStateView(items[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _createCollectStateView(CollectionItem item) {
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
                  valueListenable: item.collector?.isCollectingNotifier ??
                      ValueNotifier(false),
                  builder:
                      (BuildContext context, dynamic value, Widget? child) {
                    return Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: value
                            ? SvgImage.cloudArrowUp
                            : SvgImage.cloudSlash);
                  },
                ),
                Gap(12),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.korean,
                      style: TextStyle(
                        fontFamily: Constants.pretendard,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Gap(4.0),
                    Text(
                      ' · 단위: ${item.description}',
                      style: TextStyle(
                        fontFamily: Constants.pretendard,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      ' · 주기: ${item.samplingInterval.toString()}',
                      style: TextStyle(
                        fontFamily: Constants.pretendard,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Gap(8.0),
                    FutureBuilder<CollectorPermissionState>(
                      future: item.permissionStatus,
                      builder: (context, snapshot) {
                        final status =
                            snapshot.data ?? CollectorPermissionState.required;
                        return SizedBox(
                          width: 160,
                          child: ValueListenableBuilder<double>(
                            valueListenable: item.collector?.progressNotifier ??
                                ValueNotifier(0),
                            builder: (BuildContext context, dynamic value,
                                Widget? child) {
                              return Visibility(
                                visible: ((status !=
                                        CollectorPermissionState.required) &&
                                    item.samplingInterval !=
                                        SamplingInterval.event),
                                child: LinearProgressIndicator(
                                  value: value,
                                  backgroundColor: Colors.white,
                                  color: Color(0xFF4C71F5),
                                  borderRadius: BorderRadius.circular(2.0),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    )
                  ],
                ),
                Spacer(),
                FutureBuilder<CollectorPermissionState>(
                  future: item.permissionStatus,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else {
                      final state =
                          snapshot.data ?? CollectorPermissionState.none;
                      return CupertinoButton(
                        color: state.indicatorColor,
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
                        minSize: 0,
                        onPressed: () async {
                          if (state == CollectorPermissionState.required) {
                            final isGranted = await item.requestRequired();
                            if (isGranted) item.collector?.onStart();
                            setState(() {});
                          }
                        },
                        child: Text(
                          state.title,
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
          ],
        ),
      ),
    );
  }
}
