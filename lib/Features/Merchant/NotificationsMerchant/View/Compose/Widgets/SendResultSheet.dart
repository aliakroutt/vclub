import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

Future<void> showSendResultSheet(
  BuildContext context, {
  required bool success,
  String? message,
  VoidCallback? onPrimary,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final color = success ? const Color(0xFF1DB876) : Colors.redAccent;

  return showModalBottomSheet(
    context: context,
    isDismissible: !success,
    enableDrag: !success,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return SafeArea(child:  Container(
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F26) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.elasticOut,
              builder: (context, value, child) => Transform.scale(scale: value, child: child),
              child: Container(
                height: 84,
                width: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(.18), color.withOpacity(.05)],
                  ),
                ),
                child: Icon(
                  success ? Iconsax.tick_circle_copy : Iconsax.close_circle_copy,
                  size: 42,
                  color: color,
                ),
              ),
            ),
            const SizedBox(height: 22),
            AppText(
              success ? "notification_sent_title".tr : "notification_failed_title".tr,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            AppText(
              success
                  ? "notification_sent_subtitle".tr
                  : ((message == null || message.isEmpty) ? "notification_failed_subtitle".tr : message),
              fontSize: 13.5,
              textAlign: TextAlign.center,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
            ),
            const SizedBox(height: 26),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: Material(
                color: color,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    Navigator.pop(context);
                    onPrimary?.call();
                  },
                  child: Center(
                    child: AppText(
                      success ? "close".tr : "retry".tr,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
    },
  );
}