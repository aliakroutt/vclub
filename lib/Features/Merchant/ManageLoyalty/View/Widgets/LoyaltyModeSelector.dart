import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';

class LoyaltyModeSelector extends StatelessWidget {
  LoyaltyModeSelector({super.key});

  final controller = Get.put(LoyaltyModeController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final modes = [
      {
        "mode": LoyaltyMode.points,
        "title": "points_mode".tr,
        "subtitle": "points_mode_subtitle".tr,
        "icon": Iconsax.coin_1,
        "color": const Color(0xFF6C5CE7),
      },
      {
        "mode": LoyaltyMode.stamps,
        "title": "stamps_mode".tr,
        "subtitle": "stamps_mode_subtitle".tr,
        "icon": Iconsax.ticket_discount,
        "color": const Color(0xFF00B894),
      },
      {
        "mode": LoyaltyMode.cashback,
        "title": "cashback_mode".tr,
        "subtitle": "cashback_mode_subtitle".tr,
        "icon": Iconsax.wallet_money,
        "color": const Color(0xFFFFB020),
      },
    ];

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
          /// ── HEADER ────────────────────────────────────────────
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
                  Iconsax.crown,
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
                      "loyalty_mode".tr,
                      fontSize: size.width * 0.042,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "loyalty_mode_description".tr,
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

          /// ── DIVIDER ───────────────────────────────────────────
          Divider(
            height: 1,
            thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),

          SizedBox(height: size.height * 0.018),

          /// ── MODE CARDS ────────────────────────────────────────
          Obx(
            () => Column(
              children: modes.map((item) {
                final isSelected =
                    controller.selectedMode.value == item["mode"];
                final color = item["color"] as Color;
                final isLast = item == modes.last;

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? 0 : size.height * 0.012,
                  ),
                  child: GestureDetector(
                    onTap: () =>
                        controller.selectMode(item["mode"] as LoyaltyMode),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.016,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isSelected
                            ? color.withOpacity(isDark ? 0.12 : 0.07)
                            : isDark
                                ? Colors.white.withOpacity(0.03)
                                : Colors.grey.withOpacity(0.04),
                        border: Border.all(
                          color: isSelected
                              ? color.withOpacity(0.45)
                              : isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : Colors.black.withOpacity(0.05),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          /// ICON
                          Container(
                            width: size.width * 0.108,
                            height: size.width * 0.108,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(13),
                              color: color.withOpacity(0.10),
                            ),
                            child: Icon(
                              item["icon"] as IconData,
                              color: color,
                              size: size.width * 0.052,
                            ),
                          ),

                          SizedBox(width: size.width * 0.038),

                          /// TITLE + SUBTITLE
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppText(
                                  item["title"].toString(),
                                  fontSize: size.width * 0.037,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? color : null,
                                ),
                                const SizedBox(height: 3),
                                AppText(
                                  item["subtitle"].toString(),
                                  fontSize: size.width * 0.029,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.50),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: size.width * 0.03),

                          /// RADIO
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? color
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? color
                                    : isDark
                                        ? Colors.white.withOpacity(0.20)
                                        : Colors.black.withOpacity(0.15),
                                width: 1.5,
                              ),
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}