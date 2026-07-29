import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LoyaltyInputField.dart';

class LimitsCapsCard extends StatelessWidget {
  LimitsCapsCard({super.key});

  final controller = Get.find<LoyaltyModeController>();

  static const Color blue = Color(0xFF1E88E5);

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
                  color: blue.withOpacity(0.12),
                ),
                child: Icon(
                  Iconsax.shield_tick,
                  color: blue,
                  size: size.width * 0.052,
                ),
              ),
              SizedBox(width: size.width * 0.035),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "limits_caps".tr,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "limits_caps_subtitle".tr,
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

          /// ── FIELDS (mode-aware) ────────────────────────
          Obx(() {
            final mode = controller.selectedMode.value;
            final fields = <Widget>[];

            switch (mode) {
              case LoyaltyMode.points:
                fields.add(
                  LoyaltyInputField(
                    label: "max_points_day".tr,
                    icon: Iconsax.flash_1,
                    controller: controller.maxPointsPerDay,
                    hint: "e.g. 1000 pts",
                  ),
                );
                fields.add(SizedBox(height: size.height * 0.015));
                fields.add(
                  LoyaltyInputField(
                    label: "max_rewards_month".tr,
                    icon: Iconsax.gift,
                    controller: controller.maxRewardsPerMonth,
                    hint: "e.g. 10 rewards",
                  ),
                );
                break;

              case LoyaltyMode.stamps:
                fields.add(
                  LoyaltyInputField(
                    label: "max_stamps_day".tr,
                    icon: Iconsax.ticket,
                    controller: controller.maxStampsPerDay,
                    hint: "e.g. 5 stamps",
                  ),
                );
                fields.add(SizedBox(height: size.height * 0.015));
                fields.add(
                  LoyaltyInputField(
                    label: "max_rewards_month".tr,
                    icon: Iconsax.gift,
                    controller: controller.maxRewardsPerMonth,
                    hint: "e.g. 10 rewards",
                  ),
                );
                break;

              case LoyaltyMode.cashback:
                fields.add(
                  LoyaltyInputField(
                    label: "max_rewards_month".tr,
                    icon: Iconsax.gift,
                    controller: controller.maxRewardsPerMonth,
                    hint: "e.g. 10 rewards",
                  ),
                );
                break;
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: fields,
            );
          }),

          SizedBox(height: size.height * 0.02),

          /// ── INFO CARD ───────────────────────────────────
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: blue.withOpacity(0.08),
              border: Border.all(color: blue.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: blue,
                  size: size.width * 0.05,
                ),
                SizedBox(width: size.width * 0.03),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "limits_info_title".tr,
                        fontWeight: FontWeight.w600,
                        color: blue,
                        fontSize: size.width * 0.031,
                      ),
                      const SizedBox(height: 4),
                      AppText(
                        "limits_info_desc".tr,
                        fontSize: size.width * 0.031,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}