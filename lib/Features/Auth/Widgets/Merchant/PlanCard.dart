// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final bool isSelected;
  final bool isPopular;
  final bool isDisabled;
  final String? comingSoonLabel;
  final String? inheritedLabel;
  final VoidCallback? onTap;

  // ── SMS add-on ──
  final bool showSmsOption;
  final bool smsSelected;
  final VoidCallback? onSmsToggle;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
    required this.onTap,
    this.isSelected = false,
    this.isPopular = false,
    this.isDisabled = false,
    this.comingSoonLabel,
    this.inheritedLabel,
    this.showSmsOption = false,
    this.smsSelected = false,
    this.onSmsToggle,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Opacity(
        opacity: isDisabled ? 0.55 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(size.width * 0.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade200,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.black.withOpacity(0.05),
                blurRadius: isSelected ? 20 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Get.locale?.languageCode == 'ar'
                  ? Positioned(
                      top: 10,
                      left: 10,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            BackgroundCircle(
                              size: size.width * 0.3,
                              innerSize: size.width * 0.2,
                            ),
                            BackgroundCircle(
                              size: size.width * 0.1,
                              innerSize: size.width * 0.05,
                            ),
                          ],
                        ),
                      ),
                    )
                  : Positioned(
                      top: 10,
                      right: 10,
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            BackgroundCircle(
                              size: size.width * 0.3,
                              innerSize: size.width * 0.2,
                            ),
                            BackgroundCircle(
                              size: size.width * 0.1,
                              innerSize: size.width * 0.05,
                            ),
                          ],
                        ),
                      ),
                    ),

              Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TOP ROW — Title + Popular/ComingSoon badge
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AppText(
                          title,
                          fontSize: size.width * 0.045,
                          fontWeight: FontWeight.w700,
                          color: isDisabled ? Colors.grey : AppColors.primary,
                        ),
                        // if (isDisabled && comingSoonLabel != null) ...[
                        //   SizedBox(width: size.width * 0.03),
                        //   Container(
                        //     padding: EdgeInsets.symmetric(
                        //       horizontal: size.width * 0.03,
                        //       vertical: size.height * 0.004,
                        //     ),
                        //     decoration: BoxDecoration(
                        //       color: Colors.grey.withOpacity(0.15),
                        //       borderRadius: BorderRadius.circular(20),
                        //       border: Border.all(
                        //         color: Colors.grey.shade400,
                        //         width: 1.2,
                        //       ),
                        //     ),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.min,
                        //       children: [
                        //         Icon(Iconsax.clock, size: size.width * 0.03, color: Colors.grey.shade600),
                        //         SizedBox(width: size.width * 0.012),
                        //         AppText(
                        //           comingSoonLabel!.toUpperCase(),
                        //           translate: false,
                        //           fontSize: size.width * 0.026,
                        //           color: Colors.grey.shade600,
                        //           fontWeight: FontWeight.w700,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ] else
                        if (isPopular) ...[
                          SizedBox(width: size.width * 0.03),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03,
                              vertical: size.height * 0.004,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 1.5,
                              ),
                            ),
                            child: AppText(
                              "popular".tr.toUpperCase(),
                              translate: false,
                              fontSize: size.width * 0.028,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: size.height * 0.012),

                    /// PRICE
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AppText(
                          price,
                          fontSize: size.width * 0.1,
                          fontWeight: FontWeight.w800,
                          color: isDisabled
                              ? Colors.grey
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        if (duration.isNotEmpty) ...[
                          SizedBox(width: 6),
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: size.height * 0.008,
                            ),
                            child: AppText(
                              "/ $duration",
                              fontSize: size.width * 0.032,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: size.height * 0.018),

                    /// SPARKLE DIVIDER
                    _SparkDivider(
                      color: isDisabled ? Colors.grey : AppColors.primary,
                    ),

                    SizedBox(height: size.height * 0.018),
                    if (inheritedLabel != null) ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: size.width * 0.035,
                          vertical: size.height * 0.011,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              AppColors.primary.withOpacity(0.12),
                              AppColors.primary.withOpacity(0.04),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.18),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Iconsax.magic_star_copy,
                              size: size.width * 0.038,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: size.width * 0.02),
                            Expanded(
                              child: AppText(
                                inheritedLabel!,
                                fontSize: size.width * 0.032,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                    ],

                    /// FEATURES
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: features.map((f) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.02),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _TealCheckBadge(
                                size: size.width * 0.055,
                                color: isDisabled
                                    ? Colors.grey
                                    : AppColors.primary,
                              ),
                              SizedBox(width: size.width * 0.03),
                              Expanded(
                                child: AppText(
                                  f,
                                  fontSize: size.width * 0.036,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                     if (showSmsOption) ...[
  SizedBox(height: size.height * 0.008),
  _InlineSmsOption(
    isPlanSelected: isSelected,
    isSmsSelected: smsSelected,
    onTap: (isSelected && !isDisabled) ? onSmsToggle : null,
    size: size,
  ),
],
                    SizedBox(height: size.height * 0.02),

                    /// SELECT BUTTON
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: size.height * 0.016,
                      ),
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? Colors.grey.withOpacity(0.15)
                            : (isSelected
                                  ? AppColors.primary
                                  : AppColors.primary.withOpacity(0.08)),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Center(
                        child: AppText(
                          isDisabled
                              ? (comingSoonLabel ?? "coming_soon".tr)
                              : (isSelected ? "selected".tr : "select_plan".tr),
                          fontSize: size.width * 0.038,
                          fontWeight: FontWeight.w600,
                          color: isDisabled
                              ? Colors.grey.shade600
                              : (isSelected ? Colors.white : AppColors.primary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// SELECTED CHECKMARK — top right corner
              if (isSelected && !isDisabled)
                Get.locale?.languageCode == 'ar'
                    ? Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          width: size.width * 0.07,
                          height: size.width * 0.07,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: size.width * 0.045,
                          ),
                        ),
                      )
                    : Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: size.width * 0.07,
                          height: size.width * 0.07,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: size.width * 0.045,
                          ),
                        ),
                      ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Teal hexagonal / badge check icon matching the screenshots
