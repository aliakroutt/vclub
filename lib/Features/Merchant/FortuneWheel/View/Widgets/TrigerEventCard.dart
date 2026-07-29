// trigger_events_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';



// ── Trigger meta ──────────────────────────────────────────────────────────────

class _TriggerMeta {
  final String id;
  final IconData icon;
  final String titleKey;
  final String descKey;
  final Color color;

  const _TriggerMeta({
    required this.id,
    required this.icon,
    required this.titleKey,
    required this.descKey,
    required this.color,
  });
}

const _kTriggers = [
  _TriggerMeta(
    id: 'purchase',
    icon: Iconsax.bag_tick,
    titleKey: 'trigger_after_purchase',
    descKey: 'trigger_after_purchase_desc',
    color: Color(0xFF3B6D11),
  ),
  _TriggerMeta(
    id: 'registration',
    icon: Iconsax.profile_add,
    titleKey: 'trigger_after_registration',
    descKey: 'trigger_after_registration_desc',
    color: Color(0xFF2E6BE0),
  ),
  _TriggerMeta(
    id: 'google_review',
    icon: Iconsax.star_1,
    titleKey: 'trigger_google_review',
    descKey: 'trigger_google_review_desc',
    color: Color(0xFFE07B2E),
  ),
  _TriggerMeta(
    id: 'special_event',
    icon: Iconsax.gift,
    titleKey: 'trigger_special_event',
    descKey: 'trigger_special_event_desc',
    color: Color(0xFFB02EE0),
  ),
];

// ── Card ──────────────────────────────────────────────────────────────────────

class TriggerEventsCard extends StatelessWidget {
  TriggerEventsCard({super.key});

  static const _accent = Color(0xFF3B6D11);

  final _c = Get.find<FortuneController>();

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────────────────
          _TriggerHeader(size: size, isDark: isDark, accent: _accent),

          SizedBox(height: size.height * 0.022),
          Divider(
            height: 1, thickness: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
          SizedBox(height: size.height * 0.018),

          // ── List ────────────────────────────────────────────────────────────
          Obx(() {
            final selected = _c.selectedTriggers;
            return Column(
              children: List.generate(_kTriggers.length, (i) {
                final t = _kTriggers[i];
                final isLast = i == _kTriggers.length - 1;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: isLast ? 0 : size.height * 0.014),
                  child: _TriggerTile(
                    meta: t,
                    isSelected: selected.contains(t.id),
                    isDark: isDark,
                    size: size,
                    onTap: () => _c.toggleTrigger(t.id),
                  ),
                );
              }),
            );
          }),

          // ── Selection badge ──────────────────────────────────────────────────
          Obx(() {
            final count = _c.selectedTriggers.length;
            if (count == 0) return const SizedBox.shrink();
            return Padding(
              padding: EdgeInsets.only(top: size.height * 0.018),
              child: _SelectionBadge(
                count: count,
                total: _kTriggers.length,
                size: size,
                isDark: isDark,
                accent: _accent,
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _TriggerHeader extends StatelessWidget {
  final Size size;
  final bool isDark;
  final Color accent;

  const _TriggerHeader({
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
          child: Icon(Iconsax.flash_1, color: accent, size: size.width * 0.052),
        ),
        SizedBox(width: size.width * 0.035),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'trigger_events_title'.tr,
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 3),
              AppText(
                'trigger_events_subtitle'.tr,
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

// ── Tile ──────────────────────────────────────────────────────────────────────

class _TriggerTile extends StatelessWidget {
  final _TriggerMeta meta;
  final bool isSelected;
  final bool isDark;
  final Size size;
  final VoidCallback onTap;

  const _TriggerTile({
    required this.meta,
    required this.isSelected,
    required this.isDark,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = meta.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isSelected
              ? color.withOpacity(isDark ? 0.14 : 0.07)
              : (isDark ? const Color(0xFF1A1A1E) : const Color(0xFFF8F8FA)),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.60)
                : (isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.07)),
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(isDark ? 0.20 : 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.10 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // Glow blob top-right (selected only)
              if (isSelected)
                Positioned(
                  top: -20,
                  right: -20,
                  child: Container(
                    width: size.width * 0.28,
                    height: size.width * 0.28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(isDark ? 0.10 : 0.07),
                    ),
                  ),
                ),

              // Content row
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.042,
                  vertical: size.width * 0.036,
                ),
                child: Row(
                  children: [
                    // Icon box
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: size.width * 0.118,
                      height: size.width * 0.118,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: isSelected
                            ? color.withOpacity(0.20)
                            : color.withOpacity(0.10),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.28),
                                  blurRadius: 10,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                            : [],
                      ),
                      child: Icon(meta.icon,
                          color: color, size: size.width * 0.056),
                    ),

                    SizedBox(width: size.width * 0.038),

                    // Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            meta.titleKey.tr,
                            fontSize: size.width * 0.036,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? color
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                          SizedBox(height: size.height * 0.004),
                          AppText(
                            meta.descKey.tr,
                            fontSize: size.width * 0.028,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? Colors.white
                                    .withOpacity(isSelected ? 0.50 : 0.28)
                                : Colors.black
                                    .withOpacity(isSelected ? 0.45 : 0.26),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: size.width * 0.030),

                    // Checkmark
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (child, anim) =>
                          ScaleTransition(scale: anim, child: child),
                      child: isSelected
                          ? Container(
                              key: const ValueKey('on'),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: color,
                                boxShadow: [
                                  BoxShadow(
                                    color: color.withOpacity(0.40),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 14),
                            )
                          : Container(
                              key: const ValueKey('off'),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.15)
                                      : Colors.black.withOpacity(0.12),
                                  width: 1.5,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Selection badge ───────────────────────────────────────────────────────────

class _SelectionBadge extends StatelessWidget {
  final int count;
  final int total;
  final Size size;
  final bool isDark;
  final Color accent;

  const _SelectionBadge({
    required this.count,
    required this.total,
    required this.size,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.038,
        vertical: size.width * 0.028,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: accent.withOpacity(isDark ? 0.12 : 0.07),
        border: Border.all(color: accent.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.15),
            ),
            child: Icon(Iconsax.tick_circle, color: accent, size: 15),
          ),
          SizedBox(width: size.width * 0.028),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$count/$total  ',
                  style: TextStyle(
                    fontSize: size.width * 0.034,
                    fontWeight: FontWeight.w800,
                    color: accent,
                  ),
                ),
                TextSpan(
                  text: 'triggers_selected'.tr,
                  style: TextStyle(
                    fontSize: size.width * 0.030,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? Colors.white.withOpacity(0.48)
                        : Colors.black.withOpacity(0.42),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}