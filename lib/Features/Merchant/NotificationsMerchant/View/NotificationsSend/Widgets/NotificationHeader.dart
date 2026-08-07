import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';

class NotificationHeader extends StatelessWidget {
  const NotificationHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Get.locale?.languageCode == "ar";

    return Column(
      crossAxisAlignment: isRTL
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,

      children: [
        Align(
          alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
          child: FadeSlide(
            delayMs: 200,

            child: AppText(
              "send_notification".tr,

              fontSize: 22,

              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Align(
          alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
          child: FadeSlide(
            delayMs: 250,

            child: AppText(
              "send_notification_subtitle".tr,

              fontSize: 14,

              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withOpacity(.7),
            ),
          ),
        ),
      ],
    );
  }
}
