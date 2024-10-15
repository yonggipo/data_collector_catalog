import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum SvgImage {
  // ignore: unused_field
  _;

  static final Widget cloudArrowUp = SvgPicture.asset(
      'assets/icons/CloudArrowUp.svg',
      semanticsLabel: 'Collecting Data Icon');
  static final Widget cloudSlash = SvgPicture.asset(
      'assets/icons/CloudSlash.svg',
      semanticsLabel: 'Waiting To Collect Data');
}
