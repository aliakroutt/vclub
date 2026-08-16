import 'package:flutter/material.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/Widgets/ShimmerWrapper.dart';

class FortuneWheelShimmer extends StatelessWidget {
  final double wheelSize;
  const FortuneWheelShimmer({super.key, required this.wheelSize});

  @override
  Widget build(BuildContext context) {
    return ShimmerWrapper(
      child: Column(
        children: [
          SizedBox(
            height: 78,
            child: Row(
              children: List.generate(
                4,
                (i) => Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ShimmerBox(width: 52, height: 52, borderRadius: BorderRadius.circular(26)),
                      const SizedBox(height: 6),
                      const ShimmerBox(width: 50, height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 90, borderRadius: BorderRadius.circular(18))),
              const SizedBox(width: 12),
              Expanded(child: ShimmerBox(height: 90, borderRadius: BorderRadius.circular(18))),
            ],
          ),
          const SizedBox(height: 30),
          Center(child: ShimmerBox(width: wheelSize, height: wheelSize, borderRadius: BorderRadius.circular(wheelSize / 2))),
          const SizedBox(height: 24),
          ShimmerBox(width: double.infinity, height: 54, borderRadius: BorderRadius.circular(16)),
        ],
      ),
    );
  }
}