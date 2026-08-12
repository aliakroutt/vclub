import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Controllers/MerchantGoogleReviewController.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Models/GoogleReviewModels.dart';

class RewardAfterReviewCard extends StatelessWidget {
  const RewardAfterReviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MerchantGoogleReviewController>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.038),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.04), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * 0.09,
                height: size.width * 0.09,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color(0xFFE24B4A).withOpacity(0.1)),
                child: const Icon(Iconsax.gift, color: Color(0xFFE24B4A), size: 17),
              ),
              SizedBox(width: size.width * 0.025),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText("reward_after_review_title".tr, fontSize: size.width * 0.036, fontWeight: FontWeight.w600),
                    AppText(
                      "reward_after_review_subtitle".tr,
                      fontSize: size.width * 0.026,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * 0.02),

          AppText("reward_offered_label".tr, fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.withOpacity(.8)),
          const SizedBox(height: 8),
          Obx(() => _SelectField(
                icon: Iconsax.gift,
                label: controller.selectedReward.value?.name ?? "select_reward_placeholder".tr,
                empty: controller.selectedReward.value == null,
                onTap: () => _showRewardSelectSheet(context, controller),
              )),

          SizedBox(height: size.height * 0.018),

          AppText("invitation_trigger_label".tr, fontSize: 12, fontWeight: FontWeight.w700, color: Colors.grey.withOpacity(.8)),
          const SizedBox(height: 8),
          Obx(() {
            final trigger = controller.selectedTrigger.value;
            final label = trigger == ReviewTrigger.rewardRedeem
                ? "trigger_reward_redeem".tr
                : trigger == ReviewTrigger.programEnd
                    ? "trigger_program_end".tr
                    : "select_trigger_placeholder".tr;

            return _SelectField(
              icon: Iconsax.flash_1,
              label: label,
              empty: trigger == null,
              onTap: () => _showTriggerSelectSheet(context, controller),
            );
          }),

          // ── Save Changes button — only enabled when something changed ──
          Obx(() {
            final hasChanges = controller.hasUnsavedRewardSettings;
            final saving = controller.isSavingRewardSettings.value;

            return AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: hasChanges || saving
                  ? Padding(
                      padding: EdgeInsets.only(top: size.height * 0.02),
                      child: SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: Material(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(13),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(13),
                            onTap: saving ? null : () => controller.saveRewardSettingsIfChanged(),
                            child: Center(
                              child: saving
                                  ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 22)
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Iconsax.tick_circle, size: 16, color: Colors.white),
                                        const SizedBox(width: 8),
                                        AppText("save_changes".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            );
          }),
        ],
      ),
    );
  }
}

class _SelectField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool empty;
  final VoidCallback onTap;

  const _SelectField({required this.icon, required this.label, required this.empty, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 16, color: empty ? Colors.grey.withOpacity(.6) : AppColors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  label,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  overflow: TextOverflow.ellipsis,
                  color: empty ? Colors.grey.withOpacity(.6) : null,
                ),
              ),
              Icon(Iconsax.arrow_circle_down_copy, size: 14, color: Colors.grey.withOpacity(.5)),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showRewardSelectSheet(BuildContext context, MerchantGoogleReviewController controller) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .7),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(children: [AppText("select_reward_title".tr, fontSize: 16, fontWeight: FontWeight.w800)]),
              ),
              Flexible(
                child: Obx(() {
                  if (controller.rewards.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      child: Center(
                        child: AppText(
                          "no_rewards_found".tr,
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                    itemCount: controller.rewards.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final reward = controller.rewards[index];

                      return Obx(() {
                        final selected = controller.selectedReward.value?.id == reward.id;

                        return _OptionRow(
                          selected: selected,
                          icon: Iconsax.gift,
                          title: reward.name,
                          subtitle: "${reward.cost} ${"points_label".tr}",
                          onTap: () {
                            controller.setSelectedReward(reward);
                            Navigator.pop(sheetContext);
                          },
                        );
                      });
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showTriggerSelectSheet(BuildContext context, MerchantGoogleReviewController controller) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(children: [AppText("select_trigger_title".tr, fontSize: 16, fontWeight: FontWeight.w800)]),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                child: Column(
                  children: [
                    Obx(() => _OptionRow(
                          selected: controller.selectedTrigger.value == ReviewTrigger.rewardRedeem,
                          icon: Iconsax.gift,
                          title: "trigger_reward_redeem".tr,
                          subtitle: "trigger_reward_redeem_subtitle".tr,
                          onTap: () {
                            controller.setSelectedTrigger(ReviewTrigger.rewardRedeem);
                            Navigator.pop(sheetContext);
                          },
                        )),
                    const SizedBox(height: 8),
                    Obx(() => _OptionRow(
                          selected: controller.selectedTrigger.value == ReviewTrigger.programEnd,
                          icon: Iconsax.flag,
                          title: "trigger_program_end".tr,
                          subtitle: "trigger_program_end_subtitle".tr,
                          onTap: () {
                            controller.setSelectedTrigger(ReviewTrigger.programEnd);
                            Navigator.pop(sheetContext);
                          },
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _OptionRow extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionRow({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected ? AppColors.primary.withOpacity(.1) : (isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025)),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, fontSize: 13.5, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                    AppText(subtitle, fontSize: 11, overflow: TextOverflow.ellipsis, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5)),
                  ],
                ),
              ),
              Icon(
                selected ? Iconsax.tick_circle : Iconsax.arrow_circle_right_copy,
                size: 19,
                color: selected ? AppColors.primary : Colors.grey.withOpacity(.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}