import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Rewards/Controllers/RewardsMerchantController.dart';

void showAddRewardSheet(
  BuildContext context,
  RewardsMerchantController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddRewardSheet(controller: controller),
  );
}

class _AddRewardSheet extends StatefulWidget {
  final RewardsMerchantController controller;
  const _AddRewardSheet({required this.controller});

  @override
  State<_AddRewardSheet> createState() => _AddRewardSheetState();
}

class _AddRewardSheetState extends State<_AddRewardSheet> {
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameFocused = false;

  // Icon per reward type, used in the chip grid
  IconData _iconForType(String type) {
    switch (type) {
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

  @override
  void initState() {
    super.initState();
    _nameFocusNode.addListener(() {
      setState(() => _isNameFocused = _nameFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';
    final controller = widget.controller;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF151515) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                /// DRAG HANDLE
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

                const SizedBox(height: 20),

                /// HEADER: icon badge + title + subtitle
                Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.75),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(Iconsax.gift, color: Colors.white, size: 22),
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isRTL
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "add_new_reward".tr,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            "add_new_reward_subtitle".tr,
                            fontSize: 12.5,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                /// NAME FIELD
                AppText(
                  "reward_name".tr,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D3142),
                ),
                const SizedBox(height: 8),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isNameFocused
                          ? AppColors.primary.withOpacity(0.6)
                          : Colors.transparent,
                      width: 1.4,
                    ),
                  ),
                  child: TextField(
                    controller: controller.newRewardNameController,
                    focusNode: _nameFocusNode,
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    textAlign: isRTL ? TextAlign.right : TextAlign.left,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    decoration: InputDecoration(
                      hintText: "enter_reward_name".tr,
                      hintStyle: TextStyle(
                        color: isDark
                            ? Colors.white.withOpacity(0.28)
                            : Colors.black.withOpacity(0.25),
                      ),
                      prefixIcon: Icon(
                        Iconsax.tag,
                        size: 18,
                        color: isDark
                            ? Colors.white.withOpacity(0.35)
                            : Colors.black.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withOpacity(0.06)
                          : const Color(0xFFF4F5F7),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                /// TYPE — chip grid selector
                AppText(
                  "reward_type".tr,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF2D3142),
                ),
                const SizedBox(height: 10),
                Obx(
                  () => Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: controller.rewardTypes.map((t) {
                      final isSelected = controller.newRewardType.value == t["value"];

                      return GestureDetector(
                        onTap: () => controller.newRewardType.value = t["value"]!,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : const Color(0xFFF4F5F7)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark
                                      ? Colors.white.withOpacity(0.08)
                                      : Colors.black.withOpacity(0.06)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _iconForType(t["value"]!),
                                size: 16,
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 7),
                              AppText(
                                t["label"]!.tr,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 28),

                /// SUBMIT
                Obx(
                  () => SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isAddingReward.value
                          ? null
                          : controller.submitNewReward,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            AppColors.primary.withOpacity(0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: controller.isAddingReward.value
                            ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : Row(
                                key: const ValueKey('label'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.add_circle,
                                      size: 19, color: Colors.white),
                                  const SizedBox(width: 8),
                                  AppText(
                                    "add_reward".tr,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}