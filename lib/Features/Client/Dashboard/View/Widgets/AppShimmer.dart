import 'package:flutter/material.dart';

/// Reusable shimmer wrapper — wrap any placeholder skeleton with this
/// to get a sliding highlight animation. No external package needed.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final bool isDark;
  const AppShimmer({super.key, required this.child, required this.isDark});

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.isDark ? Colors.white10 : Colors.black12;
    final highlightColor = widget.isDark
        ? Colors.white.withOpacity(0.25)
        : Colors.white.withOpacity(0.9);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.35, 0.5, 0.65],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 3 - 1.5),
      0.0,
      0.0,
    );
  }
}

/// Small generic block placeholder — a rounded rectangle in the shimmer base color.
class ShimmerBlock extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final bool isDark;

  const ShimmerBlock({
    super.key,
    required this.width,
    required this.height,
    this.radius = 6,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: isDark ? Colors.white12 : Colors.grey.shade300,
      ),
    );
  }
}