import 'package:flutter/material.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';

class PlansShimmerList extends StatelessWidget {
  const PlansShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: List.generate(3, (index) => const _ShimmerPlanCard()),
      ),
    );
  }
}

class _ShimmerPlanCard extends StatelessWidget {
  const _ShimmerPlanCard();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 46, height: 46, borderRadius: BorderRadius.circular(15)),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 90, height: 16),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 110, height: 22),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 1),
          const SizedBox(height: 14),
          ...List.generate(4, (i) => const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: ShimmerBox(width: double.infinity, height: 14),
              )),
          const SizedBox(height: 6),
          ShimmerBox(width: double.infinity, height: 48, borderRadius: BorderRadius.circular(14)),
        ],
      ),
    );
  }
}