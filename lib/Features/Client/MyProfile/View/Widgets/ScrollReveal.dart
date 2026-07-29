import 'package:flutter/material.dart';

/// Wraps [child] and plays a premium fade + slide-up + scale entrance
/// animation the first time it scrolls into view. Attach the same
/// [controller] used by the surrounding scroll view — each ScrollReveal
/// tracks its own on-screen position, no extra package required.
///
/// [index] staggers the start delay so a list of cards animates in
/// one after another instead of all at once.
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final int index;
  final double visibleThreshold;

  const ScrollReveal({
    super.key,
    required this.child,
    required this.controller,
    this.index = 0,
    this.visibleThreshold = 0.90,
  });

  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}

class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<Offset> _slide;
  bool _played = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 640),
    );
    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0, 0.75, curve: Curves.easeOut),
    );
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
    );
    _slide = Tween<Offset>(begin: const Offset(0, 0.09), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    widget.controller.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    if (_played || !mounted) return;
    final renderObject = context.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return;
    final position = renderObject.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;
    if (position.dy < screenHeight * widget.visibleThreshold) {
      _played = true;
      Future.delayed(Duration(milliseconds: 70 * widget.index.clamp(0, 10)), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: ScaleTransition(scale: _scale, child: widget.child),
      ),
    );
  }
}