import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CARD
// ─────────────────────────────────────────────────────────────────────────────

class ActiveWheelCard extends StatelessWidget {
  ActiveWheelCard({super.key});

  final _c = Get.find<FortuneController>();
  static const _accent = Color(0xFF2E9E5B);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final active = _c.isWheelActive.value;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(size.width * 0.045),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: isDark ? const Color(0xFF18181B) : Colors.white,
          border: Border.all(
            color: Theme.of(context).colorScheme.surface,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            _CardHeader(
              isDark: isDark,
              size: size,
              accent: _accent,
              active: active,
              onToggle: _c.toggleWheelActive,
            ),

            // ── Animated status box ───────────────────────────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Padding(
                key: ValueKey(active),
                padding: EdgeInsets.only(top: size.height * 0.018),
                child: _StatusBox(
                  isDark: isDark,
                  active: active,
                  accent: _accent,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _CardHeader extends StatelessWidget {
  final bool isDark;
  final Size size;
  final Color accent;
  final bool active;
  final VoidCallback onToggle;

  const _CardHeader({
    required this.isDark,
    required this.size,
    required this.accent,
    required this.active,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon badge
        Container(
          width: size.width * 0.105,
          height: size.width * 0.105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: accent.withOpacity(0.10),
          ),
          child: Icon(
            active ? Iconsax.play_circle : Iconsax.pause_circle,
            color: accent,
            size: size.width * 0.052,
          ),
        ),

        SizedBox(width: size.width * 0.035),

        // Titles
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'active_wheel'.tr,
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 3),
              AppText(
                'active_wheel_subtitle'.tr,
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

        // Premium toggle
        GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            width: 50,
            height: 28,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: active
                  ? accent
                  : isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.black.withOpacity(0.08),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              alignment: active ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATUS BOX
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBox extends StatelessWidget {
  final bool isDark;
  final bool active;
  final Color accent;

  const _StatusBox({
    required this.isDark,
    required this.active,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final color = active
        ? accent
        : (isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.35));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: active
            ? accent.withOpacity(isDark ? 0.10 : 0.06)
            : (isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03)),
        border: active ? Border.all(color: accent.withOpacity(0.20)) : null,
      ),
      child: Row(
        children: [
          Icon(
            active ? Iconsax.tick_circle : Iconsax.info_circle,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              active ? 'wheel_active_info'.tr : 'wheel_inactive_info'.tr,
              fontSize: 12,
              color: active
                  ? accent
                  : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}