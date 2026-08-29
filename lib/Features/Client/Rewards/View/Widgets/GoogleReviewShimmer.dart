import 'package:flutter/material.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';

class GoogleReviewShimmer extends StatelessWidget {
  const GoogleReviewShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: List.generate(3, (i) => const _ShimmerCard()),
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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 38, height: 38, borderRadius: BorderRadius.circular(19)),
              const SizedBox(width: 10),
              const Expanded(child: ShimmerBox(width: double.infinity, height: 14)),
              const SizedBox(width: 10),
              ShimmerBox(width: 60, height: 20, borderRadius: BorderRadius.circular(20)),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 44),
          const SizedBox(height: 14),
          ShimmerBox(width: double.infinity, height: 42, borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }
}