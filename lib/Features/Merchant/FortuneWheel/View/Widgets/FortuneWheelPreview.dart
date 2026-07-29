// fortune_preview_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';

class FortunePreviewCard extends StatelessWidget {
  FortunePreviewCard({super.key});

  final controller = Get.find<FortuneController>();

  static const _accent = Color(0xFF3B6D11);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() {
        final segs = controller.segments;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            _PreviewHeader(size: size, isDark: isDark, accent: _accent),

            SizedBox(height: size.height * 0.022),
            Divider(
              height: 1,
              thickness: 1,
              color: isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05),
            ),
            SizedBox(height: size.height * 0.030),

            // ── WHEEL ────────────────────────────────────────────────────────
            Center(
              child: _FortuneWheelPreview(
                segments: segs,
                size: size,
                isDark: isDark,
              ),
            ),

            SizedBox(height: size.height * 0.030),

            // ── LEGEND ───────────────────────────────────────────────────────
            if (segs.isNotEmpty) ...[
              Divider(
                height: 1,
                thickness: 1,
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
              SizedBox(height: size.height * 0.018),
              ...List.generate(segs.length, (i) {
                final isLast = i == segs.length - 1;
                return Padding(
                  padding:
                      EdgeInsets.only(bottom: isLast ? 0 : size.height * 0.010),
                  child: _LegendRow(
                    segment: segs[i],
                    index: i,
                    size: size,
                    isDark: isDark,
                  ),
                );
              }),
            ],
          ],
        );
      }),
    );
  }
}

// ── HEADER ────────────────────────────────────────────────────────────────────

class _PreviewHeader extends StatelessWidget {
  final Size size;
  final bool isDark;
  final Color accent;

  const _PreviewHeader({
    required this.size,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: size.width * 0.105,
          height: size.width * 0.105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: accent.withOpacity(0.10),
          ),
          child: Icon(
            Icons.pie_chart_rounded,
            color: accent,
            size: size.width * 0.052,
          ),
        ),
        SizedBox(width: size.width * 0.035),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                "fortune_preview_title".tr,
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 3),
              AppText(
                "fortune_preview_subtitle".tr,
                fontSize: size.width * 0.029,
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.50),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── WHEEL PAINTER ─────────────────────────────────────────────────────────────

class _WheelPainter extends CustomPainter {
  final List<FortuneSegment> segments;
  final List<double> sweeps; // radians per segment
  final bool isDark;

  _WheelPainter({
    required this.segments,
    required this.sweeps,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.18; // donut hole
    final strokeRadius = radius - 1.5;

    final paint = Paint()..style = PaintingStyle.fill;
    final dividerPaint = Paint()
      ..color = isDark
          ? const Color(0xFF18181B)
          : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    double startAngle = -math.pi / 2; // 12 o'clock

    for (int i = 0; i < segments.length; i++) {
      final sweep = sweeps[i];
      paint.color = segments[i].color;

      // Main segment arc
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: strokeRadius),
        startAngle,
        sweep,
        true,
        paint,
      );

      // Divider line
      canvas.drawLine(
        center,
        Offset(
          center.dx + strokeRadius * math.cos(startAngle),
          center.dy + strokeRadius * math.sin(startAngle),
        ),
        dividerPaint,
      );

      // Segment label: percent text
      final midAngle = startAngle + sweep / 2;
      final labelRadius = radius * 0.62;
      final labelOffset = Offset(
        center.dx + labelRadius * math.cos(midAngle),
        center.dy + labelRadius * math.sin(midAngle),
      );

      final seg = segments[i];
      final pct = double.tryParse(seg.percentController.text) ?? 0.0;
      final label = pct > 0 ? '${pct.toStringAsFixed(0)}%' : '';

      if (label.isNotEmpty && sweep > 0.25) {
        final tp = TextPainter(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              shadows: [
                Shadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        canvas.save();
        canvas.translate(labelOffset.dx, labelOffset.dy);
        canvas.rotate(midAngle + math.pi / 2);
        tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
        canvas.restore();
      }

      startAngle += sweep;
    }

    // ── Donut hole ──
    final holePaint = Paint()
      ..color = isDark ? const Color(0xFF18181B) : Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, innerRadius, holePaint);

    // ── Center decorative ring ──
    final ringPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.06)
          : Colors.black.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, innerRadius, ringPaint);
  }

  @override
  bool shouldRepaint(_WheelPainter old) =>
      old.segments != segments ||
      old.sweeps != sweeps ||
      old.isDark != isDark;
}

// ── WHEEL WIDGET ──────────────────────────────────────────────────────────────

class _FortuneWheelPreview extends StatelessWidget {
  final List<FortuneSegment> segments;
  final Size size;
  final bool isDark;

