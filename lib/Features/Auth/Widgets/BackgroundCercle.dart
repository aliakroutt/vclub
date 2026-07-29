import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class BackgroundCircle extends StatelessWidget {
  final double size;
  final double innerSize;
  final double opacity;

  const BackgroundCircle({
    super.key,
    required this.size,
    required this.innerSize,
    this.opacity = 0.08,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Get.isDarkMode;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// OUTER CIRCLE (primary soft glow)
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(opacity),
            ),
          ),

          /// INNER CIRCLE (adaptive for theme)
          Container(
            width: innerSize,
            height: innerSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withOpacity(0.04) // soft glow in dark mode
                  : Colors.white, // clean in light mode
              border: isDark
                  ? Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}