import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import "permission_state_screen.dart";
import '../common/constants.dart';
import '../common/firebase_service.dart';

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
  bool _isButtonDisabled = true;

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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Loading..."),
              ],
            ),
          ),
        );
      },
    );

    // firebase path setting
    await FirebaseService.shared.setRoot(username);
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PermissionStateScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'User Registration',
          style: TextStyle(
            fontFamily: Constants.pretendard,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                height: 48,
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '이름을 입력해주세요',
                    hintStyle: TextStyle(
                      fontFamily: Constants.pretendard,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0x993C3C43),
                    ),
                  ),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: Constants.pretendard,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Gap(16),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed:
                    _isButtonDisabled ? null : () => _createUser(context),
                child: Text(
                  '유저 등록',
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
