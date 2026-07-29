// fortune_card.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';


class FortuneCard extends StatelessWidget {
  FortuneCard({super.key});

  final controller = Get.find<FortuneController>();

  static const _accent = Color(0xFF3B6D11);

  static const _segmentTypes = [
    {'value': 'gift',         'label': 'segment_type_gift',         'icon': Iconsax.gift},
    {'value': 'discount',     'label': 'segment_type_discount',     'icon': Iconsax.percentage_circle},
    {'value': 'bonus_points', 'label': 'segment_type_bonus_points', 'icon': Iconsax.star_1},
    {'value': 'cashback',     'label': 'segment_type_cashback',     'icon': Iconsax.wallet_money},
    {'value': 'no_win',       'label': 'segment_type_no_win',       'icon': Iconsax.close_circle},
  ];

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
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
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
          // ── HEADER ──────────────────────────────────────
          _FortuneHeader(controller: controller, size: size, isDark: isDark, accent: _accent),

          SizedBox(height: size.height * 0.022),
          Divider(
            height: 1, thickness: 1,
            color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          ),
          SizedBox(height: size.height * 0.018),

          // ── SEGMENTS LIST ────────────────────────────────
          Obx(() {
            if (controller.segments.isEmpty) {
              return _EmptyState(size: size, isDark: isDark, accent: _accent);
            }
            return Column(
              children: List.generate(controller.segments.length, (i) {
                final isLast = i == controller.segments.length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : size.height * 0.014),
                  child: _SegmentRow(
                    key: ValueKey('seg_${i}_${controller.segments[i].hashCode}'),
                    index: i,
                    isDark: isDark,
                    size: size,
                    controller: controller,
                    types: _segmentTypes,
                    accent: _accent,
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// ── HEADER ────────────────────────────────────────────────────────────────────

class _FortuneHeader extends StatelessWidget {
  final FortuneController controller;
  final Size size;
  final bool isDark;
  final Color accent;

  const _FortuneHeader({
    required this.controller,
    required this.size,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon box
        Container(
          width: size.width * 0.105,
          height: size.width * 0.105,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: accent.withOpacity(0.10),
          ),
          child: Icon(Iconsax.candle_2, color: accent, size: size.width * 0.052),
        ),
        SizedBox(width: size.width * 0.035),

        // Title + subtitle
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => AppText(
                    "fortune_segments_title".trParams({
                      "current": controller.segments.length.toString(),
                      "max": FortuneController.maxSegments.toString(),
                    }),
                    fontSize: size.width * 0.042,
                    fontWeight: FontWeight.w700,
                  )),
              const SizedBox(height: 3),
              AppText(
                "fortune_segments_subtitle".tr,
                fontSize: size.width * 0.029,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.50),
              ),
            ],
          ),
        ),

        // Add button
        Obx(() {
          final canAdd = controller.canAdd;
          return GestureDetector(
            onTap: canAdd ? controller.addSegment : null,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: canAdd ? 1.0 : 0.4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.add_circle, size: 15, color: accent),
                    const SizedBox(width: 5),
                    AppText(
                      "add_segment".tr,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: accent,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

// ── SEGMENT ROW ───────────────────────────────────────────────────────────────

class _SegmentRow extends StatelessWidget {
  final int index;
  final bool isDark;
  final Size size;
  final FortuneController controller;
  final List<Map<String, Object>> types;
  final Color accent;

  const _SegmentRow({
    super.key,
    required this.index,
    required this.isDark,
    required this.size,
    required this.controller,
    required this.types,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final seg = controller.segments[index];

      return AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
          border: Border.all(
            color: seg.color.withOpacity(0.28),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: seg.color.withOpacity(isDark ? 0.08 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [

    // ── ROW 1: index badge · name field (full width) · color · delete ──
    Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.038,
        vertical: size.width * 0.026,
      ),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        color: seg.color.withOpacity(isDark ? 0.07 : 0.04),
      ),
      child: Row(
        children: [
          // Index badge
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(shape: BoxShape.circle, color: seg.color),
            child: Center(
              child: AppText('${index + 1}', fontSize: 11,
                  fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          SizedBox(width: size.width * 0.025),

          // Name field — takes all remaining space
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: seg.nameController,
                style: TextStyle(
                  fontSize: size.width * 0.033,
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: "segment_name_hint".tr,
                  hintStyle: TextStyle(
                    fontSize: size.width * 0.030,
                    color: isDark
                        ? Colors.white.withOpacity(0.22)
                        : Colors.black.withOpacity(0.20),
                    fontWeight: FontWeight.w400,
                  ),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.04)
                      : Colors.black.withOpacity(0.03),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white.withOpacity(0.07)
                          : Colors.black.withOpacity(0.07),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide:
                        BorderSide(color: seg.color.withOpacity(0.60), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: size.width * 0.020),

          // Color picker
          GestureDetector(
            onTap: () => _pickColor(context, index, seg.color),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: seg.color,
                boxShadow: [
                  BoxShadow(color: seg.color.withOpacity(0.40),
                      blurRadius: 8, offset: const Offset(0, 2)),
                ],
              ),
              child: const Icon(Iconsax.colorfilter, color: Colors.white, size: 16),
            ),
          ),
          SizedBox(width: size.width * 0.020),

          // Delete
          GestureDetector(
            onTap: () => controller.removeSegment(index),
            child: Container(
              width: 38, height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red.withOpacity(0.07),
              ),
              child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 16),
            ),
          ),
        ],
      ),
    ),

    // ── ROW 2: type dropdown — full width ──
    Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.038, size.width * 0.028,
        size.width * 0.038, 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            "segment_type_label".tr,
            fontSize: size.width * 0.026,
            color: isDark
                ? Colors.white.withOpacity(0.30)
                : Colors.black.withOpacity(0.30),
          ),
          const SizedBox(height: 5),
          Container(
            height: 40,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.025),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.04),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.06),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: seg.type,
                isExpanded: true,
                dropdownColor: isDark ? const Color(0xFF1F1F23) : Colors.white,
                icon: Icon(Iconsax.arrow_down, size: 13,
                    color: isDark
                        ? Colors.white.withOpacity(0.35)
                        : Colors.black.withOpacity(0.30)),
                style: TextStyle(
                  fontSize: size.width * 0.030,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                items: types
                    .map((t) => DropdownMenuItem<String>(
                          value: t['value'] as String,
                          child: Row(children: [
                            Icon(t['icon'] as IconData, size: 14, color: seg.color),
                            const SizedBox(width: 6),
                            AppText((t['label'] as String).tr,
                                fontSize: size.width * 0.029,
                                fontWeight: FontWeight.w600),
                          ]),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.updateSegmentType(index, v);
                },
              ),
            ),
          ),
        ],
      ),
    ),

    // ── ROW 3: % Win · Max Winners — each takes 50% ──
    Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.038, size.width * 0.018,
        size.width * 0.038, size.width * 0.020,
      ),
      child: Row(
        children: [
          // Win %
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  "segment_win_pct".tr,
                  fontSize: size.width * 0.026,
                  color: isDark
                      ? Colors.white.withOpacity(0.30)
                      : Colors.black.withOpacity(0.30),
                ),
                const SizedBox(height: 5),
                SizedBox(
                  height: 40,
                  child: TextField(
                    controller: seg.percentController,
                    keyboardType: TextInputType.number,
                    onChanged: (v) => controller.updateSegmentPercent(index, v),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: size.width * 0.033,
                      fontWeight: FontWeight.w700,
                      color: seg.color,
                    ),
                    decoration: InputDecoration(
                      hintText: "0",
                      hintStyle: TextStyle(
                        fontSize: size.width * 0.029,
                        color: isDark
                            ? Colors.white.withOpacity(0.20)
                            : Colors.black.withOpacity(0.18),
                      ),
                      suffixText: "%",
                      suffixStyle: TextStyle(
                          color: seg.color,
                          fontWeight: FontWeight.w700,
                          fontSize: size.width * 0.030),
                      isDense: true,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                      filled: true,
                      fillColor: seg.color.withOpacity(0.07),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: seg.color.withOpacity(0.22)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: seg.color.withOpacity(0.55), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Max Winners (hidden for no_win)
          if (seg.type != 'no_win') ...[
            SizedBox(width: size.width * 0.030),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    "segment_max_winners".tr,
                    fontSize: size.width * 0.026,
                    color: isDark
                        ? Colors.white.withOpacity(0.30)
                        : Colors.black.withOpacity(0.30),
                  ),
                  const SizedBox(height: 5),
                  SizedBox(
                    height: 40,
                    child: TextField(
                      controller: seg.maxWinnersController,
                      keyboardType: TextInputType.number,
                      onChanged: (v) => controller.updateMaxWinners(index, v),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: size.width * 0.030,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: "∞",
                        hintStyle: TextStyle(
                          fontSize: size.width * 0.030,
                          color: isDark
                              ? Colors.white.withOpacity(0.20)
                              : Colors.black.withOpacity(0.18),
                        ),
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.black.withOpacity(0.03),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white.withOpacity(0.07)
                                : Colors.black.withOpacity(0.07),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: seg.color.withOpacity(0.55), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),

            // ── LABELS ROW ───────────────────────────────
            

            // ── EXTRA FIELD by type ──────────────────────
            if (seg.type == 'discount') ...[
              _ExtraField(
                controller: seg.discountController,
                hint: "reward_discount_hint".tr,
                suffix: "%",
                label: "segment_discount_label".tr,
                color: seg.color,
                isDark: isDark,
                size: size,
              ),
            ] else if (seg.type == 'bonus_points') ...[
              _ExtraField(
                controller: seg.pointsController,
                hint: "reward_points_hint".tr,
                suffix: "pts",
                label: "segment_points_label".tr,
                color: seg.color,
                isDark: isDark,
                size: size,
              ),
            ] else if (seg.type == 'cashback') ...[
              _ExtraField(
                controller: seg.cashbackController,
                hint: "reward_cashback_hint".tr,
                suffix: "€",
                label: "segment_cashback_label".tr,
                color: seg.color,
                isDark: isDark,
                size: size,
              ),
            ],
          ],
        ),
      );
    });
  }

  void _pickColor(BuildContext context, int index, Color current) {
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Grouped palette for a curated, intentional feel
  final groups = <String, List<Color>>{
    'Nature':   [const Color(0xFF3B6D11), const Color(0xFF4CAF50), const Color(0xFF2EE0A0), const Color(0xFF00BCD4)],
    'Vivid':    [const Color(0xFF2E6BE0), const Color(0xFF2EB0E0), const Color(0xFFB02EE0), const Color(0xFF9C27B0)],
    'Warm':     [const Color(0xFFE07B2E), const Color(0xFFFF9800), const Color(0xFFE0C82E), const Color(0xFFFF5252)],
    'Bold':     [const Color(0xFFE02E6B), const Color(0xFFE91E63), const Color(0xFF795548), const Color(0xFF607D8B)],
  };

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) {
      Color selected = current;

      return StatefulBuilder(
        builder: (ctx, setState) {
          return SafeArea(child:  Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1C1F) : const Color(0xFFF9F9FB),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.07)
                      : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Drag handle ──
                Center(
                  child: Container(
                    width: 36, height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.10),
                    ),
                  ),
                ),

                // ── Header ──
                Row(
                  children: [
                    // Selected color live preview
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: selected,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: selected.withOpacity(0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("pick_color".tr,
                            fontSize: 16, fontWeight: FontWeight.w700),
                        const SizedBox(height: 2),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: AppText(
                            '#${selected.value.toRadixString(16).toUpperCase().substring(2)}',
                            key: ValueKey(selected.value),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? Colors.white.withOpacity(0.35)
                                : Colors.black.withOpacity(0.35),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? Colors.white.withOpacity(0.07)
                              : Colors.black.withOpacity(0.06),
                        ),
                        child: Icon(
                          Iconsax.close_circle,
                          size: 16,
                          color: isDark
                              ? Colors.white.withOpacity(0.50)
                              : Colors.black.withOpacity(0.40),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ── Color groups ──
                ...groups.entries.map((group) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AppText(
                            group.key,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white.withOpacity(0.30)
                                : Colors.black.withOpacity(0.30),
                          ),
                        ),
                        // Color swatches row
                        Row(
                          children: group.value.map((c) {
                            final isSelected = c.value == selected.value;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => selected = c);
                                  Future.delayed(
                                    const Duration(milliseconds: 180),
                                    () {
                                      controller.updateSegmentColor(index, c);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: c,
                                    borderRadius: BorderRadius.circular(14),
                                    border: isSelected
                                        ? Border.all(color: Colors.white, width: 2.5)
                                        : Border.all(color: Colors.transparent, width: 2.5),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: c.withOpacity(0.55),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: c.withOpacity(0.20),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  );
                }),

              ],
            ),
          ));
        },
      );
    },
  );
}
}

