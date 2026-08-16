import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Client/FortuneWheel/Models/FortuneWheelModels.dart';

class SpinWheelWidget extends StatefulWidget {
  final List<WheelSegmentModel> segments;
  final double size;
  final VoidCallback? onSpinComplete;

  const SpinWheelWidget({
    super.key,
    required this.segments,
    required this.size,
    this.onSpinComplete,
  });

  @override
  State<SpinWheelWidget> createState() => SpinWheelWidgetState();
}

class SpinWheelWidgetState extends State<SpinWheelWidget> {
  final StreamController<int> _selected = StreamController<int>.broadcast();

  @override
  void dispose() {
    _selected.close();
    super.dispose();
  }

  /// Call ONLY after the API has already returned the winning index.
  /// The package handles all rotation math and guarantees landing on
  /// this exact index.
  void spinToIndex(int index) {
    _selected.add(index);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.segments.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: FortuneWheel(
        selected: _selected.stream,
        animateFirst: false,
        physics: CircularPanPhysics(
          duration: const Duration(seconds: 4),
          curve: Curves.decelerate,
        ),
        onAnimationEnd: widget.onSpinComplete,
        indicators: [
          FortuneIndicator(
            alignment: Alignment.topCenter,
            child: TriangleIndicator(color: AppColors.primary, width: 22, height: 22),
          ),
        ],
        items: [
          for (final seg in widget.segments)
            FortuneItem(
              style: FortuneItemStyle(
                color: seg.color,
                borderColor: Colors.white,
                borderWidth: 2,
                textStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Text(seg.label, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            ),
        ],
      ),
    );
  }
}