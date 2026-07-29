import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';

class MerchantStatsGrid extends StatelessWidget {
  const MerchantStatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = MerchantDashboardController.to;

    return Obx(() {
      // ── ERROR STATE ─────────────────────────────────────
      if (controller.statsError.value.isNotEmpty &&
          controller.stats.value == null) {
        return _ErrorState(
          isDark: isDark,
          size: size,
          message: controller.statsError.value,
          onRetry: () => controller.fetchStats(),
        );
      }

      // ── LOADING / SHIMMER STATE ─────────────────────────
      if (controller.statsLoading.value && controller.stats.value == null) {
        return _ShimmerGrid(size: size, isDark: isDark);
      }

      final s = controller.stats.value;
      if (s == null) {
        return _ErrorState(
          isDark: isDark,
          size: size,
          message: "no_stats_data_merchant".tr,
          onRetry: () => controller.fetchStats(),
        );
      }

      final stats = [
        {
          "title": "total_clients_merchant".tr,
          "value": s.clients.total.toDouble(),
          "suffix": "",
          "icon": Iconsax.profile_2user,
          "color": const Color(0xFF7C6FF7),
          "badge": null,
        },
        {
          "title": "new_clients_merchant".tr,
          "value": s.clients.newThisMonth.toDouble(),
          "suffix": "",
          "icon": Iconsax.user_add,
          "color": const Color(0xFF00C896),
          "badge": null,
        },
        {
          "title": "qr_nfc_scans_merchant".tr,
          "value": s.scans.total.toDouble(),
          "suffix": "",
          "icon": Iconsax.scan_barcode,
          "color": const Color(0xFF0984E3),
          "badge": s.scans.thisMonth,
        },
        {
          "title": "rewards_used_merchant".tr,
          "value": s.rewardsRedeemed.total.toDouble(),
          "suffix": "",
          "icon": Iconsax.gift,
          "color": const Color(0xFFFF6B6B),
          "badge": s.rewardsRedeemed.thisMonth,
        },
        {
          "title": "google_reviews_merchant".tr,
          "value": s.reviews.total.toDouble(),
          "suffix": "",
          "icon": Iconsax.star_1,
          "color": const Color(0xFFFFB930),
          "badge": s.reviews.thisMonth,
        },
        {
          "title": "loyalty_rate_merchant".tr,
          "value": s.retentionRate,
          "suffix": "%",
          "icon": Iconsax.chart_success,
          "color": const Color(0xFF00CEC9),
          "badge": null,
        },
      ];

      final rows = <List<Map<String, dynamic>>>[];
      for (var i = 0; i < stats.length; i += 2) {
        rows.add([stats[i], stats[i + 1]]);
      }

      return Column(
        children: List.generate(rows.length, (rowIdx) {
          final pair = rows[rowIdx];
          return Padding(
            padding: EdgeInsets.only(bottom: size.height * .014),
            child: Row(
              children: List.generate(2, (col) {
                final item = pair[col];
                final index = rowIdx * 2 + col;
                return Expanded(
                  child: Padding(
                    padding: Get.locale?.languageCode == 'ar'
                        ? EdgeInsets.only(
                            right: col == 1 ? size.width * .02 : 0,
                            left: col == 0 ? size.width * .02 : 0,
                          )
                        : EdgeInsets.only(
                            left: col == 1 ? size.width * .02 : 0,
                            right: col == 0 ? size.width * .02 : 0,
                          ),
                    child: FadeSlide(
                      delayMs: 200 + index * 80,
                      child: _GridStatCard(
                        title: item["title"].toString(),
                        value: item["value"] as double,
                        suffix: item["suffix"].toString(),
                        icon: item["icon"] as IconData,
                        color: item["color"] as Color,
                        badgeCount: item["badge"] as int?,
                        isDark: isDark,
                        size: size,
                        delay: index * 80,
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      );
    });
  }
}

// ── GRID STAT CARD ────────────────────────────────────────────────────────────

class _GridStatCard extends StatefulWidget {
  const _GridStatCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.icon,
    required this.color,
    required this.badgeCount,
    required this.isDark,
    required this.size,
    required this.delay,
  });

  final String title;
  final double value;
  final String suffix;
  final IconData icon;
  final Color color;
  final int? badgeCount;
  final bool isDark;
  final Size size;
  final int delay;

  @override
  State<_GridStatCard> createState() => _GridStatCardState();
}

class _GridStatCardState extends State<_GridStatCard> {
  bool _start = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _start = true);
    });
  }

  String _formatValue(double v) {
    if (widget.value % 1 != 0) {
      return v.toStringAsFixed(1);
    }
    if (v >= 1000) {
      final s = v.round().toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    }
    return v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final color = widget.color;
    final isDark = widget.isDark;

    return Container(
      padding: EdgeInsets.all(s.width * .038),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.07)
              : Colors.black.withOpacity(.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .26 : .05),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
          BoxShadow(
            color: color.withOpacity(.06),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── TOP ROW: icon + this-month badge ──────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: s.width * .094,
                height: s.width * .094,
                decoration: BoxDecoration(
                  color: color.withOpacity(.11),
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: color.withOpacity(.20)),
                ),
                child: Icon(widget.icon, color: color, size: s.width * .042),
              ),
              if (widget.badgeCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withOpacity(.20)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.arrow_circle_up,
                            size: s.width * .024,
                            color: color,
                          ),
                          SizedBox(width: s.width * .006),
                          AppText(
                            "+${widget.badgeCount}",
                            fontSize: s.width * .024,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ],
                      ),
                      SizedBox(height: s.height * .002),
                      AppText(
                        "this_month_merchant".tr,
                        fontSize: s.width * .02,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ],
                  ),
                ),
            ],
          ),

          SizedBox(height: s.height * .014),

          // ── VALUE ──────────────────────────────────────
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1100),
            curve: Curves.easeOutCubic,
            tween: Tween(begin: 0, end: _start ? widget.value : 0),
            builder: (_, animVal, __) {
              return AppText(
                "${_formatValue(animVal)}${widget.suffix}",
                fontSize: s.width * .052,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0D0D1A),
              );
            },
          ),

          SizedBox(height: s.height * .004),

          // ── TITLE ─────────────────────────────────────
          AppText(
            widget.title,
            fontSize: s.width * .028,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withOpacity(.38)
                : Colors.black.withOpacity(.40),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),

          SizedBox(height: s.height * .012),

          // ── BOTTOM ACCENT BAR ──────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: _start ? 1.0 : 0),
              builder: (_, animProg, __) {
                return LinearProgressIndicator(
                  value: animProg,
                  minHeight: 3,
                  backgroundColor: color.withOpacity(.10),
                  valueColor: AlwaysStoppedAnimation(color),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── SHIMMER GRID (loading state) ──────────────────────────────────────────────

class _ShimmerGrid extends StatelessWidget {
  const _ShimmerGrid({required this.size, required this.isDark});

  final Size size;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final rows = 3;
    return Column(
      children: List.generate(rows, (rowIdx) {
        return Padding(
          padding: EdgeInsets.only(bottom: size.height * .014),
          child: Row(
            children: List.generate(2, (col) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: col == 1 ? size.width * .02 : 0,
                    right: col == 0 ? size.width * .02 : 0,
                  ),
                  child: _ShimmerStatCard(size: size, isDark: isDark),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}

class _ShimmerStatCard extends StatefulWidget {
  const _ShimmerStatCard({required this.size, required this.isDark});

  final Size size;
  final bool isDark;

  @override
  State<_ShimmerStatCard> createState() => _ShimmerStatCardState();
}

class _ShimmerStatCardState extends State<_ShimmerStatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final isDark = widget.isDark;
    final baseColor = isDark
        ? Colors.white.withOpacity(.06)
        : Colors.black.withOpacity(.05);
    final highlightColor = isDark
        ? Colors.white.withOpacity(.14)
        : Colors.black.withOpacity(.10);

    return Container(
      padding: EdgeInsets.all(s.width * .038),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.07)
              : Colors.black.withOpacity(.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerBox(
                width: s.width * .094,
                height: s.width * .094,
                radius: 13,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
              _shimmerBox(
                width: s.width * .16,
                height: 18,
                radius: 20,
                baseColor: baseColor,
                highlightColor: highlightColor,
              ),
            ],
          ),
          SizedBox(height: s.height * .018),
          _shimmerBox(
            width: s.width * .22,
            height: s.width * .052,
            radius: 8,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          SizedBox(height: s.height * .01),
          _shimmerBox(
            width: s.width * .3,
            height: 12,
            radius: 6,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          SizedBox(height: s.height * .014),
          _shimmerBox(
            width: double.infinity,
            height: 3,
            radius: 4,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
        ],
      ),
    );
  }

  Widget _shimmerBox({
    required double width,
    required double height,
    required double radius,
    required Color baseColor,
    required Color highlightColor,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox(
            width: width,
            height: height,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0 + _controller.value * 3, 0),
                  end: Alignment(0.0 + _controller.value * 3, 0),
                  colors: [baseColor, highlightColor, baseColor],
                  stops: const [0.35, 0.5, 0.65],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── ERROR STATE ────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.isDark,
    required this.size,
    required this.message,
    required this.onRetry,
  });

  final bool isDark;
  final Size size;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: size.height * .04,
        horizontal: size.width * .06,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.07)
              : Colors.black.withOpacity(.06),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Iconsax.warning_2,
              color: Colors.redAccent,
              size: 26,
            ),
          ),
          SizedBox(height: size.height * .016),
          AppText(
            message,
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDark
                ? Colors.white.withOpacity(.7)
                : Colors.black.withOpacity(.65),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: size.height * .018),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Colors.redAccent.withOpacity(.10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Iconsax.refresh,
                    color: Colors.redAccent,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  AppText(
                    "retry_merchant".tr,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
