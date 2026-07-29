import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Features/Client/Dashboard/Controllers/ClientDashboardController.dart';
import 'package:vclub/Features/Client/Dashboard/View/Widgets/RewardsTab.dart';

class ProgramsRewardsList extends StatelessWidget {
  final double height;
  final VoidCallback? onExploreTap;

  const ProgramsRewardsList({
    super.key,
    this.height = 440,
    this.onExploreTap,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientDashboardController>(); // adjust to your controller name

    return SizedBox(
      height: height,
      child: Obx(() {
        if (controller.rewardsLoading.value) {
          return const _RewardsShimmerList();
        }

        if (controller.rewards.isEmpty) {
          return Center(child: _EmptyRewardsState(onExploreTap: onExploreTap));
        }

        return ListView.separated(
          primary: true,
          padding: const EdgeInsets.only(top: 4, bottom: 100),
          itemCount: controller.rewards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final reward = controller.rewards[index];
            return RewardCard(
              reward: reward,
              onTap: () {
                // handle tap, e.g. open reward details
              },
            );
          },
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Shimmer loading placeholder — mirrors RewardCard layout
// ─────────────────────────────────────────────────────────────

class _RewardsShimmerList extends StatelessWidget {
  const _RewardsShimmerList();

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final baseColor = isDark ? Colors.white.withOpacity(0.06) : Colors.grey.shade200;
    final highlightColor = isDark ? Colors.white.withOpacity(0.14) : Colors.grey.shade100;

    return ListView.separated(
      primary: true,
      padding: const EdgeInsets.symmetric(vertical: 4),
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
                        width: 100,
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
                  width: 64,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
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

class _EmptyRewardsState extends StatelessWidget {
  final VoidCallback? onExploreTap;

  const _EmptyRewardsState({this.onExploreTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Get.find<ThemeService>().isDarkMode.value;

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
                  color: AppColors.primary.withOpacity(isDark ? 0.14 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.award,
                  size: 36,
                  color: AppColors.primary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "no_rewards_title".tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "no_rewards_subtitle".tr,
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
              if (onExploreTap != null) ...[
                const SizedBox(height: 22),
                _ExploreButton(onTap: onExploreTap!, isDark: isDark),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ExploreButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isDark;

  const _ExploreButton({required this.onTap, required this.isDark});

  @override
  State<_ExploreButton> createState() => _ExploreButtonState();
}

class _ExploreButtonState extends State<_ExploreButton>
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
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.30),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Iconsax.search_normal_1, size: 15, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                "explore_programs".tr,
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