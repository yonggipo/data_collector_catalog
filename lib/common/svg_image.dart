import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

enum SvgImage {
  // ignore: unused_field
  _;

  static final Widget boxArrowDonw = SvgPicture.asset(
      'assets/icons/BoxArrowDown.svg',
      semanticsLabel: 'Collecting Data Icon');
  static final Widget clockCountDown = SvgPicture.asset(
      'assets/icons/ClockCountdown.svg',
      semanticsLabel: 'Waiting To Collect Data');
  static final Widget warningCircle = SvgPicture.asset(
      'assets/icons/WarningCircle.svg',
      semanticsLabel: 'Waiting For Permission');
}
