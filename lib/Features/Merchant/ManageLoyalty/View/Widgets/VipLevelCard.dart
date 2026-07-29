import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';

class VIPLevelsCard extends StatelessWidget {
  VIPLevelsCard({super.key});

  final controller = Get.find<LoyaltyModeController>();
  static const Color blue = Color(0xFF3B82F6);

  final List<Map<String, dynamic>> defaultLevels = [
    {"key": "bronze",   "name": "vip_bronze",   "color": const Color(0xFFCD7F32)},
    {"key": "silver",   "name": "vip_silver",   "color": const Color(0xFFB0BEC5)},
    {"key": "gold",     "name": "vip_gold",     "color": const Color(0xFFFFC107)},
    {"key": "platinum", "name": "vip_platinum", "color": const Color(0xFFE5E4E2)},
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * 0.045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.07)
              : Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.06),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── HEADER ──────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * 0.11,
                height: size.width * 0.11,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [blue.withOpacity(0.25), blue.withOpacity(0.08)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: blue.withOpacity(0.2)),
                ),
                child: Icon(Iconsax.crown, color: blue, size: size.width * 0.052),
              ),
              SizedBox(width: size.width * 0.035),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      "vip_levels".tr,
                      fontSize: size.width * 0.043,
                      fontWeight: FontWeight.w700,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "vip_levels_subtitle".tr,
                      fontSize: size.width * 0.030,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(0.45),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: blue.withOpacity(0.1),
                  border: Border.all(color: blue.withOpacity(0.2)),
                ),
                child: AppText(
                  "${defaultLevels.length} ${"levels".tr}",
                  fontSize: size.width * 0.027,
                  fontWeight: FontWeight.w600,
                  color: blue,
                ),
              ),
            ],
          ),

       



