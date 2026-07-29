import 'package:flutter/material.dart';

class FadeSlide extends StatefulWidget {
  final Widget child;
  final int delayMs;

  /// Vertical movement (positive = comes from bottom)
  final double dy;

  final Duration duration;
  final Curve curve;

  const FadeSlide({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.dy = 20,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeOutCubic,
  });

  @override
  State<FadeSlide> createState() => _FadeSlideState();
}

class _FadeSlideState extends State<FadeSlide> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1 : 0,
      duration: widget.duration,
      curve: widget.curve,
      child: AnimatedSlide(
        offset: _visible
            ? Offset.zero
            : Offset(0, widget.dy / 100),
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}