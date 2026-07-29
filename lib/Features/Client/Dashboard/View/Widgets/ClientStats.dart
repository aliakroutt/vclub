import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/Models/client_stats_model.dart'; // adjust path

class ClientStatsRow extends StatelessWidget {
  const ClientStatsRow({super.key});

  // Single source of truth: field -> (title key, icon, color)
  List<_StatItem> _buildItems(ClientStatsModel s) {
  return [
    _StatItem(
      title: 'points_earned_client'.tr,
      value: s.pointsEarned.toString(),
      icon: Iconsax.star_1,
      color: const Color(0xFFFFB300), // amber gold
    ),
    _StatItem(
      title: 'stamps_earned_client'.tr,
      value: s.stampsEarned.toString(),
      icon: Iconsax.award,
      color: const Color(0xFF29B6F6), // blue
    ),
    _StatItem(
      title: 'cashback_earned_client'.tr,
      value: "${s.cashbackEarned} €",
      icon: Iconsax.money_recive,
      color: const Color(0xFF4CAF50), // green
    ),
    _StatItem(
      title: 'bonus_received_client'.tr,
      value: s.bonusReceived.toString(),
      icon: Iconsax.gift,
      color: const Color(0xFF6C63FF), // purple
    ),
  ];
}

  @override
  Widget build(BuildContext context) {
    final controller = ClientDashboardController.to;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Obx(() {
        final isLoading = controller.statsLoading.value;
        final hasError = controller.statsError.value.isNotEmpty;
        final data = controller.stats.value;

        // ---------- LOADING ----------
        if (isLoading && data == null) {
  return _StatsGrid(
    itemCount: 4,
    itemBuilder: (context, i) => _ShimmerStatCard(isDark: isDark),
  );
}

        // ---------- ERROR (with no cached data) ----------
        if (hasError && data == null) {
          return _StatsErrorState(
            isDark: isDark,
            onRetry: () => controller.fetchStats(),
          );
        }

        // ---------- EMPTY (shouldn't really happen once loaded) ----------
        if (data == null) {
          return const SizedBox.shrink();
        }

        // ---------- LOADED ----------
        final items = _buildItems(data);
        return _StatsGrid(
          itemCount: items.length,
          itemBuilder: (context, i) => _StatCard(
            title: items[i].title,
            value: items[i].value,
            icon: items[i].icon,
            color: items[i].color,
            isDark: isDark,
          ),
        );
      }),
    );
  }
}

class _StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  _StatItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });
}

// =========================
// SHARED GRID SHELL
// =========================
class _StatsGrid extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;

  const _StatsGrid({required this.itemCount, required this.itemBuilder});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 2.2, // was 1.5 — higher ratio = shorter card
      ),
      itemBuilder: itemBuilder,
    );
  }
}

// =========================
// ERROR STATE
// =========================
class _StatsErrorState extends StatelessWidget {
  final bool isDark;
  final VoidCallback onRetry;

  const _StatsErrorState({required this.isDark, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.78),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.08)
              : Colors.white.withOpacity(0.6),
        ),
      ),
      child: Column(
        children: [
          Icon(Iconsax.warning_2, color: Colors.redAccent, size: 28),
          const SizedBox(height: 8),
          AppText(
            'failed_load_stats'.tr,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: AppText(
              'retry'.tr,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// =========================
// REAL STAT CARD
// =========================
class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDark;
  final Color color;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.isDark,
    required this.color,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final iconSize = size.width * 0.045;
    final titleSize = size.width * 0.028;
    final valueSize = size.width * 0.045;
    final cardHeight = size.height * 0.1;
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) => _ctrl.reverse(),
      onTapCancel: () => _ctrl.reverse(),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          height: cardHeight,
          padding: EdgeInsets.all(size.width * 0.03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.78),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(widget.isDark ? 0.25 : 0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: widget.isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.white.withOpacity(0.6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(size.width * 0.02),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: widget.color.withOpacity(widget.isDark ? 0.18 : 0.12),
                    ),
                    child: Icon(widget.icon, size: iconSize, color: widget.color),
                  ),
                  Spacer(),
                   AppText(
                widget.value,
                fontSize: valueSize,
                fontWeight: FontWeight.w800,
              ),
                ],
              ),
              
              AppText(
                widget.title,
                fontSize: titleSize,
                fontWeight: FontWeight.w400,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =========================
// SHIMMER STAT CARD (placeholder while loading)
// =========================
// =========================
// SHIMMER STAT CARD (placeholder while loading)
// =========================
class _ShimmerStatCard extends StatelessWidget {
  final bool isDark;
  const _ShimmerStatCard({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return _ShimmerEffect(
          isDark: isDark,
          child: Container(
            width: w,
            height: h,
            padding: EdgeInsets.all(w * 0.03),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.white.withOpacity(0.78),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.white.withOpacity(0.6),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: h * 0.35,
                  height: h * 0.28,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                Container(
                  width: w * 0.3,
                  height: h * 0.12,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                Container(
                  width: w * 0.45,
                  height: h * 0.1,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Lightweight shimmer built with a ShaderMask + sliding gradient —
/// no external "shimmer" package dependency required.
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final bool isDark;
  const _ShimmerEffect({required this.child, required this.isDark});

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
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
    final baseColor = widget.isDark ? Colors.white10 : Colors.black12;
    final highlightColor = widget.isDark
        ? Colors.white.withOpacity(0.25)
        : Colors.white.withOpacity(0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // slides the gradient from fully off-screen left to fully off-screen right
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 3 - 1.5),
      0.0,
      0.0,
    );
  }
}