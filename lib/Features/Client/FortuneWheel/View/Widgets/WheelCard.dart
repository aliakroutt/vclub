import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/FortuneWheel/Controllers/FortuneWheelController.dart';
import 'SegmentChipsRow.dart';
import 'SpinWheelWidget.dart';

class WheelCard extends StatelessWidget {
  final GlobalKey<SpinWheelWidgetState> wheelKey;
  final bool isSpinning;
  final VoidCallback onSpin;
  final VoidCallback onSpinAnimationComplete;

  const WheelCard({
    super.key,
    required this.wheelKey,
    required this.isSpinning,
    required this.onSpin,
    required this.onSpinAnimationComplete,
  });

  ImageProvider? _decodeLogo(String? logo) {
    if (logo == null || logo.isEmpty) return null;
    try {
      final b64 = logo.contains(',') ? logo.split(',').last : logo;
      return MemoryImage(base64Decode(b64));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FortuneWheelController>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF1C1F26), const Color(0xFF16181D)]
              : [Colors.white, const Color(0xFFFAFAFF)],
        ),
        border: Border.all(color: AppColors.primary.withOpacity(isDark ? .16 : .1)),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withOpacity(isDark ? .1 : .08), blurRadius: 30, offset: const Offset(0, 14)),
          BoxShadow(color: Colors.black.withOpacity(isDark ? .25 : .04), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          // ── HEADER ──
          Obx(() {
            final company = controller.selectedCompany.value;
            final wheel = controller.wheel.value;
            final logo = _decodeLogo(company?.companyLogo);
            final canSpin = wheel?.canSpin ?? false;

            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
              ),
              child: Row(
                children: [
                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: logo == null
                          ? LinearGradient(colors: [AppColors.primary.withOpacity(.2), AppColors.primary.withOpacity(.06)])
                          : null,
                      image: logo != null ? DecorationImage(image: logo, fit: BoxFit.cover) : null,
                      border: Border.all(color: AppColors.primary.withOpacity(.22), width: 1.2),
                    ),
                    child: logo == null
                        ? Center(
                            child: AppText(
                              (company?.companyName.isNotEmpty ?? false) ? company!.companyName[0].toUpperCase() : "?",
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: AppText(
                      company?.companyName.isNotEmpty == true ? company!.companyName : "—",
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (wheel != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: (canSpin ? const Color(0xFF00C896) : Colors.grey).withOpacity(.12),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: (canSpin ? const Color(0xFF00C896) : Colors.grey).withOpacity(.28)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            height: 5,
                            width: 5,
                            decoration: BoxDecoration(shape: BoxShape.circle, color: canSpin ? const Color(0xFF00C896) : Colors.grey),
                          ),
                          const SizedBox(width: 4),
                          AppText(
                            canSpin ? "wheel_available".tr : "wheel_not_available".tr,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: canSpin ? const Color(0xFF00C896) : Colors.grey,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // ── WHEEL ──
          Obx(() {
            final wheel = controller.wheel.value;

            if (controller.loadingWheel.value) {
              return SizedBox(height: size.width * .62, width: size.width * .62, child: const _WheelShimmerCircle());
            }

            if (wheel == null || wheel.segments.isEmpty) {
              return SizedBox(
                height: size.width * .5,
                child: Center(child: AppText("wheel_unavailable".tr, fontSize: 12.5, color: Colors.grey)),
              );
            }

            return SpinWheelWidget(
              key: wheelKey,
              segments: wheel.segments,
              size: size.width * .62,
              onSpinComplete: onSpinAnimationComplete,
            );
          }),

          // ── CHIPS ──
          Obx(() {
            final wheel = controller.wheel.value;
            if (wheel == null || wheel.segments.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 18),
              child: SegmentChipsRow(segments: wheel.segments),
            );
          }),

          const SizedBox(height: 20),

          // ── SPIN BUTTON ──
          Obx(() {
            final wheel = controller.wheel.value;
            if (wheel == null) return const SizedBox.shrink();
            final canSpin = wheel.canSpin;

            return SizedBox(
              width: double.infinity,
              height: 44,
              child: Material(
                color: canSpin ? AppColors.primary : Colors.grey.withOpacity(.3),
                borderRadius: BorderRadius.circular(13),
                child: InkWell(
                  borderRadius: BorderRadius.circular(13),
                  onTap: canSpin && !isSpinning ? onSpin : null,
                  child: Center(
                    child: isSpinning
                        ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 20)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.gift, size: 15, color: Colors.white),
                              const SizedBox(width: 7),
                              AppText(
                                canSpin ? "spin_now".tr : "no_spins_left".tr,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _WheelShimmerCircle extends StatelessWidget {
  const _WheelShimmerCircle();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(shape: BoxShape.circle, color: (isDark ? Colors.white : Colors.black).withOpacity(.06)),
    );
  }
}