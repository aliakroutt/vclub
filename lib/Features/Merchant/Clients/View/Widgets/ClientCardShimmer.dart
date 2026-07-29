import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ClientCardShimmer extends StatelessWidget {
  const ClientCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white.withOpacity(0.07) : Colors.black.withOpacity(0.06);
    final highlight = isDark ? Colors.white.withOpacity(0.16) : Colors.black.withOpacity(0.03);
    final borderColor = isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: .5),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(height: 12, width: 120, color: Colors.white),
                        const SizedBox(height: 8),
                        Container(height: 10, width: 160, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(height: 10, width: 100, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    width: 50,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: Colors.white),
              const SizedBox(height: 12),
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Column(
                      children: [
                        Container(width: 14, height: 14, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(width: 30, height: 10, color: Colors.white),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}