import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RoleAnimatedSwitcher extends StatelessWidget {
  final RxString role;
  final Widget clientWidget;
  final Widget merchantWidget;

  const RoleAnimatedSwitcher({
    super.key,
    required this.role,
    required this.clientWidget,
    required this.merchantWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isClient = role.value == "client";

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, 0.08), // bottom → top
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: offsetAnimation,
              child: child,
            ),
          );
        },
        child: Container(
          key: ValueKey(role.value), // IMPORTANT for switching
          child: isClient ? clientWidget : merchantWidget,
        ),
      );
    });
  }
}