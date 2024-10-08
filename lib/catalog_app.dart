import 'package:flutter/cupertino.dart';

import 'collect_state_screen.dart';

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: CollectStateScreen(),
    );
  }
}
