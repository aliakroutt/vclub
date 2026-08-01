// Features/Merchant/FortuneWheel/View/FortuneWheelHome.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelHistoryController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelHomeController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/FortuneSegmentModel.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/FortuneWheelConfig.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/HistoryTab.dart';

class FortuneWheelHome extends StatefulWidget {
  const FortuneWheelHome({super.key});

  @override
  State<FortuneWheelHome> createState() => _FortuneWheelHomeState();
}

class _FortuneWheelHomeState extends State<FortuneWheelHome> {
  final controller = Get.put(FortuneWheelHomeController());
  final historycontroller = Get.put(FortuneWheelHistoryController());
  int _tabIndex = 0;

  @override
  void initState() {
    controller.fetchWheelConfig();
    historycontroller.fetchHistory();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: isDark
            ? Theme.of(context).scaffoldBackgroundColor
            : const Color(0xFFF6F7FB),
        body: SafeArea(
          child: Obx(() {
            if (controller.loading.value && !controller.initialLoaded.value) {
              return _buildLoadingSkeleton(size, isDark);
            }

            if (controller.error.value.isNotEmpty &&
                controller.config.value == null) {
              return _buildErrorState();
            }

            final config = controller.config.value;
            final configured = config != null && config.isConfigured;

            if (!configured) {
              return _buildNotConfigured(size, isDark);
            }

            return _buildConfiguredView(size, isDark, config);
          }),
        ),
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(Size size, bool isDark, {required bool configured}) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.65),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Icon(Iconsax.gift, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                "fortune_wheel",
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
              const SizedBox(height: 2),
              AppText(
                configured
                    ? "wheel_header_subtitle_active"
                    : "wheel_header_subtitle_setup",
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- NOT CONFIGURED ----------------
  Widget _buildNotConfigured(Size size, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),
          FadeSlide(
            delayMs: 100,
            child: _buildHeader(size, isDark, configured: false),
          ),
          SizedBox(height: size.height * 0.05),
          FadeSlide(
            delayMs: 250,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.06),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.16),
                          AppColors.primary.withValues(alpha: 0.05),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Iconsax.gift,
                      size: 46,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppText(
                    "wheel_not_configured_title",
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  AppText(
                    "wheel_not_configured_subtitle",
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    textAlign: TextAlign.center,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 22),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _MiniPerk(icon: Iconsax.star, labelKey: "perk_points"),
                      _MiniPerk(
                        icon: Iconsax.discount_shape,
                        labelKey: "perk_discounts",
                      ),
                      _MiniPerk(
                        icon: Iconsax.wallet_money,
                        labelKey: "perk_cashback",
                      ),
                      _MiniPerk(icon: Iconsax.gift, labelKey: "perk_gifts"),
                    ],
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.064,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.75),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () async {
                            //  final result = await Get.to(() => const FortuneWheelConfig());
                            AppNavigator.to(FortuneWheelConfig(isEdit: false));
                            controller.refresh();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.setting_2,
                                size: 20,
                                color: Colors.white,
                              ),
                              SizedBox(width: size.width * 0.025),
                              AppText(
                                "configure_now",
                                fontSize: size.width * 0.038,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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
          SizedBox(height: size.height * 0.04),
        ],
      ),
    );
  }

  // ---------------- CONFIGURED (TABS) ----------------
  Widget _buildConfiguredView(
    Size size,
    bool isDark,
    FortuneWheelConfigModel config,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.01),
          FadeSlide(
            delayMs: 100,
            child: _buildHeader(size, isDark, configured: true),
          ),
          SizedBox(height: size.height * 0.016),
          FadeSlide(delayMs: 160, child: _buildStatsRow(config, isDark)),
          SizedBox(height: size.height * 0.02),
          FadeSlide(delayMs: 200, child: _buildTabBar(isDark)),
          SizedBox(height: size.height * 0.018),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _tabIndex == 0
                  ? _buildWheelTab(size, isDark, config)
                  :  HistoryTab(key: const ValueKey('history'),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  // The "active/inactive" pill was removed — status now only lives as the
  // badge inside the wheel preview card. The trailing empty `Expanded` keeps
  // the two remaining pills at the exact same width they had when there were
  // three of them, instead of letting them stretch to fill the freed space.
  Widget _buildStatsRow(FortuneWheelConfigModel config, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _StatPill(
            icon: Iconsax.chart_21,
            iconColor: AppColors.primary,
            labelKey: "segments_count",
            valueText: "${config.segments.length}",
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatPill(
            icon: Iconsax.calendar_1,
            iconColor: const Color(0xFFE08A2B),
            labelKey: "max_per_day_home",
            valueText: "${config.maxPerDay}",
            isDark: isDark,
          ),
        ),
        // const SizedBox(width: 8),
        // const Expanded(child: SizedBox()),
      ],
    );
  }

  Widget _buildTabBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabItem(0, 'wheel_tab', Iconsax.gift),
          _tabItem(1, 'history_tab', Iconsax.clock),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String key, IconData icon) {
    final selected = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withValues(alpha: 0.8),
                    ],
                  )
                : null,
            color: selected ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? Colors.white
                    : Theme.of(context).iconTheme.color?.withValues(alpha: 0.6),
              ),
              const SizedBox(width: 6),
              AppText(
                key,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : Theme.of(
                        context,
                      ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- WHEEL TAB ----------------
  Widget _buildWheelTab(
    Size size,
    bool isDark,
    FortuneWheelConfigModel config,
  ) {
    return SingleChildScrollView(
      key: const ValueKey('wheel'),
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          FadeSlide(
            delayMs: 250,
            child: _WheelSummaryCard(config: config, isDark: isDark),
          ),
          SizedBox(height: size.height * 0.02),
          FadeSlide(
            delayMs: 300,
            child: SizedBox(
              width: double.infinity,
              height: size.height * 0.062,
              child: OutlinedButton(
                onPressed: () async {
                  AppNavigator.to(FortuneWheelConfig(isEdit: true));
                  controller.refresh();
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primary, width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  backgroundColor: AppColors.primary,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.edit_copy, size: 20, color: Colors.white),
                    SizedBox(width: size.width * 0.025),
                    AppText(
                      "update_configuration",
                      fontSize: size.width * 0.038,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: size.height * 0.15),
        ],
      ),
    );
  }
  // ---------------- LOADING / MODERN SHIMMER ----------------
  Widget _buildLoadingSkeleton(Size size, bool isDark) {
    final base = isDark
        ? Colors.white.withValues(alpha: 0.07)
        : Colors.black.withValues(alpha: 0.055);
    final highlight = isDark
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.11);
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.05);

    Widget block({double? width, required double height, double radius = 10}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    Widget cardShell({required Widget child, EdgeInsets? padding}) {
      return Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cardBorder),
        ),
        child: child,
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: size.height * 0.02),

          // header row: icon avatar + title + subtitle
          Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            period: const Duration(milliseconds: 1500),
            child: Row(
              children: [
                block(width: 46, height: 46, radius: 16),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      block(width: size.width * 0.34, height: 18, radius: 6),
                      const SizedBox(height: 7),
                      block(width: size.width * 0.48, height: 12, radius: 6),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.02),

          // stats row — only 2 real pills now, third slot stays empty to match
          Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            period: const Duration(milliseconds: 1500),
            child: Row(
              children: [
                ...List.generate(2, (i) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: cardBorder),
                        ),
                        child: Row(
                          children: [
                            block(width: 28, height: 28, radius: 8),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  block(width: 26, height: 12, radius: 4),
                                  const SizedBox(height: 5),
                                  block(width: 36, height: 8, radius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const Expanded(child: SizedBox()),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.024),

          // tab bar
          Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            period: const Duration(milliseconds: 1500),
            child: block(height: 48, radius: 14, width: double.infinity),
          ),
          SizedBox(height: size.height * 0.024),

          // summary card
          cardShell(
            child: Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              period: const Duration(milliseconds: 1500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      block(width: 110, height: 15, radius: 6),
                      block(width: 64, height: 20, radius: 20),
                    ],
                  ),
                  SizedBox(height: size.height * 0.03),

                  // wheel circle with a faux rim ring
                  Center(
                    child: Container(
                      width: size.width * 0.46,
                      height: size.width * 0.46,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: base, width: 2),
                      ),
                      child: ClipOval(
                        child: block(
                          height: double.infinity,
                          width: double.infinity,
                          radius: 999,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),

                  // quick stats row (max/day, max/week, active hours)
                  Row(
                    children: List.generate(3, (i) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: i == 2 ? 0 : 8),
                          child: block(height: 62, radius: 14),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 18),

                  block(width: 90, height: 12, radius: 5),
                  const SizedBox(height: 12),

                  // segment cards — left accent bar + icon badge + label + probability pill
                  ...List.generate(3, (i) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.03)
                            : Colors.black.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(14),
                        border: Border(left: BorderSide(color: base, width: 3)),
                      ),
                      child: Row(
                        children: [
                          block(width: 29, height: 29, radius: 9),
                          const SizedBox(width: 10),
                          Expanded(child: block(height: 12, radius: 6)),
                          const SizedBox(width: 12),
                          block(width: 34, height: 20, radius: 8),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          SizedBox(height: size.height * 0.022),

          Shimmer.fromColors(
            baseColor: base,
            highlightColor: highlight,
            period: const Duration(milliseconds: 1500),
            child: block(
              height: size.height * 0.062,
              radius: 16,
              width: double.infinity,
            ),
          ),
          SizedBox(height: size.height * 0.05),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: isDark ? 0.14 : 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.warning_2,
                size: 40,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 18),
            AppText(
              "failed_load_wheel_config",
              fontSize: 15,
              fontWeight: FontWeight.w700,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            AppText(
              "failed_load_wheel_config_subtitle",
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              textAlign: TextAlign.center,
              color: Theme.of(
                context,
              ).textTheme.bodySmall?.color?.withValues(alpha: 0.55),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: () => controller.refresh(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.refresh, size: 16, color: Colors.white),
                    const SizedBox(width: 8),
                    AppText(
                      "retry",
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== SUB-WIDGETS ====================

class _MiniPerk extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  const _MiniPerk({required this.icon, required this.labelKey});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          AppText(labelKey, fontSize: 11.5, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }
}

// Compact stat pill: fixed height so every card in the row is identical,
// with a horizontal icon + 1-2 line text layout instead of a tall stacked column.
class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String labelKey;
  final String? valueText;
  final bool isDark;
  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.labelKey,
    required this.valueText,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: iconColor),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: valueText != null
                  ? [
                      Text(
                        valueText!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 1),
                      AppText(
                        labelKey,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withValues(alpha: 0.55),
                      ),
                    ]
                  : [
                      AppText(
                        labelKey,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: iconColor,
                      ),
                    ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- WHEEL SUMMARY CARD (now shows everything about the wheel) ----------------
class _WheelSummaryCard extends StatelessWidget {
  final FortuneWheelConfigModel config;
  final bool isDark;
  const _WheelSummaryCard({required this.config, required this.isDark});

  // String get _activeHoursText => config.activeHoursEnabled
  //     ? '${config.activeHoursStart} - ${config.activeHoursEnd}'
  //     : 'active_hours_always'.tr;

  IconData _triggerIcon(String trigger) {
    switch (trigger) {
      case 'inscription':
        return Iconsax.user_add;
      case 'purchase':
        return Iconsax.shopping_cart;
      case 'event':
        return Iconsax.calendar_1;
      case 'google_review':
        return Iconsax.star_1;
      default:
        return Iconsax.flag;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardColor = Theme.of(context).cardColor;
    final subtitleColor = Theme.of(
      context,
    ).textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.05),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                "wheel_preview",
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
              _StatusBadge(active: config.active),
            ],
          ),
          const SizedBox(height: 26),

          // ---- wheel graphic — painter now draws title + percent per slice ----
          Center(
            child: SizedBox(
              height: size.width * 0.52,
              width: size.width * 0.52,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // ambient premium glow behind the wheel
                  Container(
                    width: size.width * 0.5,
                    height: size.width * 0.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary.withValues(
                            alpha: isDark ? 0.28 : 0.16,
                          ),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(
                            alpha: isDark ? 0.4 : 0.14,
                          ),
                          blurRadius: 26,
                          offset: const Offset(0, 12),
                        ),
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: isDark ? 0.25 : 0.15,
                          ),
                          blurRadius: 30,
                          spreadRadius: -6,
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      size: Size(size.width * 0.44, size.width * 0.44),
                      painter: _MiniWheelPainter(
                        segments: config.segments,
                        holeColor: cardColor,
                        primaryColor: AppColors.primary,
                      ),
                    ),
                  ),
                  // premium gradient pointer
                  Positioned(
                    top: 0,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withValues(alpha: 0.7),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: cardColor, width: 2),
                      ),
                      child: const Icon(
                        Iconsax.arrow_down_1_copy,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 26),

          // ---- quick stats: max/day, max/week, active hours ----
          Column(
            children: [
              _QuickStat(
                icon: Iconsax.calendar_1,
                color: const Color(0xFFE08A2B),
                labelKey: "max_per_day",
                value: "${config.maxPerDay}",
              ),

              const SizedBox(height: 10),

              _QuickStat(
                icon: Iconsax.calendar_2,
                color: const Color(0xFF6E56CF),
                labelKey: "max_per_week",
                value: "${config.maxPerWeek}",
              ),
            ],
          ),

          // ---- triggers ----
          if (config.triggers.isNotEmpty) ...[
            const SizedBox(height: 22),
            AppText(
              "triggers",
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: subtitleColor,
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: config.triggers
                  .map(
                    (t) => _TriggerChip(
                      icon: _triggerIcon(t),
                      labelKey: "trigger_$t",
                      isDark: isDark,
                    ),
                  )
                  .toList(),
            ),
          ],

          const SizedBox(height: 22),
          AppText(
            "segments_label",
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: subtitleColor,
          ),
          const SizedBox(height: 10),
          ...config.segments.map(
            (s) => _SegmentCard(segment: s, isDark: isDark),
          ),
        ],
      ),
    );
  }
}

