import 'package:flutter/material.dart';

class Responsive {
  static double w(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double h(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// scale based on screen width (design base = 375)
  static double scaleW(BuildContext context, double value) {
    return value * w(context) / 375;
  }

  /// scale based on screen height (design base = 812)
  static double scaleH(BuildContext context, double value) {
    return value * h(context) / 812;
  }
}