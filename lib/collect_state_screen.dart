// ignore: unused_import
import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'collertor/collection_item.dart';
import 'collertor/collector_premission_state.dart';
import 'collertor/collector_state.dart';
import 'common/constants.dart';

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
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _createCollectStateView(items[index]);
        },
      ),
    );
  }

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
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: item.collectorState.icon,
            ),
            Gap(12),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: Constants.pretendard,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Gap(4.0),
                Text(
                  '단위: ${item.unit} · 수집주기: ${item.samplingInterval.toString()}',
                  style: TextStyle(
                    fontFamily: Constants.pretendard,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            Spacer(),
            FutureBuilder<CollectorPermissionState>(
              future: item.permissionStatus,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  final state = snapshot.data ?? CollectorPermissionState.none;
                  return CupertinoButton(
                    color: state.indicatorColor,
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
                    minSize: 0,
                    onPressed: () async {
                      if (state == CollectorPermissionState.required) {
                        await item.requestRequiredPermissions();
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
      ),
    );
  }
}
