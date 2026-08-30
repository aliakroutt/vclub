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
                    Iconsax.arrow_circle_down_copy,
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

  void _openPicker(BuildContext context) async {
    // If rewards haven't loaded yet at all, wait briefly for the initial
    // fetch to settle before deciding whether to skip straight to the
    // add-reward sheet.
    if (controller.rewardsLoading.value) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _PickerLoadingSheet(controller: controller),
      );
      return;
    }

    if (controller.availableRewards.isEmpty) {
      // No rewards exist at all — skip the empty picker and go straight
      // to creating one, with a friendly nudge message.
      _openAddRewardSheet(context, isFirstReward: true);
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _RewardPickerSheet(
        controller: controller,
        onCreateNew: () {
          Navigator.pop(ctx);
          _openAddRewardSheet(context, isFirstReward: false);
        },
      ),
    );
  }

  void _openAddRewardSheet(BuildContext context, {required bool isFirstReward}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AddRewardInlineSheet(
        controller: controller,
        isFirstReward: isFirstReward,
      ),
    );
  }
}

/// Brief loading sheet shown only if the picker is opened before the
/// initial reward fetch has resolved.
class _PickerLoadingSheet extends StatelessWidget {
  final LoyaltyModeController controller;
  const _PickerLoadingSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151515) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// =========================
// PREMIUM PICKER SHEET
// =========================
class _RewardPickerSheet extends StatelessWidget {
  final LoyaltyModeController controller;
  final VoidCallback onCreateNew;

  const _RewardPickerSheet({required this.controller, required this.onCreateNew});

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
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    return SafeArea(
      top: false,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.78,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF151515) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 14),
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
            const SizedBox(height: 18),

            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Iconsax.gift, color: Colors.white, size: 21),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        AppText(
                          "select_reward".tr,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        const SizedBox(height: 2),
                        Obx(() => AppText(
                              "reward_count_available".trParams({
                                'count': '${controller.availableRewards.length}',
                              }),
                              fontSize: 12,
                              color: Colors.grey,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // ── LIST ──
            Flexible(
              child: Obx(() {
                if (controller.rewardsLoading.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: controller.availableRewards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final reward = controller.availableRewards[index];
                    final isSelected = controller.selectedReward.value?.id == reward.id;

                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          controller.selectReward(reward);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: isSelected
                                ? LinearGradient(
                                    colors: [
                                      AppColors.primary.withOpacity(0.14),
                                      AppColors.primary.withOpacity(0.05),
                                    ],
                                  )
                                : null,
                            color: isSelected
                                ? null
                                : (isDark
                                    ? Colors.white.withOpacity(0.04)
                                    : Colors.black.withOpacity(0.025)),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.4)
                                  : Colors.transparent,
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.12),
                                ),
                                child: Icon(_iconForType(reward.type), size: 17, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AppText(
                                  reward.name,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.5,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Iconsax.tick_circle, color: Colors.white, size: 14),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 14),

            // ── ADD NEW REWARD CTA ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: onCreateNew,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.35),
                        width: 1.4,
                      ),
                      color: AppColors.primary.withOpacity(0.06),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Iconsax.add_circle, size: 19, color: AppColors.primary),
                        const SizedBox(width: 8),
                        AppText(
                          "add_new_reward".tr,
                          fontWeight: FontWeight.w700,
                          fontSize: 14.5,
                          color: AppColors.primary,
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
    );
  }
}

// =========================
// ADD REWARD SHEET (inline, tied to LoyaltyModeController)
// =========================
class _AddRewardInlineSheet extends StatefulWidget {
  final LoyaltyModeController controller;
  final bool isFirstReward;

  const _AddRewardInlineSheet({required this.controller, required this.isFirstReward});

  @override
  State<_AddRewardInlineSheet> createState() => _AddRewardInlineSheetState();
}

class _AddRewardInlineSheetState extends State<_AddRewardInlineSheet> {
  final FocusNode _nameFocusNode = FocusNode();
  bool _isNameFocused = false;

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

  Future<void> _submit() async {
    final success = await widget.controller.addRewardFromPicker();
    if (success && mounted) {
      Navigator.pop(context);
    }
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

                Row(
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.75)],
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
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "add_new_reward".tr,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            widget.isFirstReward
                                ? "no_rewards_yet_subtitle".tr
                                : "add_new_reward_subtitle".tr,
                            fontSize: 12.5,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

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
                      color: _isNameFocused ? AppColors.primary.withOpacity(0.6) : Colors.transparent,
                      width: 1.4,
                    ),
                  ),
                  child: TextField(
                    controller: controller.rewardNameController,
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
                        color: isDark ? Colors.white.withOpacity(0.28) : Colors.black.withOpacity(0.25),
                      ),
                      prefixIcon: Icon(
                        Iconsax.tag,
                        size: 18,
                        color: isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.3),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF4F5F7),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

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
                    children: controller.rewardTypeOptions.map((t) {
                      final isSelected = controller.rewardTypeSelection.value == t["value"];

                      return GestureDetector(
                        onTap: () => controller.rewardTypeSelection.value = t["value"]!,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : (isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF4F5F7)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _iconForType(t["value"]!),
                                size: 16,
                                color: isSelected ? Colors.white : AppColors.primary,
                              ),
                              const SizedBox(width: 7),
                              AppText(
                                t["label"]!.tr,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 28),

                Obx(
                  () => SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isAddingRewardFromPicker.value ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: controller.isAddingRewardFromPicker.value
                            ? const SizedBox(
                                key: ValueKey('loading'),
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                              )
                            : Row(
                                key: const ValueKey('label'),
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.add_circle, size: 19, color: Colors.white),
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