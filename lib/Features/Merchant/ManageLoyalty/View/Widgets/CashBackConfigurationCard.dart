import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LoyaltyInputField.dart';

class CashbackConfigurationCard extends StatelessWidget {
  CashbackConfigurationCard({super.key});

  final controller = Get.find<LoyaltyModeController>();

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
            color: Colors.black.withOpacity(
              isDark ? 0.22 : 0.04,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── HEADER ─────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * 0.105,
                height: size.width * 0.105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary.withOpacity(0.12),
                ),
                child: Icon(
                  Iconsax.wallet_money,
                  color: AppColors.primary,
                  size: size.width * 0.052,
                ),
              ),
              SizedBox(width: size.width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "cashback_rules".tr,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "cashback_rules_subtitle".tr,
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

          SizedBox(height: size.height * 0.022),

          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),

          SizedBox(height: size.height * 0.022),

          /// RATE
          LoyaltyInputField(
            label: "cashback_rate".tr,
            controller: controller.cashbackRateController,
            icon: Iconsax.percentage_circle,
             hint: "hint_cashback_rate".tr,
          ),

          SizedBox(height: size.height * 0.018),

          /// MINIMUM PURCHASE
          LoyaltyInputField(
            label: "cashback_minimum_purchase".tr,
            controller: controller.cashbackMinimumController,
            icon: Iconsax.shopping_cart,
             hint: "hint_cashback_minimum".tr,
          ),

          SizedBox(height: size.height * 0.018),

          /// EXPIRY
          LoyaltyInputField(
            label: "cashback_expiry".tr,
            controller: controller.cashbackExpiryController,
            icon: Iconsax.calendar,
              hint: "hint_cashback_expiry".tr,
          ),

          SizedBox(height: size.height * 0.025),

          /// INFO CARD
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primary.withOpacity(0.10),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.20),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Iconsax.info_circle,
                  color: AppColors.primary,
                  size: size.width * 0.05,
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "cashback_example".tr,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: size.width * 0.031,
                      ),
                      SizedBox(height: size.height * 0.005),
                      AppText(
                        "cashback_example_text".tr,
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