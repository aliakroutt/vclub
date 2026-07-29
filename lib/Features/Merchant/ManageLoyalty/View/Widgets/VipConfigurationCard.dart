import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LoyaltyInputField.dart';

class VipConfigurationCard extends StatelessWidget {
  VipConfigurationCard({super.key});

  final controller = Get.find<LoyaltyModeController>();

  static const Color purple = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── HEADER ───────────────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * 0.105,
                height: size.width * 0.105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: purple.withOpacity(0.12),
                ),
                child: Icon(
                  Iconsax.crown_1,
                  color: purple,
                  size: size.width * 0.052,
                ),
              ),
              SizedBox(width: size.width * 0.035),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "vip_configuration".tr,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "vip_configuration_subtitle".tr,
                      fontSize: size.width * 0.030,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.50),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),

          SizedBox(height: size.height * 0.02),

          /// ── FIELDS ───────────────────────────────────────
          LoyaltyInputField(
            label: "vip_threshold_pts".tr,
            icon: Iconsax.crown,
            controller: controller.vipThresholdController,
            hint: "e.g. 1000 pts",
          ),

          SizedBox(height: size.height * 0.015),

          LoyaltyInputField(
            label: "pts_for_review".tr,
            icon: Iconsax.star,
            controller: controller.reviewPointsController,
            hint: "e.g. 50 pts",
          ),

          SizedBox(height: size.height * 0.015),

          LoyaltyInputField(
            label: "review_cooldown_days".tr,
            icon: Iconsax.calendar,
            controller: controller.reviewCooldownController,
            hint: "e.g. 30 days",
          ),
        ],
      ),
    );
  }
}