import 'package:data_collector_catalog/common/firebase_service.dart';
import 'package:data_collector_catalog/screens/permission_state_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'dart:developer' as dev;

import '../common/constants.dart';

class UserInletScreen extends StatefulWidget {
  const UserInletScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _UserInletScreenState();
  }
}

class _UserInletScreenState extends State<UserInletScreen> {
  // ignore: unused_field
  static const _log = '_UserInletScreenState';

  final _controller = TextEditingController();
  bool _isButtonDisabled = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _createUser(BuildContext context) {
    dev.log('createUser: ${_controller.text}', name: _log);
    setState(() {
      _isButtonDisabled = true;
    });
    _moveToPermissionsScreen(context, _controller.text);
  }

  void _updateButtonState() {
    final text = _controller.text;
    final isValied = (text.length >= 3);
    dev.log('input text: $text, isValied: $isValied', name: _log);
    setState(() {
      _isButtonDisabled = !isValied;
    });
  }

  Future<void> _moveToPermissionsScreen(
      BuildContext context, String username) async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return Center(
          child: CupertinoActivityIndicator(radius: 20),
        );
      },
    );

    // firebase path setting
    await Future.delayed(Duration(seconds: 2));
    FirebaseService.shared.setRoot(username);
    Navigator.of(context).pop();
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => PermissionStateScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: Colors.white,
        middle: const Text('User Inlet Screen'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 48,
                child: CupertinoTextField(
                  controller: _controller,
                  placeholder: '이름을 입력해주세요',
                  textAlign: TextAlign.center,
                  placeholderStyle: TextStyle(
                    fontFamily: Constants.pretendard,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0x993C3C43),
                  ),
                  style: TextStyle(
                    fontFamily: Constants.pretendard,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Gap(16),
              CupertinoButton(
                onPressed:
                    _isButtonDisabled ? null : () => _createUser(context),
                color: Color(0xFF4C71F5),
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8.0),
                child: Text(
                  '유저 생성',
                  style: TextStyle(
                    fontFamily: Constants.pretendard,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