// small stat block used for max/day, max/week, active hours
class _QuickStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String labelKey;
  final String value;

  const _QuickStat({
    required this.icon,
    required this.color,
    required this.labelKey,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtitleColor = Theme.of(
      context,
    ).textTheme.bodySmall?.color?.withValues(alpha: .55);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: .04)
            : Colors.black.withValues(alpha: .025),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 16, color: color),
          ),

          SizedBox(width: 10),

          AppText(labelKey, fontSize: 11.5, fontWeight: FontWeight.w600),
          Spacer(),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// chip used for each trigger (inscription, purchase, event, google_review...)
class _TriggerChip extends StatelessWidget {
  final IconData icon;
  final String labelKey;
  final bool isDark;
  const _TriggerChip({
    required this.icon,
    required this.labelKey,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.primary),
          const SizedBox(width: 6),
          AppText(labelKey, fontSize: 11, fontWeight: FontWeight.w700),
        ],
      ),
    );
  }
}

class _SegmentCard extends StatelessWidget {
  final FortuneSegmentModel segment;
  final bool isDark;
  const _SegmentCard({required this.segment, required this.isDark});

  IconData get _typeIcon {
    switch (segment.type) {
      case 'discount':
        return Iconsax.discount_shape;
      case 'points':
        return Iconsax.star;
      case 'cashback':
        return Iconsax.wallet_money;
      default:
        return Iconsax.gift;
    }
  }

