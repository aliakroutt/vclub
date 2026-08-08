import 'package:flutter/material.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';

class AuditShimmerList extends StatelessWidget {
  const AuditShimmerList({super.key});

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
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.045)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ShimmerBox(width: 42, height: 42, borderRadius: BorderRadius.circular(13)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ShimmerBox(width: 160, height: 13),
                    const SizedBox(height: 8),
                    const ShimmerBox(width: 100, height: 11),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const ShimmerBox(width: 60, height: 11),
              const Spacer(),
              ShimmerBox(width: 80, height: 20, borderRadius: BorderRadius.circular(9)),
            ],
          ),
        ],
      ),
    );
  }
}