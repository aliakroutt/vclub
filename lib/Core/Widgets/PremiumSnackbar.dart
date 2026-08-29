// lib/Core/Widgets/PremiumSnackbar.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

enum SnackType { success, info, warning, error }

class PremiumSnackbar {
  static void show({
    required String title,
    required String message,
    SnackType type = SnackType.info,
    Duration duration = const Duration(seconds: 5),
  }) {
    final meta = _metaFor(type);

    Get.rawSnackbar(
      messageText: _SnackbarContent(title: title, message: message, meta: meta),
      backgroundColor: Colors.transparent,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: 20,
      duration: duration,
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeIn,
      snackStyle: SnackStyle.FLOATING,
      padding: EdgeInsets.zero,
      boxShadows: [
        BoxShadow(
          color: meta.color.withOpacity(0.35),
          blurRadius: 24,
          spreadRadius: -6,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  static _SnackMeta _metaFor(SnackType type) {
    switch (type) {
      case SnackType.success:
        return _SnackMeta(Iconsax.tick_circle, const Color(0xFF2ECC71));
      case SnackType.warning:
        return _SnackMeta(Iconsax.warning_2_copy, const Color(0xFFF2A93B));
      case SnackType.error:
        return _SnackMeta(Iconsax.close_circle_copy, const Color(0xFFE05C5C));
      case SnackType.info:
      return _SnackMeta(Iconsax.info_circle_copy, const Color(0xFF6C5CE7));
    }
  }
}

class _SnackMeta {
  final IconData icon;
  final Color color;
  _SnackMeta(this.icon, this.color);
}

class _SnackbarContent extends StatelessWidget {
  final String title;
  final String message;
  final _SnackMeta meta;

  const _SnackbarContent({
    required this.title,
    required this.message,
    required this.meta,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(
          color: meta.color.withOpacity(0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [meta.color, Color.lerp(meta.color, Colors.black, 0.15)!],
              ),
              boxShadow: [
                BoxShadow(
                  color: meta.color.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(meta.icon, color: Colors.white, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppText(
                  title,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                const SizedBox(height: 2),
                AppText(
                  message,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Get.closeCurrentSnackbar(),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.05),
              ),
              child: Icon(
                Iconsax.close_circle_copy,
                size: 16,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}