import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Controllers/MerchantGoogleReviewController.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Models/GoogleReviewModels.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';

class GoogleReviewsStatsColumn extends StatelessWidget {
  const GoogleReviewsStatsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantGoogleReviewController>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      if (controller.loading.value && !controller.initialLoaded.value) {
        return ShimmerWrapper(
          child: Column(
            children: List.generate(
              3,
              (i) => Padding(
                padding: EdgeInsets.only(bottom: size.height * 0.015),
                child: Container(
                  height: size.height * .1,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(.05),
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
              ),
            ),
          ),
        );
      }

      final LoyaltyProgramModel? program = controller.program.value;
      final modeLabel = program?.mode == 'points'
          ? "points_label".tr
          : program?.mode == 'stamps'
              ? "stamps_label".tr
              : "cashback_label".tr;

      final expiryDays = program?.mode == 'points'
          ? program?.pointsExpiryDays
          : program?.mode == 'stamps'
              ? program?.stampsExpiryDays
              : program?.cashbackExpiryDays;

      final stats = [
        {
          "title": "review_reward_points".tr,
          "value": "${program?.reviewRewardPoints ?? 0} $modeLabel",
          "icon": Iconsax.star_1,
          "color": const Color(0xFFFFC542),
        },
        {
          "title": "review_reward_cooldown".tr,
          "value": "${program?.reviewRewardCooldownDays ?? 0} ${"days_label".tr}",
          "icon": Iconsax.timer_1,
          "color": const Color(0xFF6C5CE7),
        },
        {
          "title": "loyalty_expiry_label".tr,
          "value": "${expiryDays ?? 0} ${"days_label".tr}",
          "icon": Iconsax.calendar_1,
          "color": const Color(0xFF00B894),
        },
      ];

      return Column(
        children: List.generate(stats.length, (index) {
          final item = stats[index];

          return Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.015),
            child: FadeSlide(
              delayMs: 200 + index * 100,
              child: _StatCard(
                title: item["title"].toString(),
                value: item["value"].toString(),
                icon: item["icon"] as IconData,
                color: item["color"] as Color,
                isDark: isDark,
                size: size,
              ),
            ),
          );
        }),
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Size size;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.045,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.14,
            height: size.width * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color.withOpacity(0.18), color.withOpacity(0.05)],
              ),
            ),
            child: Icon(icon, color: color, size: size.width * 0.055),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
                SizedBox(height: size.height * 0.005),
                AppText(value, fontSize: size.width * 0.052, fontWeight: FontWeight.w800),
              ],
            ),
          ),
        ],
      ),
    );
  }
}