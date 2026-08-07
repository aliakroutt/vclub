import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';

class NotificationTabs extends StatelessWidget {
  const NotificationTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeSlide(
      delayMs: 220,
      child: Container(
        height: 44,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? Colors.white.withOpacity(.06)
              : Colors.black.withOpacity(.04),
        ),
        child: TabBar(
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.tab,
          splashBorderRadius: BorderRadius.circular(11),
          overlayColor: WidgetStateProperty.all(Colors.transparent),
          indicator: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(11),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          labelColor: Colors.white,
          unselectedLabelColor:
              Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(.55),
          labelPadding: EdgeInsets.zero,
          tabs: [
            Tab(
              height: 38,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.edit_2, size: 15),
                  const SizedBox(width: 6),
                  AppText("compose".tr, fontSize: 12.5, fontWeight: FontWeight.w700),
                ],
              ),
            ),
            Tab(
              height: 38,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Iconsax.notification, size: 15),
                  const SizedBox(width: 6),
                  AppText("sent".tr, fontSize: 12.5, fontWeight: FontWeight.w700),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}