class _TealCheckBadge extends StatelessWidget {
  final double size;
  final Color color;
  const _TealCheckBadge({required this.size, this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) {
    return Icon(Iconsax.verify, color: color, size: size * 1);
  }
}

/// Horizontal divider with a sparkle ✦ in the centre
class _SparkDivider extends StatelessWidget {
  final Color color;
  const _SparkDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color.withOpacity(0.25), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.auto_awesome, size: 16, color: color),
        ),
        Expanded(child: Divider(color: color.withOpacity(0.25), thickness: 1)),
      ],
    );
  }
}

/// Compact SMS add-on toggle embedded inside a plan card. Only
/// interactive when its parent plan is the currently selected one —
/// otherwise shown dimmed/locked, since the add-on only applies to
/// whichever plan the merchant actually picks.
class _InlineSmsOption extends StatelessWidget {
  final bool isPlanSelected;
  final bool isSmsSelected;
  final VoidCallback? onTap;
  final Size size;

  const _InlineSmsOption({
    required this.isPlanSelected,
    required this.isSmsSelected,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final active = isPlanSelected && isSmsSelected;
    final interactive = isPlanSelected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.only(bottom: size.height * 0.014),
        padding: EdgeInsets.all(size.width * 0.033),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: active
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.16),
                    AppColors.primary.withOpacity(0.05),
                  ],
                )
              : null,
          color: active
              ? null
              : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.025)),
          border: Border.all(
            color: active ? AppColors.primary.withOpacity(0.5) : Colors.transparent,
            width: 1.3,
          ),
        ),
        child: Opacity(
          opacity: interactive ? 1 : 0.45,
          child: Row(
            children: [
              Container(
                width: size.width * 0.09,
                height: size.width * 0.09,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(11),
                  gradient: active
                      ? LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.7)],
                        )
                      : null,
                  color: active ? null : Colors.grey.withOpacity(0.18),
                ),
                child: Icon(
                  Iconsax.sms_notification,
                  size: size.width * 0.042,
                  color: active ? Colors.white : Colors.grey.shade600,
                ),
              ),
              SizedBox(width: size.width * 0.026),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: AppText(
                            "sms_addon_title".tr,
                            fontSize: size.width * 0.033,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppText(
                          "sms_addon_price".tr,
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.w700,
                          color: active ? AppColors.primary : Colors.grey.shade600,
                        ),
                      ],
                    ),
                    if (!interactive) ...[
                      SizedBox(height: size.height * 0.003),
                      AppText(
                        "sms_addon_locked_hint".tr,
                        fontSize: size.width * 0.026,
                        color: Colors.grey.shade500,
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(width: size.width * 0.02),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: size.width * 0.055,
                height: size.width * 0.055,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: active ? AppColors.primary : Colors.grey.shade400,
                    width: 1.4,
                  ),
                ),
                child: active
                    ? Icon(Icons.check, size: size.width * 0.036, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
