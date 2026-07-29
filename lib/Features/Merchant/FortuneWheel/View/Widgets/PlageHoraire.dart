import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CARD
// ─────────────────────────────────────────────────────────────────────────────

class GameTimeSlotCard extends StatelessWidget {
  GameTimeSlotCard({super.key});

  final _c = Get.find<FortuneController>();
  static const _accent = Color(0xFFE8640C);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final enabled = _c.gameTimeEnabled.value;

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
              enabled: enabled,
              onToggle: _c.toggleGameTime,
            ),

            // ── Animated body ────────────────────────────────────────────────
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: enabled
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Padding(
                padding: EdgeInsets.only(top: size.height * 0.018),
                child: _InfoBox(
                  text: 'game_time_info'.tr,
                  isDark: isDark,
                ),
              ),
              secondChild: Padding(
                padding: EdgeInsets.only(top: size.height * 0.022),
                child: Column(
                  children: [
                    // ── Time row ──────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _TimeButton(
                            label: 'start_time'.tr,
                            value: _c.startTime.value,
                            isDark: isDark,
                            onTap: _c.pickStartTime,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.03),
                          child: Column(
                            children: [
                              SizedBox(height: size.height * 0.022),
                              Icon(
                                Iconsax.arrow_right,
                                size: 18,
                                color: isDark
                                    ? Colors.white.withOpacity(0.25)
                                    : Colors.black.withOpacity(0.20),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: _TimeButton(
                            label: 'end_time'.tr,
                            value: _c.endTime.value,
                            isDark: isDark,
                            onTap: _c.pickEndTime,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.018),

                    // ── Active window pill ─────────────────────────────────
                    if (_c.startTime.value.isNotEmpty &&
                        _c.endTime.value.isNotEmpty)
                      _ActiveWindowPill(
                        start: _c.startTime.value,
                        end: _c.endTime.value,
                        isDark: isDark,
                      ),
                  ],
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
  final bool enabled;
  final VoidCallback onToggle;

  const _CardHeader({
    required this.isDark,
    required this.size,
    required this.accent,
    required this.enabled,
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
          child: Icon(Iconsax.timer_1, color: accent, size: size.width * 0.052),
        ),

        SizedBox(width: size.width * 0.035),

        // Titles
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                'game_time_slot'.tr,
                fontSize: size.width * 0.042,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 3),
              AppText(
                'game_time_slot_subtitle'.tr,
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
              color: enabled
                  ? accent
                  : isDark
                      ? Colors.white.withOpacity(0.10)
                      : Colors.black.withOpacity(0.08),
              boxShadow: enabled
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
              alignment:
                  enabled ? Alignment.centerRight : Alignment.centerLeft,
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
// TIME BUTTON  (tappable pill — replaces the old text field)
// ─────────────────────────────────────────────────────────────────────────────

class _TimeButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback onTap;

  static const _accent = Color(0xFFE8640C);

  const _TimeButton({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onTap,
  });

  bool get _hasValue => value.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: AppText(
              label,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? Colors.white.withOpacity(0.45)
                  : Colors.black.withOpacity(0.40),
            ),
          ),

          // Pill
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: _hasValue
                  ? _accent.withOpacity(isDark ? 0.14 : 0.07)
                  : isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03),
              border: Border.all(
                color: _hasValue
                    ? _accent.withOpacity(0.40)
                    : isDark
                        ? Colors.white.withOpacity(0.08)
                        : Colors.black.withOpacity(0.08),
                width: _hasValue ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Iconsax.clock,
                  size: 16,
                  color: _hasValue
                      ? _accent
                      : isDark
                          ? Colors.white.withOpacity(0.25)
                          : Colors.black.withOpacity(0.22),
                ),
                const SizedBox(width: 8),
                Text(
                  _hasValue ? value : '--:--',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: _hasValue
                        ? _accent
                        : isDark
                            ? Colors.white.withOpacity(0.20)
                            : Colors.black.withOpacity(0.18),
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

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE WINDOW PILL
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveWindowPill extends StatelessWidget {
  final String start;
  final String end;
  final bool isDark;

  static const _accent = Color(0xFFE8640C);

  const _ActiveWindowPill({
    required this.start,
    required this.end,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _accent.withOpacity(isDark ? 0.10 : 0.06),
        border: Border.all(color: _accent.withOpacity(0.20)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _accent.withOpacity(0.15),
            ),
            child: const Icon(Iconsax.timer_1, color: _accent, size: 15),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark
                      ? Colors.white.withOpacity(0.50)
                      : Colors.black.withOpacity(0.45),
                ),
                children: [
                  TextSpan(text: '${'wheel_available_from'.tr} '),
                  TextSpan(
                    text: start,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                  TextSpan(text: '  ${'wheel_to'.tr}  '),
                  TextSpan(
                    text: end,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: _accent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// INFO BOX
// ─────────────────────────────────────────────────────────────────────────────

class _InfoBox extends StatelessWidget {
  final String text;
  final bool isDark;

  const _InfoBox({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isDark
            ? Colors.white.withOpacity(0.03)
            : Colors.black.withOpacity(0.03),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            size: 14,
            color: Theme.of(context)
                .textTheme
                .bodySmall
                ?.color
                ?.withOpacity(0.35),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: AppText(
              text,
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color
                  ?.withOpacity(0.55),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM TIME PICKER BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

Future<String?> showPremiumTimePicker(
  BuildContext context, {
  required bool isDark,
  String initialValue = '',
}) {
  int initHour = 9;
  int initMinute = 0;

  if (initialValue.isNotEmpty) {
    final parts = initialValue.split(':');
    if (parts.length == 2) {
      initHour = int.tryParse(parts[0]) ?? 9;
      initMinute = int.tryParse(parts[1]) ?? 0;
    }
  }

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PremiumTimePickerSheet(
      isDark: isDark,
      initialHour: initHour,
      initialMinute: initMinute,
    ),
  );
}

class _PremiumTimePickerSheet extends StatefulWidget {
  final bool isDark;
  final int initialHour;
  final int initialMinute;

  const _PremiumTimePickerSheet({
    required this.isDark,
    required this.initialHour,
    required this.initialMinute,
  });

  @override
  State<_PremiumTimePickerSheet> createState() =>
      _PremiumTimePickerSheetState();
}

class _PremiumTimePickerSheetState extends State<_PremiumTimePickerSheet> {
  static const _accent = Color(0xFFE8640C);

  late int _hour;
  late int _minute;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialHour;
    _minute = widget.initialMinute;
    _hourCtrl = FixedExtentScrollController(initialItem: _hour);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  String get _formatted =>
      '${_hour.toString().padLeft(2, '0')}:${_minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF18181B) : Colors.white;
    final textColor =
        widget.isDark ? Colors.white : const Color(0xFF111111);
    final subtleColor = widget.isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.07);
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.40 : 0.10),
            blurRadius: 32,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: subtleColor,
                ),
              ),
            ),

            // ── Title ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'select_time'.tr,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  // Preview chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _accent.withOpacity(0.12),
                    ),
                    child: Text(
                      _formatted,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _accent,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Drum-roll pickers ─────────────────────────────────────────
            SizedBox(
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Selection highlight
                  Center(
                    child: Container(
                      height: 52,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color: _accent.withOpacity(widget.isDark ? 0.12 : 0.07),
                        border:
                            Border.all(color: _accent.withOpacity(0.22)),
                      ),
                    ),
                  ),

                  // Pickers row
                  Row(
                    children: [
                      // Hours
                      Expanded(
                        child: _Drum(
                          controller: _hourCtrl,
                          itemCount: 24,
                          label: (i) => i.toString().padLeft(2, '0'),
                          onChanged: (v) => setState(() => _hour = v),
                          isDark: widget.isDark,
                          accent: _accent,
                        ),
                      ),

                      // Colon
                      Text(
                        ':',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: _accent,
                          letterSpacing: 0,
                        ),
                      ),

                      // Minutes
                      Expanded(
                        child: _Drum(
                          controller: _minuteCtrl,
                          itemCount: 60,
                          label: (i) => i.toString().padLeft(2, '0'),
                          onChanged: (v) => setState(() => _minute = v),
                          isDark: widget.isDark,
                          accent: _accent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Confirm button ─────────────────────────────────────────────
            Padding(
              padding:
                  EdgeInsets.fromLTRB(20, 0, 20, size.height * 0.025),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(_formatted),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: _accent,
                    boxShadow: [
                      BoxShadow(
                        color: _accent.withOpacity(0.36),
                        blurRadius: 16,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'confirm'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRUM ROLLER
// ─────────────────────────────────────────────────────────────────────────────

class _Drum extends StatelessWidget {
  final FixedExtentScrollController controller;
  final int itemCount;
  final String Function(int) label;
  final ValueChanged<int> onChanged;
  final bool isDark;
  final Color accent;

  const _Drum({
    required this.controller,
    required this.itemCount,
    required this.label,
    required this.onChanged,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: 52,
      perspective: 0.003,
      diameterRatio: 2.2,
      physics: const FixedExtentScrollPhysics(),
      onSelectedItemChanged: onChanged,
      childDelegate: ListWheelChildBuilderDelegate(
        builder: (context, index) {
          if (index < 0 || index >= itemCount) return null;

          return Center(
            child: Text(
              label(index),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111111),
                letterSpacing: 1.0,
              ),
            ),
          );
        },
        childCount: itemCount,
      ),
    );
  }
}