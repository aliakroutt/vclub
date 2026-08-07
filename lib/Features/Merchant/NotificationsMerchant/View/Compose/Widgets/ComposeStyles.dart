import 'package:flutter/material.dart';

BoxDecoration composePanelDecoration(BuildContext context, {bool highlighted = false}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return BoxDecoration(
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05),
    ),
    // boxShadow: [
    //   BoxShadow(
    //     blurRadius: 18,
    //     spreadRadius: -10,
    //     offset: const Offset(0, 8),
    //     color: isDark ? Colors.black.withOpacity(.35) : Colors.black.withOpacity(.05),
    //   ),
    // ],
  );
}