import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LoyaltyInputField.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/RewardPicker.dart';

class StampsConfigurationCard extends StatelessWidget {
  StampsConfigurationCard({super.key});

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
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                width: size.width * 0.105,
                height: size.width * 0.105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: AppColors.primary.withOpacity(0.10),
                ),
                child: Icon(
                  Iconsax.ticket_discount,
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
                      "stamp_rules".tr,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "stamp_rules_subtitle".tr,
                      fontSize: size.width * 0.030,
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.50),
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

          RewardPickerField(controller: controller),
          SizedBox(height: size.height * 0.018),

          LoyaltyInputField(
            label: "stamps_per_visit".tr,
            controller: controller.stampsPerVisitController,
            icon: Iconsax.ticket,
            hint: "hint_stamps_per_visit".tr,
          ),

          SizedBox(height: size.height * 0.018),

          LoyaltyInputField(
            label: "stamps_required".tr,
            controller: controller.stampsRequiredController,
            icon: Iconsax.ticket_discount,
            hint: "hint_stamps_required".tr,
          ),

          SizedBox(height: size.height * 0.018),

          LoyaltyInputField(
            label: "expiry_days".tr,
            controller: controller.stampsExpiryController,
            icon: Iconsax.calendar,
            hint: "hint_expiry_days".tr,
          ),

          SizedBox(height: size.height * 0.025),

          /// INFO CARD
          Container(
            padding: EdgeInsets.all(size.width * 0.04),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.primary.withOpacity(0.08),
              border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
                        "stamp_example".tr,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        fontSize: size.width * 0.031,
                      ),

                      SizedBox(height: size.height * 0.005),

                      AppText(
                        "stamp_example_text".tr,
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
