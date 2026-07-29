import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/RewardsMerchantModel.dart';


class RewardsCardStats extends StatelessWidget {
  const RewardsCardStats({
    super.key,
    this.onViewAll,
  });

  final VoidCallback? onViewAll;

  static const _accent = Color(0xFFFF8A00);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = MerchantDashboardController.to;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.06)
              : Colors.black.withOpacity(.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .04),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          /// HEADER
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _accent.withOpacity(.10),
                ),
                child: Icon(
                  Iconsax.gift,
                  color: _accent,
                  size: size.width * .05,
                ),
              ),

              SizedBox(width: size.width * .035),

              Expanded(
                child: AppText(
                  "rewards_merchant".tr,
                  fontSize: size.width * .042,
                  fontWeight: FontWeight.w700,
                ),
              ),

              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: onViewAll,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  child: AppText(
                    "view_all_merchant".tr,
                    fontSize: size.width * .031,
                    fontWeight: FontWeight.w700,
                    color: _accent,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .022),

          Obx(() {
            // ── ERROR STATE ─────────────────────────────
            if (controller.rewardsError.value.isNotEmpty && controller.rewards.isEmpty) {
              return _MessageState(
                icon: Iconsax.warning_2,
                iconColor: Colors.redAccent,
                message: controller.rewardsError.value,
                actionLabel: "retry_merchant".tr,
                onAction: () => controller.fetchRewards(),
                size: size,
                isDark: isDark,
              );
            }

            // ── LOADING / SHIMMER STATE ──────────────────
            if (controller.rewardsLoading.value && controller.rewards.isEmpty) {
              return Column(
                children: List.generate(
                  3,
                  (i) => Padding(
                    padding: EdgeInsets.only(bottom: size.height * .014),
                    child: _ShimmerRewardTile(size: size, isDark: isDark),
                  ),
                ),
              );
            }

            // ── EMPTY STATE ──────────────────────────────
            if (controller.rewards.isEmpty) {
              return _MessageState(
                icon: Iconsax.gift,
                iconColor: _accent,
                message: "no_rewards_merchant".tr,
                size: size,
                isDark: isDark,
              );
            }

            // ── DATA ──────────────────────────────────────
            final displayed = controller.rewards.take(3).toList();

            return Column(
              children: displayed
                  .map(
                    (reward) => Padding(
                      padding: EdgeInsets.only(bottom: size.height * .014),
                      child: _RewardTile(reward: reward),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

class _RewardTile extends StatelessWidget {
  final RewardModel reward;

  const _RewardTile({
    required this.reward,
  });

  static const _accent = Color(0xFFFF8A00);

  IconData get _icon {
    switch (reward.type.toLowerCase()) {
      case 'product':
        return Iconsax.box;
      case 'discount':
        return Iconsax.discount_shape;
      case 'cashback':
        return Iconsax.wallet_money;
      case 'service':
        return Iconsax.briefcase;
      default:
        return Iconsax.gift;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtitle = reward.stock != null
        ? "${reward.cost.toStringAsFixed(reward.cost % 1 == 0 ? 0 : 1)} ${"points_merchant".tr} • ${reward.stock} ${"in_stock_merchant".tr}"
        : "${reward.cost.toStringAsFixed(reward.cost % 1 == 0 ? 0 : 1)} ${"points_merchant".tr}";

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .035,
        vertical: size.height * .014,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark
            ? Colors.white.withOpacity(.03)
            : Colors.black.withOpacity(.02),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.05)
              : Colors.black.withOpacity(.04),
        ),
      ),
      child: Row(
        children: [
          /// ICON
          Container(
            width: size.width * .12,
            height: size.width * .12,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: [
                  _accent.withOpacity(.22),
                  _accent.withOpacity(.06),
                ],
              ),
            ),
            child: Icon(
              _icon,
              color: _accent,
              size: size.width * .055,
            ),
          ),

          SizedBox(width: size.width * .035),

          /// TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  reward.name,
                  fontWeight: FontWeight.w700,
                  fontSize: size.width * .036,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  fontSize: size.width * .031,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withOpacity(.55),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  decoration: BoxDecoration(
    color: reward.active
        ? const Color(0xFF00C896).withOpacity(.12)
        : Colors.grey.withOpacity(.12),
    borderRadius: BorderRadius.circular(20),
  ),
  child: AppText(
    reward.active ? "active_merchant".tr : "inactive_merchant".tr,
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: reward.active ? const Color(0xFF00C896) : Colors.grey,
  ),
),
        ],
      ),
    );
  }
}

// ── SHIMMER TILE ───────────────────────────────────────────────────────────

class _ShimmerRewardTile extends StatefulWidget {
  const _ShimmerRewardTile({required this.size, required this.isDark});

  final Size size;
  final bool isDark;

  @override
  State<_ShimmerRewardTile> createState() => _ShimmerRewardTileState();
}

class _ShimmerRewardTileState extends State<_ShimmerRewardTile>
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

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final isDark = widget.isDark;
    final baseColor = isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05);
    final highlightColor = isDark ? Colors.white.withOpacity(.14) : Colors.black.withOpacity(.10);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * .035,
        vertical: size.height * .014,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.04),
        ),
      ),
      child: Row(
        children: [
          _shimmerBox(
            width: size.width * .12,
            height: size.width * .12,
            radius: 14,
            baseColor: baseColor,
            highlightColor: highlightColor,
          ),
          SizedBox(width: size.width * .035),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shimmerBox(
                  width: size.width * .35,
                  height: 14,
                  radius: 6,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
                const SizedBox(height: 6),
                _shimmerBox(
                  width: size.width * .25,
                  height: 11,
                  radius: 6,
                  baseColor: baseColor,
                  highlightColor: highlightColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── MESSAGE STATE (error / empty) ──────────────────────────────────────────

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.size,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color iconColor;
  final String message;
  final Size size;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: size.height * .022),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(height: size.height * .014),
          AppText(
            message,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(.65) : Colors.black.withOpacity(.55),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            SizedBox(height: size.height * .014),
            GestureDetector(
              onTap: onAction,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: iconColor.withOpacity(.10),
                ),
                child: AppText(
                  actionLabel!,
                  color: iconColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}