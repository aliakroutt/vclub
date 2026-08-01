import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Dashboard/Controllers/MerchantDashController.dart';


class AnalyticsSummaryCard extends StatelessWidget {
  const AnalyticsSummaryCard({super.key});

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

      final items = (hasError || stats == null)
          ? <Map<String, dynamic>>[]
          : [
              {
                "icon": Iconsax.user_tick,
                "title": "active_clients",
                "value": stats.clients.active.toString(),
                "color": const Color(0xFF6C5CE7),
              },
              {
                "icon": Iconsax.user_add,
                "title": "new_clients_month",
                "value": stats.clients.newThisMonth.toString(),
                "color": const Color(0xFF0984E3),
              },
              {
                "icon": Iconsax.crown,
                "title": "vip_clients",
                "value": stats.clients.vip.toString(),
                "color": const Color(0xFFFFC542),
              },
              {
                "icon": Iconsax.star,
                "title": "total_reviews",
                "value": stats.reviews.total.toString(),
                "color": const Color(0xFF00B894),
              },
            ];

      return Container(
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          color: Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: size.width * 0.11,
                  height: size.width * 0.11,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFF00CEC9).withOpacity(0.12),
                  ),
                  child: const Icon(Iconsax.chart_1, color: Color(0xFF00CEC9)),
                ),
                SizedBox(width: size.width * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        "summary",
                        fontSize: size.width * 0.042,
                        fontWeight: FontWeight.w800,
                      ),
                      const SizedBox(height: 2),
                      AppText(
                        "key_indicators",
                        fontSize: size.width * 0.032,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: size.height * 0.02),

            if (isLoading)
              ...List.generate(
                4,
                (index) => Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.014),
                  child: _IndicatorRowSkeleton(size: size, isDark: isDark),
                ),
              )
            else if (hasError || stats == null)
              Padding(
                padding: EdgeInsets.symmetric(vertical: size.height * 0.01),
                child: Center(
                  child: AppText(
                    "no_data_available".tr,
                    fontSize: size.width * 0.034,
                    color: Colors.grey,
                  ),
                ),
              )
            else
              ...items.map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.014),
                  child: _IndicatorRow(
                    icon: item["icon"] as IconData,
                    title: (item["title"] as String).tr,
                    value: item["value"].toString(),
                    color: item["color"] as Color,
                    size: size,
                    isDark: isDark,
                  ),
                );
              }),
          ],
        ),
      );
    });
  }
}

/// ================= INDICATOR ROW =================

class _IndicatorRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Size size;
  final bool isDark;

  const _IndicatorRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.03,
        vertical: size.height * 0.012,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.02),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.10,
            height: size.width * 0.10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color.withOpacity(0.12),
            ),
            child: Icon(icon, color: color, size: size.width * 0.045),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: AppText(
              title,
              fontSize: size.width * 0.035,
              fontWeight: FontWeight.w600,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.7),
            ),
          ),
          AppText(
            value,
            fontSize: size.width * 0.038,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _IndicatorRowSkeleton extends StatelessWidget {
  final Size size;
  final bool isDark;

  const _IndicatorRowSkeleton({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final base = isDark ? Colors.white : Colors.black;

    return Container(
      height: size.height * 0.055,
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: base.withOpacity(0.03),
      ),
      child: Row(
        children: [
          Container(
            width: size.width * 0.10,
            height: size.width * 0.10,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: base.withOpacity(0.06),
            ),
          ),
          SizedBox(width: size.width * 0.03),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: base.withOpacity(0.06),
              ),
            ),
          ),
        ],
      ),
    );
  }
}