import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Rewards/Controllers/RewardsMerchantController.dart';
import 'package:vclub/Features/Merchant/Rewards/View/Widgets/AddRewardSheet.dart';
import 'package:vclub/Features/Merchant/Rewards/View/Widgets/RewardsCard.dart';

class MerchantRewards extends StatefulWidget {
  const MerchantRewards({super.key});

  @override
  State<MerchantRewards> createState() => _MerchantRewardsState();
}

class _MerchantRewardsState extends State<MerchantRewards> {
  final controller = Get.put(RewardsMerchantController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: controller.fetchRewards,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: size.height * 0.01),

                    Align(
                      alignment: isRTL
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FadeSlide(
                        delayMs: 200,
                        child: AppText(
                          "validate_reward".tr,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.01),

                    Align(
                      alignment: isRTL
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: FadeSlide(
                        delayMs: 250,
                        child: AppText(
                          "scan_reward_desc".tr,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(
                            context,
                          ).textTheme.bodySmall?.color?.withOpacity(0.7),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.025),

                    /// ===== SCAN + CODE VALIDATION BAR =====
                    FadeSlide(
                      delayMs: 300,
                      child: ValidateBar(controller: controller, isRTL: isRTL),
                    ),

                    SizedBox(height: size.height * 0.025),

                    /// ===== REWARDS LIST =====
                    FadeSlide(
                      delayMs: 450,
                      child: Obx(() {
                        if (controller.rewardsLoading.value) {
                          return const _RewardsListSkeleton();
                        }

                        if (controller.rewardsError.value.isNotEmpty) {
                          return _ErrorState(
                            message: controller.rewardsError.value,
                            onRetry: controller.fetchRewards,
                          );
                        }

                        if (controller.rewards.isEmpty) {
                          return _EmptyState(isDark: isDark);
                        }

                        return Column(
                          children: controller.rewards
                              .map(
                                (reward) => RewardCard(
                                  key: ValueKey(reward.id),
                                  reward: reward,
                                  controller: controller,
                                ),
                              )
                              .toList(),
                        );
                      }),
                    ),

                    SizedBox(height: size.height * 0.1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────

class ValidateBar extends StatefulWidget {
  final RewardsMerchantController controller;
  final bool isRTL;

  const ValidateBar({super.key, required this.controller, required this.isRTL});

  @override
  State<ValidateBar> createState() => _ValidateBarState();
}

class _ValidateBarState extends State<ValidateBar> {
  bool _isEnteringCode = false;
  final FocusNode _codeFocusNode = FocusNode();

  void _openCodeEntry() {
    setState(() => _isEnteringCode = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _codeFocusNode.requestFocus();
    });
  }

  void _closeCodeEntry() {
    setState(() => _isEnteringCode = false);
    widget.controller.codeController.clear();
    _codeFocusNode.unfocus();
  }

  @override
  void dispose() {
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;
    final isRTL = widget.isRTL;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1).animate(anim),
            child: child,
          ),
        ),
        child: _isEnteringCode
            ? _buildExpandedCodeField(size, isDark, controller, isRTL)
            : _buildActionRow(context, size, isDark, controller, isRTL),
      ),
    );
  }

  // ── COLLAPSED: big "Add" button + 2 small icon buttons ─────
  Widget _buildActionRow(
    BuildContext context,
    Size size,
    bool isDark,
    RewardsMerchantController controller,
    bool isRTL,
  ) {
    final height = size.height * 0.062;

    return Row(
      key: const ValueKey('action_row'),
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      children: [
        /// ADD REWARD — wide, primary, icon + label
        Expanded(
          flex: 3,
          child: _PressableScale(
            onTap: () => showAddRewardSheet(context, controller),
            child: Container(
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.85),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.32),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                children: [
                  const Icon(Iconsax.add_circle, size: 20, color: Colors.white),
                  SizedBox(width: size.width * 0.02),
                  Flexible(
                    child: AppText(
                      "add_reward".tr,
                      fontSize: size.width * 0.036,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: size.width * 0.025),

        /// SCAN QR — small icon-only
        _PressableScale(
          onTap: controller.validateRewardByScan,
          child: Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.22)),
            ),
            alignment: Alignment.center,
            child: Icon(Iconsax.scan, size: 21, color: AppColors.primary),
          ),
        ),

        SizedBox(width: size.width * 0.025),

        /// VALIDATE BY CODE — small icon-only
        _PressableScale(
          onTap: _openCodeEntry,
          child: Container(
            width: height,
            height: height,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withOpacity(0.22)),
            ),
            alignment: Alignment.center,
            child: Icon(
              Iconsax.ticket_star,
              size: 21,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }

  // ── EXPANDED: full-width code field with validate + close ──
  Widget _buildExpandedCodeField(
    Size size,
    bool isDark,
    RewardsMerchantController controller,
    bool isRTL,
  ) {
    final height = size.height * 0.062;

    return Container(
      key: const ValueKey('code_field'),
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(.06)
            : Colors.black.withOpacity(.035),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.10)
              : Colors.black.withOpacity(.08),
        ),
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          SizedBox(width: size.width * 0.04),
          Icon(Iconsax.ticket_discount, size: 19, color: AppColors.primary),
          SizedBox(width: size.width * 0.025),
          Expanded(
            child: TextField(
              controller: controller.codeController,
              focusNode: _codeFocusNode,
              textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
              textAlign: isRTL ? TextAlign.right : TextAlign.left,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                fontSize: size.width * .034,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: "enter_reward_code".tr,
                hintStyle: TextStyle(
                  fontSize: size.width * .034,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? Colors.white.withOpacity(.35)
                      : Colors.black.withOpacity(.35),
                ),
              ),
            ),
          ),

          /// VALIDATE (submit)
          Obx(
            () => GestureDetector(
              onTap: controller.isValidatingCode.value
                  ? null
                  : controller.validateRewardByCode,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: controller.isValidatingCode.value
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.primary,
                        ),
                      )
                    : Icon(
                        Iconsax.tick_circle,
                        size: 22,
                        color: AppColors.primary,
                      ),
              ),
            ),
          ),

          /// CLOSE
          GestureDetector(
            onTap: _closeCodeEntry,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(
                Iconsax.close_circle,
                size: 20,
                color: AppColors.primary.withOpacity(.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Reusable press-scale wrapper
// ─────────────────────────────────────────────────────────────

class _PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _PressableScale({required this.child, required this.onTap});

  @override
  State<_PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<_PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────

class _RewardsListSkeleton extends StatelessWidget {
  const _RewardsListSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.04);

    return Column(
      children: List.generate(
        3,
        (i) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 78,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: [
          const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 34),
          const SizedBox(height: 10),
          AppText(message, fontSize: 13, color: Colors.grey),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: AppText("retry".tr, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  const _EmptyState({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.grey.withOpacity(0.04),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Iconsax.gift,
            size: size.width * 0.09,
            color: isDark
                ? Colors.white.withOpacity(0.15)
                : Colors.black.withOpacity(0.12),
          ),
          SizedBox(height: size.height * 0.012),
          AppText(
            "no_rewards".tr,
            fontSize: size.width * 0.034,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withOpacity(0.30)
                : Colors.black.withOpacity(0.30),
          ),
          SizedBox(height: size.height * 0.005),
          AppText(
            "add_first_reward".tr,
            fontSize: size.width * 0.029,
            color: isDark
                ? Colors.white.withOpacity(0.20)
                : Colors.black.withOpacity(0.20),
          ),
        ],
      ),
    );
  }
}
