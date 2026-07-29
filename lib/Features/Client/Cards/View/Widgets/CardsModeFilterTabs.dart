import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';

class CardModeFilterTabs extends StatelessWidget {
  const CardModeFilterTabs({super.key});

  static const _modes = ["all", "points", "stamps", "cashback"];

  IconData _iconFor(String mode) {
    switch (mode) {
      case "points":
        return Iconsax.star_1;
      case "stamps":
        return Iconsax.award;
      case "cashback":
        return Iconsax.money_recive;
      default:
        return Iconsax.grid_5;
    }
  }

  Color _colorFor(String mode, ColorScheme scheme) {
    switch (mode) {
      case "points":
        return const Color(0xFFFFB300);
      case "stamps":
        return const Color(0xFF29B6F6);
      case "cashback":
        return const Color(0xFF4CAF50);
      default:
        return scheme.primary;
    }
  }

  String _labelFor(String mode) {
    switch (mode) {
      case "points":
        return "filter_points_client".tr;
      case "stamps":
        return "filter_stamps_client".tr;
      case "cashback":
        return "filter_cashback_client".tr;
      default:
        return "filter_all_client".tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ClientCardsController.to;

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 2),
        itemCount: _modes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final mode = _modes[index];
          return _FilterChip(
            mode: mode,
            icon: _iconFor(mode),
            label: _labelFor(mode),
            color: _colorFor(mode, Theme.of(context).colorScheme),
            controller: controller,
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String mode;
  final IconData icon;
  final String label;
  final Color color;
  final ClientCardsController controller;

  const _FilterChip({
    required this.mode,
    required this.icon,
    required this.label,
    required this.color,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Obx(() {
      final isActive = controller.modeFilter.value == mode;
      final count = controller.countForMode(mode);

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => controller.setModeFilter(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: isActive
                  ? LinearGradient(
                      colors: [color, Color.lerp(color, Colors.black, 0.15)!],
                    )
                  : null,
              color: isActive
                  ? null
                  : (isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.035)),
              border: Border.all(
                color: isActive
                    ? Colors.transparent
                    : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.07)),
                width: 1.2,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.35),
                        blurRadius: 14,
                        spreadRadius: -3,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isActive
                      ? Colors.white
                      : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                ),
                const SizedBox(width: 6),
                AppText(
                  label,
                  fontSize: 12.5,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                  color: isActive
                      ? Colors.white
                      : theme.textTheme.bodySmall?.color?.withOpacity(0.75),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 5),
                  AppText(
                      "$count",
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : color,
                    ),
                
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}