  @override
  Widget build(BuildContext context) {
    // segment.label/value come straight from the backend — plain Text,
    // never AppText/.tr, since they're not translation keys.
    final subtitleColor = Theme.of(
      context,
    ).textTheme.bodySmall?.color?.withValues(alpha: 0.55);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.025),
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: segment.color, width: 3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: segment.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(_typeIcon, size: 15, color: segment.color),
          ),
          const SizedBox(width: 10),
          Text(
            segment.label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "${segment.probability}%",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool active;
  const _StatusBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xFF06A247) : const Color(0xFF9E9E9E);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          AppText(
            active ? "active" : "inactive",
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

// Premium wheel painter: gradient-filled segments, a sweeping metallic rim,
// small "bulb" markers around the circumference, a glossy center hub, and
// — new — each segment's title + percentage rendered directly on the slice.
class _MiniWheelPainter extends CustomPainter {
  final List<FortuneSegmentModel> segments;
  final Color holeColor;
  final Color primaryColor;
  _MiniWheelPainter({
    required this.segments,
    required this.holeColor,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = segments.fold<int>(0, (sum, s) => sum + s.probability);
    if (total == 0) return;

    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final segmentRect = Rect.fromCircle(center: center, radius: radius - 6);

    double startAngle = -pi / 2;
    final labels = <_SegmentLabelData>[];

    for (final s in segments) {
      final sweep = (s.probability / total) * 2 * pi;

      final gradient = RadialGradient(
        colors: [Color.lerp(s.color, Colors.white, 0.22)!, s.color],
        radius: 0.95,
      );
      final fillPaint = Paint()
        ..shader = gradient.createShader(segmentRect)
        ..style = PaintingStyle.fill;
      canvas.drawArc(segmentRect, startAngle, sweep, true, fillPaint);

      final sepPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6;
      canvas.drawArc(segmentRect, startAngle, sweep, true, sepPaint);

      labels.add(
        _SegmentLabelData(
          midAngle: startAngle + sweep / 2,
          sweep: sweep,
          label: s.label,
          percent: s.probability,
        ),
      );

      startAngle += sweep;
    }

    // metallic gradient rim
    final rimPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          primaryColor,
          primaryColor.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.6),
          primaryColor.withValues(alpha: 0.4),
          primaryColor,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    canvas.drawCircle(center, radius - 2.5, rimPaint);

    // small light "bulbs" around the rim for an arcade / premium feel
    const dotCount = 16;
    for (int i = 0; i < dotCount; i++) {
      final angle = (2 * pi / dotCount) * i;
      final dotCenter = Offset(
        center.dx + (radius - 2) * cos(angle),
        center.dy + (radius - 2) * sin(angle),
      );
      canvas.drawCircle(
        dotCenter,
        1.6,
        Paint()..color = Colors.white.withValues(alpha: 0.9),
      );
    }

    // segment labels — title (if the slice is wide enough) + percentage
    for (final l in labels) {
      _paintSegmentLabel(canvas, center, radius, l);
    }

    // glossy center hub
    final hubRadius = size.width * 0.15;
    final hubRect = Rect.fromCircle(center: center, radius: hubRadius);
    canvas.drawCircle(
      center,
      hubRadius,
      Paint()
        ..shader = RadialGradient(
          colors: [Colors.white, holeColor],
        ).createShader(hubRect),
    );
    canvas.drawCircle(
      center,
      hubRadius,
      Paint()
        ..color = primaryColor.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  void _paintSegmentLabel(
    Canvas canvas,
    Offset center,
    double radius,
    _SegmentLabelData d,
  ) {
    // narrow slices only get the percentage, wide ones also get a short title
    final showTitle = d.sweep > 0.55;
    final textRadius = radius * (showTitle ? 0.66 : 0.6);

    canvas.save();
    canvas.translate(
      center.dx + textRadius * cos(d.midAngle),
      center.dy + textRadius * sin(d.midAngle),
    );

    // rotate so text reads outward from the center, flipped on the bottom
    // half so it never renders upside down
    var rotation = d.midAngle + pi / 2;
    if (d.midAngle > pi / 2 && d.midAngle < pi * 1.5) {
      rotation += pi;
    }
    canvas.rotate(rotation);

    const shadow = [
      Shadow(color: Colors.black45, blurRadius: 3, offset: Offset(0, 1)),
    ];

    if (showTitle) {
      final titlePainter = TextPainter(
        text: TextSpan(
          text: d.label.length > 10 ? '${d.label.substring(0, 9)}…' : d.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            shadows: shadow,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      titlePainter.paint(
        canvas,
        Offset(-titlePainter.width / 2, -titlePainter.height - 1),
      );
    }

    final percentPainter = TextPainter(
      text: TextSpan(
        text: '${d.percent}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          shadows: shadow,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    percentPainter.paint(canvas, Offset(-percentPainter.width / 2, 1));

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _MiniWheelPainter oldDelegate) =>
      oldDelegate.segments != segments ||
      oldDelegate.holeColor != holeColor ||
      oldDelegate.primaryColor != primaryColor;
}

class _SegmentLabelData {
  final double midAngle;
  final double sweep;
  final String label;
  final int percent;
  _SegmentLabelData({
    required this.midAngle,
    required this.sweep,
    required this.label,
    required this.percent,
  });
}
