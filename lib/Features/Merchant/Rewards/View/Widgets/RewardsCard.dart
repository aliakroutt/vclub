import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/RewardsMerchantModel.dart';
import 'package:vclub/Features/Merchant/Rewards/Controllers/RewardsMerchantController.dart';

class RewardCard extends StatelessWidget {
  final RewardModel reward;
  final RewardsMerchantController controller;

  const RewardCard({super.key, required this.reward, required this.controller});

  IconData get _icon {
    switch (reward.type) {
      case "product":
        return Iconsax.shopping_bag;
      case "discount":
        return Iconsax.discount_shape;
      case "free_item":
        return Iconsax.gift;
      case "drink":
        return Iconsax.coffee;
      case "dessert":
        return Iconsax.cake;
      case "points_bonus":
        return Iconsax.star_1;
      default:
        return Iconsax.more_circle;
    }
  }
  // NOTE: if `Iconsax.coffee` / `Iconsax.cake` don't exist in your
  // iconsax_flutter version, swap for any icon you already use.

  String get _typeLabelKey {
    switch (reward.type) {
      case "product":
        return "reward_type_product";
      case "discount":
        return "reward_type_discount";
      case "free_item":
        return "reward_type_free_item";
      case "drink":
        return "reward_type_drink";
      case "dessert":
        return "reward_type_dessert";
      case "points_bonus":
        return "reward_type_points_bonus";
      default:
        return "reward_type_other";
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Obx(() {
      final isDeleting = controller.deletingRewardId.value == reward.id;

      final actionPane = ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.24,
        children: [
          CustomSlidableAction(
            onPressed: (_) => _confirmDelete(context),
            backgroundColor: Colors.transparent,
            child: Container(
              margin: EdgeInsets.only(
                left: isRTL ? 0 : 8,
                right: isRTL ? 8 : 0,
              ),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: const Icon(Iconsax.trash, color: Colors.white),
            ),
          ),
        ],
      );

      return Padding(
        padding: EdgeInsets.only(bottom: size.height * 0.014),
        child: Slidable(
          key: ValueKey(reward.id),
          endActionPane: !isRTL ? actionPane : null,
          startActionPane: isRTL ? actionPane : null,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: isDeleting ? 0.45 : 1,
            child: Container(
              padding: EdgeInsets.all(size.width * 0.035),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF18181B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child:Row(
  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
  children: [
    Container(
      width: size.width * 0.13,
      height: size.width * 0.13,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(_icon, color: AppColors.primary, size: size.width * 0.06),
    ),
    SizedBox(width: size.width * 0.035),
    Expanded(
      child: Column(
        crossAxisAlignment:
            isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          AppText(
            reward.name,
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w700,
          ),
          const SizedBox(height: 4),
          AppText(
            _typeLabelKey.tr,
            fontSize: size.width * 0.030,
            color: Colors.grey,
          ),
        ],
      ),
    ),

    /// STATUS BADGE (active / inactive)
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: reward.active
            ? Colors.green.withOpacity(0.10)
            : Colors.grey.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: reward.active ? Colors.green : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          AppText(
            reward.active ? "active".tr : "inactive".tr,
            fontSize: size.width * 0.028,
            fontWeight: FontWeight.w700,
            color: reward.active ? Colors.green.shade700 : Colors.grey.shade600,
          ),
        ],
      ),
    ),

    if (isDeleting) ...[
      const SizedBox(width: 10),
      const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    ],
  ],
),
            ),
          ),
        ),
      );
    });
  }

  void _confirmDelete(BuildContext context) {
    showGeneralDialog(
      context: context,
    barrierDismissible: true,
    barrierLabel: "dismiss", // ← add this line
    barrierColor: Colors.black.withOpacity(0.4),
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
    transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
          child: FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 26),
                        ),
                        const SizedBox(height: 18),
                        AppText(
                          "delete_reward_title".tr,
                          textAlign: TextAlign.center,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          "delete_reward_message".trParams({"name": reward.name}),
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          height: 1.4,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              controller.deleteReward(reward);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AppText("delete".tr,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : const Color(0xFFF4F5F7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AppText("cancel".tr,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF2D3142)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}