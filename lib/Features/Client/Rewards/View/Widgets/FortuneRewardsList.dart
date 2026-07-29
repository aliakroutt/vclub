import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/RewardsTab.dart';

class FortuneRewardsList extends StatelessWidget {
  final double height;
  final VoidCallback? onSpinTap;

  const FortuneRewardsList({
    super.key,
    this.height = 440,
    this.onSpinTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientDashboardController>(); // adjust to your controller name

    return SizedBox(
      height: height,
      child: Obx(() {
        if (controller.wheelhistoryLoading.value) {
          return const _WheelHistoryShimmerList();
        }

        if (controller.wheel_history.isEmpty) {
          return _EmptyWheelHistoryState(onSpinTap: onSpinTap);
        }

        return ListView.separated(
          primary: true,
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: controller.wheel_history.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final spin = controller.wheel_history[index];
            return WheelHistoryCard(spin: spin);
          },
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shimmer loading placeholder — mirrors WheelHistoryCard layout
// ─────────────────────────────────────────────────────────────

class _WheelHistoryShimmerList extends StatelessWidget {
  const _WheelHistoryShimmerList();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final baseColor = isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.white.withOpacity(0.14) : Colors.grey.shade100;

    return ListView.separated(
      primary: true,
      padding: const EdgeInsets.only(top: 4, bottom: 24),
      itemCount: 5,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          period: const Duration(milliseconds: 1400),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 12,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 10,
                        width: 90,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 9,
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 60,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
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

// ─────────────────────────────────────────────────────────────
//  Empty state — modern, premium, subtle entrance animation
// ─────────────────────────────────────────────────────────────

class _EmptyWheelHistoryState extends StatelessWidget {
  final VoidCallback? onSpinTap;

  const _EmptyWheelHistoryState({this.onSpinTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    const accent = Color(0xFFF59E0B); // matches WheelHistoryCard's "points" accent

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: accent.withOpacity(isDark ? 0.16 : 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.gift,
                  size: 36,
                  color: accent.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "no_spins_title".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "no_spins_subtitle".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: isDark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.45),
                ),
              ),
              if (onSpinTap != null) ...[
                const SizedBox(height: 22),
                _SpinButton(onTap: onSpinTap!, accent: accent),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpinButton extends StatefulWidget {
  final VoidCallback onTap;
  final Color accent;

  const _SpinButton({required this.onTap, required this.accent});

  @override
  State<_SpinButton> createState() => _SpinButtonState();
}

class _SpinButtonState extends State<_SpinButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) async {
        await _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: widget.accent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.reserve, size: 15, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "spin_now".tr,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}