// ── EXTRA FIELD ───────────────────────────────────────────────────────────────

class _ExtraField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String suffix;
  final String label;
  final Color color;
  final bool isDark;
  final Size size;

  const _ExtraField({
    required this.controller,
    required this.hint,
    required this.suffix,
    required this.label,
    required this.color,
    required this.isDark,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        size.width * 0.038, 0,
        size.width * 0.038, size.width * 0.028,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            label,
            fontSize: size.width * 0.027,
            color: isDark ? Colors.white.withOpacity(0.35) : Colors.black.withOpacity(0.35),
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 38,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                fontSize: size.width * 0.033,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontSize: size.width * 0.030,
                  color: isDark
                      ? Colors.white.withOpacity(0.22)
                      : Colors.black.withOpacity(0.20),
                ),
                suffixText: suffix,
                suffixStyle: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: size.width * 0.030,
                ),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                filled: true,
                fillColor: color.withOpacity(0.06),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color.withOpacity(0.20)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: color.withOpacity(0.55), width: 1.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final Size size;
  final bool isDark;
  final Color accent;

  const _EmptyState({
    required this.size,
    required this.isDark,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: size.height * 0.035),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withOpacity(0.025) : Colors.grey.withOpacity(0.04),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: size.width * 0.14,
            height: size.width * 0.14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withOpacity(0.08),
            ),
            child: Icon(
              Iconsax.candle_2,
              size: size.width * 0.07,
              color: isDark ? Colors.white.withOpacity(0.15) : Colors.black.withOpacity(0.12),
            ),
          ),
          SizedBox(height: size.height * 0.013),
          AppText(
            "no_segments".tr,
            fontSize: size.width * 0.034,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white.withOpacity(0.30) : Colors.black.withOpacity(0.30),
          ),
          SizedBox(height: size.height * 0.005),
          AppText(
            "add_first_segment".tr,
            fontSize: size.width * 0.028,
            color: isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.18),
          ),
        ],
      ),
    );
  }
}