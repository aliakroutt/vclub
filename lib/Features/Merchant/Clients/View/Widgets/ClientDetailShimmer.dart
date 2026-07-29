import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ClientDetailShimmer extends StatelessWidget {
  const ClientDetailShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06);
    final highlight = isDark ? Colors.white.withOpacity(0.16) : Colors.black.withOpacity(0.03);
    final cs = Theme.of(context).colorScheme;
    final border = Theme.of(context).dividerColor.withOpacity(.10);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Column(
        children: [
          // Hero shimmer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: border, width: 1),
            ),
            child: Column(
              children: [
                Container(width: 84, height: 84, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white)),
                const SizedBox(height: 16),
                Container(width: 70, height: 16, color: Colors.white),
                const SizedBox(height: 12),
                Container(width: 140, height: 18, color: Colors.white),
                const SizedBox(height: 10),
                Container(width: 180, height: 12, color: Colors.white),
                const SizedBox(height: 24),
                Container(height: 1, color: Colors.white),
                const SizedBox(height: 20),
                Row(
                  children: List.generate(3, (i) => Expanded(
                    child: Column(
                      children: [
                        Container(width: 18, height: 18, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(width: 30, height: 14, color: Colors.white),
                      ],
                    ),
                  )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          // Info grid shimmer
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.6,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: List.generate(4, (i) => Container(
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
              ),
              child: const Padding(
                padding: EdgeInsets.all(14),
                child: SizedBox.expand(child: ColoredBox(color: Colors.white)),
              ),
            )),
          ),
          const SizedBox(height: 20),
          ...List.generate(4, (i) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border, width: 1),
              ),
            ),
          )),
        ],
      ),
    );
  }
}