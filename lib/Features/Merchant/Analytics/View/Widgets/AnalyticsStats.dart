import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';


class AnalyticsStatsColumn extends StatelessWidget {
  const AnalyticsStatsColumn({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = MerchantDashboardController.to;

    return Obx(() {
      final isLoading =
          controller.statsLoading.value && !controller.initialLoaded.value;
      final hasError = controller.statsError.value.isNotEmpty;
      final stats = controller.stats.value;

      if (isLoading) {
        return Column(
          children: List.generate(
            4,
            (index) => Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.015),
              child: _StatCardSkeleton(size: size, isDark: isDark),
            ),
          ),
        );
      }

      if (hasError || stats == null) {
        return _StatsErrorState(
          size: size,
          isDark: isDark,
          onRetry: controller.fetchStats,
        );
      }

      final items = <_StatItem>[
        _StatItem(
          title: "total_clients".tr,
          value: stats.clients.total.toDouble(),
          suffix: "",
          subtitle: stats.clients.newThisMonth > 0
              ? "new_this_month".trParams({
                  "count": stats.clients.newThisMonth.toString(),
                })
              : null,
          icon: Iconsax.profile_2user,
          color: const Color(0xFF6C5CE7),
        ),
        _StatItem(
          title: "total_scans".tr,
          value: stats.scans.total.toDouble(),
          suffix: "",
          subtitle: stats.scans.thisMonth > 0
              ? "new_this_month".trParams({
                  "count": stats.scans.thisMonth.toString(),
                })
              : null,
          icon: Iconsax.scan_barcode,
          color: const Color(0xFF0984E3),
        ),
        _StatItem(
          title: "rewards_redeemed".tr,
          value: stats.rewardsRedeemed.total.toDouble(),
          suffix: "",
          subtitle: stats.rewardsRedeemed.thisMonth > 0
              ? "new_this_month".trParams({
                  "count": stats.rewardsRedeemed.thisMonth.toString(),
                })
              : null,
          icon: Iconsax.gift,
          color: const Color(0xFF00B894),
        ),
        _StatItem(
          title: "retention_rate".tr,
          value: stats.retentionRate,
          suffix: "%",
          subtitle: stats.clients.vip > 0
              ? "vip_clients_count".trParams({
                  "count": stats.clients.vip.toString(),
                })
              : null,
          icon: Iconsax.chart_2,
          color: const Color(0xFFFFC542),
        ),
      ];

      return Column(
        children: List.generate(items.length, (index) {
          final item = items[index];

          return Padding(
            padding: EdgeInsets.only(bottom: size.height * 0.015),
            child: FadeSlide(
              delayMs: 200 + index * 100,
              child: _StatCard(
                title: item.title,
                value: item.value,
                suffix: item.suffix,
                subtitle: item.subtitle,
                icon: item.icon,
                color: item.color,
                isDark: isDark,
                size: size,
                delay: index * 80,
              ),
            ),
          );
        }),
      );
    });
  }
}

class _StatItem {
  final String title;
  final double value;
  final String suffix;
  final String? subtitle;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.title,
    required this.value,
    required this.suffix,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _StatCard extends StatefulWidget {
  final String title;
  final double value;
  final String suffix;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Size size;
  final int delay;

  const _StatCard({
    required this.title,
    required this.value,
    required this.suffix,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.size,
    required this.delay,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _start = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _start = true);
    });
  }

  String _format(double v) {
    if (v >= 1000) {
      return v.toInt().toString().replaceAllMapped(
            RegExp(r'\B(?=(\d{3})+(?!\d))'),
            (match) => ',',
          );
    }
    return v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.045,
        vertical: size.height * 0.018,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: widget.isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.25 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            width: size.width * 0.14,
            height: size.width * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.color.withOpacity(0.18),
                  widget.color.withOpacity(0.05),
                ],
              ),
            ),
            child: Icon(
              widget.icon,
              color: widget.color,
              size: size.width * 0.055,
            ),
          ),

          SizedBox(width: size.width * 0.04),

          /// TITLE + VALUE
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  widget.title,
                  fontSize: size.width * 0.034,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(0.6),
                ),
                SizedBox(height: size.height * 0.005),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1100),
                  curve: Curves.easeOutCubic,
                  tween: Tween<double>(
                    begin: 0,
                    end: _start ? widget.value : 0,
                  ),
                  builder: (context, val, _) {
                    return AppText(
                      "${_format(val)}${widget.suffix}",
                      fontSize: size.width * 0.055,
                      fontWeight: FontWeight.w800,
                    );
                  },
                ),
              ],
            ),
          ),

          /// SUBTITLE PILL (real "+X this month" data, no fake trend %)
          if (widget.subtitle != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: widget.color.withOpacity(0.12),
                border: Border.all(
                  color: widget.color.withOpacity(0.25),
                ),
              ),
              child: AppText(
                widget.subtitle!,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: widget.color,
              ),
            ),
        ],
      ),
    );
  }
}

class _StatCardSkeleton extends StatelessWidget {
  final Size size;
  final bool isDark;

  const _StatCardSkeleton({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? Colors.white : Colors.black;

    return Container(
      height: size.height * 0.1,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: base.withOpacity(0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.14,
            height: size.width * 0.14,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: base.withOpacity(0.06),
            ),
          ),
          SizedBox(width: size.width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: size.width * 0.3,
                  height: 12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: base.withOpacity(0.06),
                  ),
                ),
                SizedBox(height: size.height * 0.01),
                Container(
                  width: size.width * 0.2,
                  height: 16,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: base.withOpacity(0.08),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsErrorState extends StatelessWidget {
  final Size size;
  final bool isDark;
  final VoidCallback onRetry;

  const _StatsErrorState({
    required this.size,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.04),
        ),
      ),
      child: Column(
        children: [
          AppText(
            "failed_load_stats".tr,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withOpacity(0.6),
          ),
          SizedBox(height: size.height * 0.012),
          GestureDetector(
            onTap: onRetry,
            child: AppText(
              "retry".tr,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF6C5CE7),
            ),
          ),
        ],
      ),
    );
  }
}