import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';


class ParticipationLimitsCard extends StatelessWidget {
  ParticipationLimitsCard({super.key});

  final _c = Get.find<FortuneController>();

  

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF18181B) : Colors.white,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
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
          /// ── HEADER ─────────────────────────────
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
                  Iconsax.calendar_tick,
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
                      "participation_limits".tr,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "participation_limits_subtitle".tr,
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

          SizedBox(height: size.height * 0.02),

          /// ── MAX PER DAY ─────────────────────────
          _LimitField(
            size: size,
            isDark: isDark,
            title: "max_per_day".tr,
            controller: _c.maxPerDayController,
            hint: "0",
            icon: Iconsax.sun_1,
          ),

          SizedBox(height: size.height * 0.015),

          /// ── MAX PER WEEK ────────────────────────
          _LimitField(
            size: size,
            isDark: isDark,
            title: "max_per_week".tr,
            controller: _c.maxPerWeekController,
            hint: "0",
            icon: Iconsax.calendar_1,
          ),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// FIELD WIDGET
/// ─────────────────────────────────────────────
class _LimitField extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Size size;
  final bool isDark;

  const _LimitField({
    required this.title,
    required this.controller,
    required this.hint,
    required this.icon,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// ── LABEL (TOP) ─────────────────────────────
        AppText(
          title,
          fontSize: size.width * 0.034,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),

        SizedBox(height: size.height * 0.015),

        /// ── ICON + FIELD (CENTER ROW) ───────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// icon
            Container(
              width: size.width * 0.10,
              height: size.width * 0.10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AppColors.primary.withOpacity(0.10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: size.width * 0.045,
              ),
            ),

            SizedBox(width: size.width * 0.03),

            /// input (center aligned vertically with icon)
            Expanded(
              child: SizedBox(
                height: size.width * 0.105,
                child: Center(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                    decoration: InputDecoration(
                      hintText: hint,
                      filled: true,
                      fillColor: AppColors.primary.withOpacity(0.07),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.20),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                          color: AppColors.primary.withOpacity(0.50),
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}