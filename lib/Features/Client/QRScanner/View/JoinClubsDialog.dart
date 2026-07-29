import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

/// Modern, premium confirmation dialogs shown after a merchant QR
/// join attempt. Works in both dark and light mode and follows the
/// app's RTL/translation setup.
class JoinClubDialogs {
  JoinClubDialogs._();

  static void showSuccess() {
    Get.dialog(
      const _JoinResultDialog(isSuccess: true),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
    );
  }

  static void showError(String message) {
    Get.dialog(
      _JoinResultDialog(isSuccess: false, errorMessage: message),
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.55),
    );
  }
}

class _JoinResultDialog extends StatefulWidget {
  final bool isSuccess;
  final String? errorMessage;

  const _JoinResultDialog({
    required this.isSuccess,
    this.errorMessage,
  });

  @override
  State<_JoinResultDialog> createState() => _JoinResultDialogState();
}

class _JoinResultDialogState extends State<_JoinResultDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _cardFade;
  late final Animation<double> _cardScale;
  late final Animation<double> _iconScale;
  late final Animation<double> _checkProgress;
  late final Animation<double> _ringPulse;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  late final List<_Particle> _particles;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.isSuccess ? 1500 : 750),
    );

    _cardFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );

    _cardScale = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _iconScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(0.05, widget.isSuccess ? 0.55 : 0.4,
            curve: Curves.elasticOut),
      ),
    );

    _ringPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 1.0, curve: Curves.easeOut),
      ),
    );

    _checkProgress = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
    );

    _contentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.55, 0.9, curve: Curves.easeOut),
      ),
    );

    final accent = widget.isSuccess ? AppColors.primary : const Color(0xFFE5484D);
    _particles = widget.isSuccess
        ? List.generate(14, (i) => _Particle.random(i, accent))
        : const [];

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Decaying horizontal shake used only for the error state.
  double _shakeOffset(double t) {
    if (widget.isSuccess) return 0;
    final decay = (1 - t).clamp(0.0, 1.0);
    return sin(t * pi * 8) * 9 * decay;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    final cardColor = isDark ? const Color(0xFF161616) : Colors.white;
    final subTextColor = isDark ? Colors.white60 : Colors.black54;
    final accentColor =
        widget.isSuccess ? AppColors.primary : const Color(0xFFE5484D);

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            return Opacity(
              opacity: _cardFade.value.clamp(0.0, 1.0),
              child: Transform.translate(
                offset: Offset(_shakeOffset(_ctrl.value), 0),
                child: Transform.scale(
                  scale: _cardScale.value,
                  child: child,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(isDark ? 0.85 : 0.96),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.04),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.18),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: AnimatedBuilder(
                        animation: _ctrl,
                        builder: (context, _) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Confetti burst (success only)
                              if (widget.isSuccess)
                                CustomPaint(
                                  size: const Size(108, 108),
                                  painter: _ConfettiPainter(
                                    t: _ctrl.value,
                                    particles: _particles,
                                  ),
                                ),

                              // Soft pulsing outer ring
                              Transform.scale(
                                scale: 0.9 + (_ringPulse.value * 0.25),
                                child: Container(
                                  width: 88,
                                  height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: accentColor.withOpacity(
                                      0.14 * (1 - _ringPulse.value * 0.6),
                                    ),
                                  ),
                                ),
                              ),

                              // Solid icon disc, bounces in
                              Transform.scale(
                                scale: _iconScale.value,
                                child: Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accentColor,
                                        accentColor.withOpacity(0.75),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accentColor.withOpacity(0.4),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: widget.isSuccess
                                      ? CustomPaint(
                                          painter: _CheckPainter(
                                            progress: _checkProgress.value,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Transform.scale(
                                          scale: _iconScale.value,
                                          child: const Icon(
                                            Icons.priority_high_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            Center(
                              child: AppText(
                                widget.isSuccess
                                    ? "joined_club_title"
                                    : "join_failed_title",
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.isSuccess
                                  ? "joined_club_message".tr
                                  : (widget.errorMessage ??
                                      "something_went_wrong".tr),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: subTextColor,
                                fontSize: 13.5,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => Get.back(),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  elevation: 0,
                                ),
                                child: AppText(
                                  widget.isSuccess ? "great_thanks" : "try_again",
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Draws the animated checkmark stroke-by-stroke as [progress] goes 0 -> 1.
class _CheckPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CheckPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final path = Path()
      ..moveTo(size.width * 0.24, size.height * 0.53)
      ..lineTo(size.width * 0.43, size.height * 0.72)
      ..lineTo(size.width * 0.78, size.height * 0.30);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      final extractLength = metric.length * progress.clamp(0.0, 1.0);
      canvas.drawPath(metric.extractPath(0, extractLength), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// A single confetti dot bursting outward from the center.
class _Particle {
  final double angle;
  final double distance;
  final double size;
  final double delay;
  final Color color;

  const _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.delay,
    required this.color,
  });

  factory _Particle.random(int seed, Color base) {
    final rnd = Random(seed * 7919 + 13);
    final hueShift = rnd.nextBool();
    return _Particle(
      angle: rnd.nextDouble() * 2 * pi,
      distance: 34 + rnd.nextDouble() * 28,
      size: 2.5 + rnd.nextDouble() * 3.5,
      delay: rnd.nextDouble() * 0.25,
      color: hueShift ? base : Colors.amber,
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  final List<_Particle> particles;

  _ConfettiPainter({required this.t, required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in particles) {
      final localT = ((t - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
      if (localT <= 0) continue;

      final eased = Curves.easeOut.transform(localT);
      final dist = p.distance * eased;
      final pos = center + Offset(cos(p.angle), sin(p.angle)) * dist;
      final opacity = (1 - eased).clamp(0.0, 1.0);

      final paint = Paint()..color = p.color.withOpacity(opacity);
      canvas.drawCircle(pos, p.size * (1 - eased * 0.35), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.t != t;
}