SizedBox(height: size.height * 0.022),
          /// ── LEVELS ──────────────────────────────
          ...List.generate(defaultLevels.length, (index) {
            final level = defaultLevels[index];
            final isLast = index == defaultLevels.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : size.height * 0.014),
              child: _VipLevelItem(
                size: size,
                isDark: isDark,
                index: index,
                levelKey: level["key"],
                titleKey: level["name"],
                defaultColor: level["color"],
                controller: controller,
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// ─────────────────────────────────────────────
/// ITEM
/// ─────────────────────────────────────────────
class _VipLevelItem extends StatefulWidget {
  final Size size;
  final bool isDark;
  final int index;
  final String levelKey;
  final String titleKey;
  final Color defaultColor;
  final LoyaltyModeController controller;

  const _VipLevelItem({
    required this.size,
    required this.isDark,
    required this.index,
    required this.levelKey,
    required this.titleKey,
    required this.defaultColor,
    required this.controller,
  });

  @override
  State<_VipLevelItem> createState() => _VipLevelItemState();
}

class _VipLevelItemState extends State<_VipLevelItem> {
  bool _showColorPicker = false;

  static const List<Color> _palette = [
    Color(0xFFCD7F32), // bronze
    Color(0xFFB0BEC5), // silver
    Color(0xFFFFC107), // gold
    Color(0xFFE5E4E2), // platinum
    Color(0xFF3B82F6), // blue
    Color(0xFF8B5CF6), // violet
    Color(0xFF10B981), // emerald
    Color(0xFFEF4444), // red
    Color(0xFFF97316), // orange
    Color(0xFFEC4899), // pink
    Color(0xFF06B6D4), // cyan
    Color(0xFFA3E635), // lime
  ];

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final isDark = widget.isDark;

    final nameCtrl =
        widget.controller.vipNameControllers[widget.levelKey] ??
            TextEditingController(text: widget.titleKey.tr);
    final pointsCtrl =
        widget.controller.vipPointsControllers[widget.levelKey] ??
            TextEditingController();

    widget.controller.vipNameControllers[widget.levelKey] = nameCtrl;
    widget.controller.vipPointsControllers[widget.levelKey] = pointsCtrl;

    /// GetBuilder rebuilds whenever controller.update() is called
    return GetBuilder<LoyaltyModeController>(
      builder: (ctrl) {
        final activeColor =
            ctrl.vipColors[widget.levelKey] ?? widget.defaultColor;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: _showColorPicker
                  ? activeColor.withOpacity(0.4)
                  : isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.05),
              width: _showColorPicker ? 1.5 : 1,
            ),
            boxShadow: _showColorPicker
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.12),
                      blurRadius: 20,
                      spreadRadius: 1,
                    )
                  ]
                : [],
          ),
          child: Column(
            children: [
              /// ── MAIN ROW ──
              Padding(
                padding: EdgeInsets.all(s.width * 0.035),
                child: Row(
                  children: [
                    /// Index badge
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: activeColor.withOpacity(0.15),
                      ),
                      child: Center(
                        child: AppText(
                          "${widget.index + 1}",
                          fontSize: s.width * 0.028,
                          fontWeight: FontWeight.w800,
                          color: activeColor,
                        ),
                      ),
                    ),

                    SizedBox(width: s.width * 0.028),

                    /// Name field
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: s.width * 0.035,
                          letterSpacing: -0.2,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.titleKey.tr,
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.25)
                                : Colors.black.withOpacity(0.25),
                            fontWeight: FontWeight.w500,
                            fontSize: s.width * 0.035,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),

                    SizedBox(width: s.width * 0.02),

                    /// Color swatch button
                    GestureDetector(
                      onTap: () =>
                          setState(() => _showColorPicker = !_showColorPicker),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: activeColor.withOpacity(0.12),
                          border: Border.all(
                            color: activeColor
                                .withOpacity(_showColorPicker ? 0.6 : 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: activeColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: activeColor.withOpacity(0.5),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            AppText(
                              "#${activeColor.value.toRadixString(16).substring(2).toUpperCase()}",
                              fontSize: s.width * 0.026,
                              fontWeight: FontWeight.w600,
                              color: activeColor,
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              _showColorPicker
                                  ? Icons.keyboard_arrow_up_rounded
                                  : Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: activeColor.withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ── POINTS ROW ──
              Padding(
                padding: EdgeInsets.only(
                  left: s.width * 0.035,
                  right: s.width * 0.035,
                  bottom: s.width * 0.035,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: s.width * 0.033,
                    vertical: s.height * 0.020,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark
                        ? Colors.white.withOpacity(0.04)
                        : Colors.black.withOpacity(0.035),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Iconsax.activity,
                        size: s.width * 0.040,
                        color: isDark
                            ? Colors.white.withOpacity(0.35)
                            : Colors.black.withOpacity(0.35),
                      ),
                      SizedBox(width: s.width * 0.022),
                      Expanded(
                        child: TextField(
                          controller: pointsCtrl,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: s.width * 0.032,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "vip_from_points".tr,
                            hintStyle: TextStyle(
                              fontSize: s.width * 0.032,
                              color: isDark
                                  ? Colors.white.withOpacity(0.25)
                                  : Colors.black.withOpacity(0.25),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      AppText(
                        "pts".tr,
                        fontSize: s.width * 0.028,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? Colors.white.withOpacity(0.2)
                            : Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),
                ),
              ),

              /// ── COLOR PICKER PANEL ──
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeInOut,
                child: _showColorPicker
                    ? _ColorPickerPanel(
                        palette: _palette,
                        activeColor: activeColor,
                        isDark: isDark,
                        size: s,
                        onColorSelected: (color) {
                          ctrl.vipColors[widget.levelKey] = color;
                          ctrl.update(); // triggers GetBuilder rebuild
                          setState(() => _showColorPicker = false);
                        },
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// ─────────────────────────────────────────────
/// COLOR PICKER PANEL
/// ─────────────────────────────────────────────
class _ColorPickerPanel extends StatefulWidget {
  final List<Color> palette;
  final Color activeColor;
  final bool isDark;
  final Size size;
  final ValueChanged<Color> onColorSelected;

  const _ColorPickerPanel({
    required this.palette,
    required this.activeColor,
    required this.isDark,
    required this.size,
    required this.onColorSelected,
  });

  @override
  State<_ColorPickerPanel> createState() => _ColorPickerPanelState();
}

class _ColorPickerPanelState extends State<_ColorPickerPanel> {
  final _hexController = TextEditingController();
  String? _hexError;

  @override
  void dispose() {
    _hexController.dispose();
    super.dispose();
  }

  void _applyHex() {
    final raw = _hexController.text.replaceAll('#', '').trim();
    if (raw.length == 6) {
      final value = int.tryParse('FF$raw', radix: 16);
      if (value != null) {
        widget.onColorSelected(Color(value));
        _hexController.clear();
        setState(() => _hexError = null);
        return;
      }
    }
    setState(() => _hexError = "invalid_hex".tr);
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    final isDark = widget.isDark;

    return Container(
      padding: EdgeInsets.fromLTRB(
          s.width * 0.035, 0, s.width * 0.035, s.width * 0.035),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Divider(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.06),
            height: 1,
          ),
          SizedBox(height: s.height * 0.014),

          /// Palette grid
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: widget.palette.map((color) {
              final isSelected = color.value == widget.activeColor.value;
              return GestureDetector(
                onTap: () => widget.onColorSelected(color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    border: Border.all(
                      color: isSelected ? Colors.white : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withOpacity(0.55),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
              );
            }).toList(),
          ),

          SizedBox(height: s.height * 0.014),

          /// Hex input row
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.04),
                    border: Border.all(
                      color: _hexError != null
                          ? Colors.redAccent.withOpacity(0.5)
                          : isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.black.withOpacity(0.08),
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: AppText(
                          "#",
                          fontSize: s.width * 0.033,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white.withOpacity(0.4)
                              : Colors.black.withOpacity(0.35),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _hexController,
                          maxLength: 6,
                          style: TextStyle(
                            fontSize: s.width * 0.032,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            hintText: "RRGGBB",
                            hintStyle: TextStyle(
                              fontSize: s.width * 0.030,
                              color: isDark
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.2),
                              letterSpacing: 0.5,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            counterText: "",
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _applyHex(),
                          onChanged: (_) {
                            if (_hexError != null) {
                              setState(() => _hexError = null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _applyHex,
                child: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: widget.activeColor,
                    boxShadow: [
                      BoxShadow(
                        color: widget.activeColor.withOpacity(0.4),
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: const Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ),
              ),
            ],
          ),

          if (_hexError != null) ...[
            const SizedBox(height: 4),
            AppText(
              _hexError!,
              fontSize: s.width * 0.026,
              fontWeight: FontWeight.w500,
              color: Colors.redAccent,
            ),
          ],
        ],
      ),
    );
  }
}