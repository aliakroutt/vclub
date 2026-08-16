import 'package:flutter/material.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/FortuneWheel/Models/FortuneWheelModels.dart';

class SegmentChipsRow extends StatelessWidget {
  final List<WheelSegmentModel> segments;
  const SegmentChipsRow({super.key, required this.segments});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: segments.map((s) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: s.color.withOpacity(isDark ? .16 : .09),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: s.color.withOpacity(.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(s.type.icon, size: 10.5, color: s.color),
              const SizedBox(width: 4),
              AppText(s.label, fontSize: 10, fontWeight: FontWeight.w700, color: s.color),
            ],
          ),
        );
      }).toList(),
    );
  }
}