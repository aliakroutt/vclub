import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/Dashboard/Models/client_stats_model.dart';

class ProfileStatsRow extends StatelessWidget {
  final ClientStatsModel? stats;
  final bool isLoading;

  const ProfileStatsRow({super.key, required this.stats, this.isLoading = false});

  String _compact(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final items = [
      (label: "points_earned".tr, value: stats?.pointsEarned ?? 0, icon: Iconsax.star_1, color: const Color(0xFFF59E0B)),
      (label: "transactions".tr, value: stats?.totalTransactions ?? 0, icon: Iconsax.receipt_2_1, color: AppColors.primary),
      (label: "rewards_claimed".tr, value: stats?.stampsRewardsClaimed ?? 0, icon: Iconsax.gift, color: const Color(0xFF10B981)),
    ];

    return Row(
      children: List.generate(items.length, (i) {
        final item = items[i];
        return Expanded(
          child: Padding(
            padding: Get.locale?.languageCode == 'ar' ?  EdgeInsets.only(   left: i == items.length - 1 ? 0 : size.width * 0.03)  :  EdgeInsets.only(   right: i == items.length - 1 ? 0 : size.width * 0.03),
            child: _StatTile(
              icon: item.icon,
              label: item.label,
              value: item.value,
              color: item.color,
              isLoading: isLoading,
              compact: _compact,
            ),
          ),
        );
      }),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;
  final bool isLoading;
  final String Function(int) compact;

  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isLoading,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.symmetric(vertical: width * 0.038, horizontal: width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(0.045) : Colors.white,
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 16, offset: const Offset(0, 8))],
        border: isDark ? Border.all(color: Colors.white.withOpacity(0.07)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 14, color: color),
          ),
          const SizedBox(height: 12),
          isLoading
              ? _shimmer(isDark)
              : TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, v, _) => AppText(compact(v.round()), fontSize: width * 0.048, fontWeight: FontWeight.w800),
                ),
          const SizedBox(height: 3),
          AppText(
            label,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Widget _shimmer(bool isDark) => Container(
        width: 34,
        height: 18,
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(6),
        ),
      );
}