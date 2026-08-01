import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENTRY POINT
// ─────────────────────────────────────────────────────────────────────────────

Future<DateTime?> showPremiumDatePicker(
  BuildContext context, {
  required bool isDark,
  DateTime? initialDate,
  DateTime? firstDate,
  DateTime? lastDate,
  required Color accent,
}) {
  final now = DateTime.now();
  return showModalBottomSheet<DateTime>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PremiumCalendarSheet(
      isDark: isDark,
      accent: accent,
      initialDate: initialDate ?? now,
      firstDate: firstDate ?? DateTime(now.year - 2),
      lastDate: lastDate ?? now,
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumCalendarSheet extends StatefulWidget {
  final bool isDark;
  final Color accent;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  const _PremiumCalendarSheet({
    required this.isDark,
    required this.accent,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  @override
  State<_PremiumCalendarSheet> createState() => _PremiumCalendarSheetState();
}

class _PremiumCalendarSheetState extends State<_PremiumCalendarSheet> {
  late DateTime _visibleMonth;
  late DateTime _selected;

  static const _monthKeys = [
    'month_1', 'month_2', 'month_3', 'month_4', 'month_5', 'month_6',
    'month_7', 'month_8', 'month_9', 'month_10', 'month_11', 'month_12',
  ];
  static const _dayKeys = [
    'day_mon', 'day_tue', 'day_wed', 'day_thu', 'day_fri', 'day_sat', 'day_sun',
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialDate;
    _visibleMonth = DateTime(widget.initialDate.year, widget.initialDate.month);
  }

  bool get _canGoPrev {
    final prevMonthEnd = DateTime(_visibleMonth.year, _visibleMonth.month, 0);
    return !prevMonthEnd.isBefore(widget.firstDate);
  }

  bool get _canGoNext {
    final nextMonthStart =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 1);
    return !nextMonthStart.isAfter(widget.lastDate);
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isSelectable(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    final first = DateTime(widget.firstDate.year, widget.firstDate.month, widget.firstDate.day);
    final last = DateTime(widget.lastDate.year, widget.lastDate.month, widget.lastDate.day);
    return !d.isBefore(first) && !d.isAfter(last);
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.isDark ? const Color(0xFF18181B) : Colors.white;
    final textColor = widget.isDark ? Colors.white : const Color(0xFF111111);
    final subtleColor = widget.isDark
        ? Colors.white.withOpacity(0.10)
        : Colors.black.withOpacity(0.07);
    final accent = widget.accent;
    final today = DateTime.now();

    final firstOfMonth = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth =
        DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // Monday = 1 ... Sunday = 7 → leading blanks before day 1
    final leadingBlanks = firstOfMonth.weekday - 1;

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

            // ── Title ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'select_date'.tr,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: accent.withOpacity(0.12),
                    ),
                    child: Text(
                      '${_selected.day.toString().padLeft(2, '0')}/${_selected.month.toString().padLeft(2, '0')}/${_selected.year}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: accent,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Month navigation ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavArrow(
                    icon: Iconsax.arrow_circle_left_copy,
                    enabled: _canGoPrev,
                    isDark: widget.isDark,
                    onTap: () => _changeMonth(-1),
                  ),
                  Text(
                    '${_monthKeys[_visibleMonth.month - 1].tr} ${_visibleMonth.year}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  _NavArrow(
                    icon: Iconsax.arrow_circle_right_copy,
                    enabled: _canGoNext,
                    isDark: widget.isDark,
                    onTap: () => _changeMonth(1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Weekday header ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: _dayKeys
                    .map((k) => Expanded(
                          child: Center(
                            child: Text(
                              k.tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: widget.isDark
                                    ? Colors.white.withOpacity(0.30)
                                    : Colors.black.withOpacity(0.30),
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 6),

            // ── Day grid ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leadingBlanks + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  if (index < leadingBlanks) return const SizedBox.shrink();

                  final dayNum = index - leadingBlanks + 1;
                  final day = DateTime(
                      _visibleMonth.year, _visibleMonth.month, dayNum);
                  final selectable = _isSelectable(day);
                  final isSelected = _isSameDay(day, _selected);
                  final isToday = _isSameDay(day, today);

                  return Padding(
                    padding: const EdgeInsets.all(3),
                    child: GestureDetector(
                      onTap: selectable
                          ? () => setState(() => _selected = day)
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? accent
                              : (isToday
                                  ? accent.withOpacity(0.12)
                                  : Colors.transparent),
                          border: isToday && !isSelected
                              ? Border.all(color: accent.withOpacity(0.45))
                              : null,
                        ),
                        child: Center(
                          child: Text(
                            '$dayNum',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight:
                                  isSelected ? FontWeight.w800 : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : !selectable
                                      ? (widget.isDark
                                          ? Colors.white.withOpacity(0.15)
                                          : Colors.black.withOpacity(0.15))
                                      : (isToday
                                          ? accent
                                          : textColor.withOpacity(0.85)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Confirm button ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(_selected),
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: accent,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.36),
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

class _NavArrow extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isDark;
  final VoidCallback onTap;

  const _NavArrow({
    required this.icon,
    required this.enabled,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.25,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
          child: Icon(icon, size: 15),
        ),
      ),
    );
  }
}