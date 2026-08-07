import 'package:flutter/material.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';

class ActivityShimmerList extends StatelessWidget {
  const ActivityShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: 6,
        itemBuilder: (context, index) => const _ShimmerCard(),
      ),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  const _ShimmerCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox(width: 44, height: 44, borderRadius: BorderRadius.circular(14)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerBox(width: 140, height: 14),
                const SizedBox(height: 10),
                const ShimmerBox(width: 100, height: 11),
                const SizedBox(height: 12),
                ShimmerBox(width: 70, height: 20, borderRadius: BorderRadius.circular(8)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}