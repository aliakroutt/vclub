import 'package:flutter/material.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';


class SentNotificationsShimmerList extends StatelessWidget {
  const SentNotificationsShimmerList({super.key});

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
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(
          color:
              isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.04),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 46, height: 46, borderRadius: BorderRadius.circular(15)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 70, height: 18, borderRadius: BorderRadius.circular(8)),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 90, height: 12),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const ShimmerBox(width: double.infinity, height: 15),
          const SizedBox(height: 8),
          const ShimmerBox(width: 200, height: 13),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.circular(12)),
              const SizedBox(width: 8),
              const ShimmerBox(width: 120, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}