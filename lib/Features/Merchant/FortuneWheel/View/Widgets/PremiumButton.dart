import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class PremiumButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onTap;
  final Color color;
  final double height;
  final Color loaderColor;
  final double loaderSize;

  const PremiumButton({
    super.key,
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onTap,
    required this.color,
    this.height = 56,
    this.loaderColor = Colors.white,
    this.loaderSize = 32,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isLoading || onTap == null;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              Color.lerp(color, Colors.black, 0.18)!,
            ],
          ),
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: color.withOpacity(0.38),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: ScaleTransition(scale: anim, child: child),
            ),
            child: isLoading
                ? SizedBox(
                    key: const ValueKey('loading'),
                    height: loaderSize,
                    child: LoadingAnimationWidget.fourRotatingDots(
                      color: loaderColor,
                      size: loaderSize,
                    ),
                  )
                : Row(
                    key: const ValueKey('idle'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 19, color: Colors.white),
                      const SizedBox(width: 10),
                      AppText(
                        label,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}