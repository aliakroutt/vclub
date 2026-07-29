import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class EmployeeShimmerList extends StatelessWidget {
  final int count;
  const EmployeeShimmerList({super.key, this.count = 3});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: EmployeeCardShimmer(),
        ),
      ),
    );
  }
}

class EmployeeCardShimmer extends StatelessWidget {
  const EmployeeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;

    final baseColor = isDark ? const Color(0xFF232326) : const Color(0xFFEDEDF0);
    final highlightColor = isDark ? const Color(0xFF2E2E32) : const Color(0xFFF7F7F9);
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);

    Widget block({required double width, required double height, double radius = 6}) {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1400),
      child: Container(
        padding: EdgeInsets.all(w * 0.042),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            block(width: w * 0.118, height: w * 0.118, radius: w * 0.118),
            SizedBox(width: w * 0.034),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      block(width: w * 0.32, height: 14),
                      const Spacer(),
                      block(width: w * 0.14, height: 12),
                    ],
                  ),
                  SizedBox(height: w * 0.02),
                  block(width: w * 0.45, height: 11),
                  SizedBox(height: w * 0.03),
                  Container(height: 1, color: baseColor),
                  SizedBox(height: w * 0.03),
                  Row(
                    children: [
                      block(width: w * 0.22, height: 11),
                      const Spacer(),
                      block(width: w * 0.16, height: 16, radius: 8),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}