  const _FortuneWheelPreview({
    required this.segments,
    required this.size,
    required this.isDark,
  });

  List<double> _buildSweeps() {
    if (segments.isEmpty) return [];

    final percents = segments
        .map((s) => double.tryParse(s.percentController.text) ?? 0.0)
        .toList();

    final total = percents.fold(0.0, (a, b) => a + b);

    if (total <= 0) {
      // Equal distribution when no percents set
      final equal = (2 * math.pi) / segments.length;
      return List.filled(segments.length, equal);
    }

    return percents
        .map((p) => (p / total) * 2 * math.pi)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = size.width * 0.68;

    if (segments.isEmpty) {
      return _EmptyWheelPlaceholder(diameter: diameter, isDark: isDark);
    }

    final sweeps = _buildSweeps();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Subtle glow ring behind the wheel
        Container(
          width: diameter + 12,
          height: diameter + 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: segments.first.color.withOpacity(0.12),
                blurRadius: 28,
                spreadRadius: 4,
              ),
            ],
          ),
        ),

        // The wheel
        SizedBox(
          width: diameter,
          height: diameter,
          child: CustomPaint(
            painter: _WheelPainter(
              segments: segments,
              sweeps: sweeps,
              isDark: isDark,
            ),
          ),
        ),

        // Center hub icon
        Container(
          width: diameter * 0.175,
          height: diameter * 0.175,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF18181B) : Colors.white,
          ),
          child: Icon(
            Icons.star_rounded,
            size: diameter * 0.08,
            color: const Color(0xFF3B6D11),
          ),
        ),

        // Pointer arrow at top
        Positioned(
          top: 0,
          child: _PointerArrow(isDark: isDark),
        ),
      ],
    );
  }
}

// ── POINTER ARROW ─────────────────────────────────────────────────────────────

class _PointerArrow extends StatelessWidget {
  final bool isDark;
  const _PointerArrow({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(18, 22),
      painter: _ArrowPainter(isDark: isDark),
    );
  }
}

class _ArrowPainter extends CustomPainter {
  final bool isDark;
  _ArrowPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.white : const Color(0xFF1A1A1E)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArrowPainter old) => old.isDark != isDark;
}

// ── EMPTY WHEEL PLACEHOLDER ───────────────────────────────────────────────────

class _EmptyWheelPlaceholder extends StatelessWidget {
  final double diameter;
  final bool isDark;

  const _EmptyWheelPlaceholder({
    required this.diameter,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.06),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pie_chart_outline_rounded,
            size: diameter * 0.22,
            color: isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.black.withOpacity(0.10),
          ),
          SizedBox(height: diameter * 0.04),
          AppText(
            "no_segments".tr,
            fontSize: diameter * 0.07,
            fontWeight: FontWeight.w500,
            color: isDark
                ? Colors.white.withOpacity(0.20)
                : Colors.black.withOpacity(0.18),
          ),
        ],
      ),
    );
  }
}

// ── LEGEND ROW ────────────────────────────────────────────────────────────────

class _LegendRow extends StatelessWidget {
  final FortuneSegment segment;
  final int index;
  final Size size;
  final bool isDark;

  const _LegendRow({
    required this.segment,
    required this.index,
    required this.size,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final name = segment.nameController.text.trim();
    final displayName = name.isNotEmpty ? name : 'segment_name_hint'.tr;
    final pctText = segment.percentController.text.trim();
    final pct = double.tryParse(pctText) ?? 0.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.038,
        vertical: size.width * 0.025,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: segment.color.withOpacity(isDark ? 0.07 : 0.05),
        border: Border.all(
          color: segment.color.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          // Color dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: segment.color,
              boxShadow: [
                BoxShadow(
                  color: segment.color.withOpacity(0.45),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          SizedBox(width: size.width * 0.030),

          // Index number
          AppText(
            '${index + 1}.',
            fontSize: size.width * 0.030,
            fontWeight: FontWeight.w700,
            color: isDark
                ? Colors.white.withOpacity(0.35)
                : Colors.black.withOpacity(0.30),
          ),
          SizedBox(width: size.width * 0.018),

          // Segment name
          Expanded(
            child: AppText(
              displayName,
              fontSize: size.width * 0.033,
              fontWeight: FontWeight.w600,
              color: name.isNotEmpty
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark
                      ? Colors.white.withOpacity(0.25)
                      : Colors.black.withOpacity(0.25)),
            ),
          ),

          // Percent badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: segment.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              pct > 0 ? '${pct.toStringAsFixed(0)}%' : '—',
              fontSize: size.width * 0.030,
              fontWeight: FontWeight.w800,
              color: segment.color,
            ),
          ),
        ],
      ),
    );
  }
}