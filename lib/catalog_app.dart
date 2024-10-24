import 'package:data_collector_catalog/screens/user_inlet_screen.dart';
import 'package:flutter/cupertino.dart';

class CatalogApp extends StatelessWidget {
  const CatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      theme: CupertinoThemeData(brightness: Brightness.light),
      home: UserInletScreen(),
    );
  }
}
