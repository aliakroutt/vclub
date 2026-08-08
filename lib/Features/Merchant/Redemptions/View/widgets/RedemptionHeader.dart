import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';

class RedemptionHeader extends StatelessWidget {
  const RedemptionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isRTL = Get.locale?.languageCode == "ar";

    return Column(
      crossAxisAlignment: isRTL ? CrossAxisAlignment.start : CrossAxisAlignment.start,
      children: [
        FadeSlide(
          delayMs: 100,
          child: AppText("redemptions_title".tr, fontSize: 22, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        FadeSlide(
          delayMs: 150,
          child: AppText(
            "redemptions_subtitle".tr,
            fontSize: 14,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7),
          ),
        ),
      ],
    );
  }
}