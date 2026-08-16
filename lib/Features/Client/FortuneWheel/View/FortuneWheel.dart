import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/FortuneWheel/Controllers/FortuneWheelController.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/CompanySelectorRow.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/FortuneWheelShimmer.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/HistoryHeaderButton.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/SpinWheelWidget.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/WheelCard.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/Widgets/WheelResultDialog.dart';

class FortuenWheel extends StatefulWidget {
  const FortuenWheel({super.key});

  @override
  State<FortuenWheel> createState() => _FortuenWheelState();
}

class _FortuenWheelState extends State<FortuenWheel> {
  final GlobalKey<SpinWheelWidgetState> _wheelKey = GlobalKey<SpinWheelWidgetState>();
  bool _isSpinning = false;
  Completer<void>? _animCompleter;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<FortuneWheelController>()) {
      Get.put(FortuneWheelController());
    }
    Get.find<FortuneWheelController>().fetchAll();
  }

  void _onSpinAnimationComplete() {
    _animCompleter?.complete();
  }

  Future<void> _handleSpin() async {
    if (_isSpinning) return;

    final controller = Get.find<FortuneWheelController>();
    final wheel = controller.wheel.value;
    if (wheel == null || !wheel.canSpin) return;

    setState(() => _isSpinning = true);

    // 1. Call API FIRST — wheel is completely still, button shows a loader.
    final result = await controller.spin();

    if (result != null) {
      _animCompleter = Completer<void>();

      // 2. Trigger the spin with the CONFIRMED winning index — the
      //    package guarantees it lands exactly there.
      _wheelKey.currentState?.spinToIndex(result.segmentIndex);

      // 3. Wait for the package's own animation-end callback — real
      //    completion signal, not a guessed delay.
      await _animCompleter!.future;

      // 4. Dialog + background refresh, together, only after landing.
      if (mounted) {
        unawaited(controller.refresh());
        await showWheelResultDialog(context, result);
      }
    }

    if (mounted) setState(() => _isSpinning = false);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FortuneWheelController>();
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          FadeSlide(delayMs: 150, child: AppText('fortune_wheel'.tr, fontSize: 20, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          FadeSlide(
                            delayMs: 200,
                            child: AppText(
                              "fortune_wheel_subtitle".tr,
                              fontSize: 12.5,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FadeSlide(delayMs: 220, child: const HistoryHeaderButton()),
                  ],
                ),

                SizedBox(height: size.height * 0.02),

                Obx(() {
                  if (controller.loadingCompanies.value && !controller.initialLoaded.value) {
                    return FortuneWheelShimmer(wheelSize: size.width * .78);
                  }
                  if (controller.hasError.value && controller.companies.isEmpty) {
                    return _ErrorBlock(onRetry: controller.refresh);
                  }
                  if (controller.companies.isEmpty) {
                    return _EmptyBlock();
                  }
                  return const SizedBox.shrink();
                }),

                Obx(() {
                  if (controller.companies.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FadeSlide(delayMs: 230, child: _StatsRow(controller: controller)),
                      SizedBox(height: size.height * 0.022),
                      FadeSlide(delayMs: 260, child: const CompanySelectorRow()),
                      SizedBox(height: size.height * 0.03),
                    ],
                  );
                }),

                Obx(() {
                  if (controller.companies.isEmpty) return const SizedBox.shrink();

                  return FadeSlide(
                    delayMs: 300,
                    child: WheelCard(
                      wheelKey: _wheelKey,
                      isSpinning: _isSpinning,
                      onSpin: _handleSpin,
                      onSpinAnimationComplete: _onSpinAnimationComplete,
                    ),
                  );
                }),

                SizedBox(height: size.height * 0.15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final FortuneWheelController controller;
  const _StatsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Obx(() => _StatCard(icon: Iconsax.cup, label: "total_wins_label".tr, value: "${controller.totalWins}", color: const Color(0xFFFFB930)))),
        const SizedBox(width: 10),
        Expanded(child: Obx(() => _StatCard(icon: Iconsax.shop, label: "companies_joined_label".tr, value: "${controller.availableCompaniesCount}", color: AppColors.primary))),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(isDark ? .18 : .04), blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(9)),
            child: Icon(icon, size: 15, color: color),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(value, fontSize: 15.5, fontWeight: FontWeight.w800, height: 1.1),
                AppText(label, fontSize: 10, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyBlock extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Iconsax.gift, size: 40, color: AppColors.primary.withOpacity(.5)),
            const SizedBox(height: 14),
            AppText("no_companies_joined".tr, fontSize: 14, fontWeight: FontWeight.w700),
            const SizedBox(height: 6),
            AppText("no_companies_joined_subtitle".tr, fontSize: 12, color: Colors.grey, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _ErrorBlock extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorBlock({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            const Icon(Iconsax.warning_2, size: 36, color: Colors.redAccent),
            const SizedBox(height: 12),
            AppText("failed_load_data".tr, fontSize: 13),
            const SizedBox(height: 12),
            InkWell(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(.1), borderRadius: BorderRadius.circular(12)),
                child: AppText("retry".tr, color: Colors.redAccent, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}