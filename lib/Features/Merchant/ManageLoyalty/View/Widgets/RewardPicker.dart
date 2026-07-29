import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';

class RewardPickerField extends StatelessWidget {
  final LoyaltyModeController controller;

  const RewardPickerField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          "linked_reward".tr,
          fontSize: size.width * 0.033,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF2D3142),
        ),
        const SizedBox(height: 8),
        Obx(
          () => GestureDetector(
            onTap: () => _openPicker(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : const Color(0xFFF4F5F7),
                border: Border.all(
                  color: controller.selectedReward.value == null
                      ? Colors.transparent
                      : AppColors.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Icon(Iconsax.gift, size: 18, color: AppColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppText(
                      controller.selectedReward.value?.name ??
                          "select_reward".tr,
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w600,
                      color: controller.selectedReward.value == null
                          ? (isDark
                              ? Colors.white.withOpacity(0.35)
                              : Colors.black.withOpacity(0.30))
                          : (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  Icon(
                    Iconsax.arrow_down_1,
                    size: 15,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SafeArea(
        top: false,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.7,
          ),
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151515) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              AppText(
                "select_reward".tr,
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : Colors.black,
              ),
              const SizedBox(height: 16),
              Flexible(
                child: Obx(() {
                  if (controller.rewardsLoading.value) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 30),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (controller.availableRewards.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: AppText(
                        "no_rewards".tr,
                        textAlign: TextAlign.center,
                        color: Colors.grey,
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: controller.availableRewards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final reward = controller.availableRewards[index];
                      final isSelected =
                          controller.selectedReward.value?.id == reward.id;

                      return GestureDetector(
                        onTap: () {
                          controller.selectReward(reward);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: isSelected
                                ? AppColors.primary.withOpacity(0.1)
                                : (isDark
                                    ? Colors.white.withOpacity(0.04)
                                    : Colors.black.withOpacity(0.03)),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.4)
                                  : Colors.transparent,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Iconsax.gift,
                                  size: 18, color: AppColors.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: AppText(
                                  reward.name,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (isSelected)
                                Icon(Iconsax.tick_circle,
                                    color: AppColors.primary, size: 18),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}