import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Configs/Translations/language_service.dart';
import 'package:vclub/Features/Auth/Widgets/LanguageSelector.dart';

class AppBarLanguageSelector extends StatefulWidget {
  const AppBarLanguageSelector({super.key});

  @override
  State<AppBarLanguageSelector> createState() =>
      _AppBarLanguageSelectorState();
}

class _AppBarLanguageSelectorState extends State<AppBarLanguageSelector>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _chevron;

  final _isOpen = false.obs;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 110));
    _scale = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
    _chevron = Tween<double>(begin: 0.0, end: 0.5)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _open(BuildContext context) async {
    final themeService = Get.find<ThemeService>();
    final langService = Get.find<LanguageService>();
    final isDark = themeService.isDarkMode.value;

    _ctrl.forward();
    _isOpen.value = true;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset offset = box.localToGlobal(Offset.zero);
    final size = box.size;

    await showMenu<String>(
  context: context,
  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
  elevation: 8,
  shadowColor: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.06),
      width: 0.5,
    ),
  ),
  position: RelativeRect.fromLTRB(
    offset.dx,
    offset.dy + size.height + 8,
    offset.dx + size.width,
    0,
  ),
  items: AppLanguages.languages.map((lang) {
    final isSelected =
        (Get.locale?.languageCode ?? 'fr') == lang.code;

    return PopupMenuItem<String>(
      value: lang.code,
      padding: EdgeInsets.zero,
      child: _LangMenuItem(
        lang: lang,
        isSelected: isSelected,
        isDark: isDark,
      ),
    );
  }).toList(),
).then((code) {
  if (code != null) langService.changeLanguage(code);
});

    _ctrl.reverse();
    _isOpen.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();

    return Obx(() {
      final isDark = themeService.isDarkMode.value;
      final langCode = Get.locale?.languageCode ?? 'fr';
      final lang = AppLanguages.languages.firstWhere(
        (e) => e.code == langCode,
        orElse: () => AppLanguages.languages.first,
      );

      return GestureDetector(
        onTap: () => _open(context),
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 38,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.10)
                    : Colors.black.withOpacity(0.07),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lang.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 5),
                RotationTransition(
                  turns: _chevron,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: isDark
                        ? Colors.white.withOpacity(0.5)
                        : Colors.black.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────
//  Single item in the dropdown
// ─────────────────────────────────────────────────────────────

class _LangMenuItem extends StatefulWidget {
  final LanguageModel lang;
  final bool isSelected;
  final bool isDark;

  const _LangMenuItem({
    required this.lang,
    required this.isSelected,
    required this.isDark,
  });

  @override
  State<_LangMenuItem> createState() => _LangMenuItemState();
}

class _LangMenuItemState extends State<_LangMenuItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: widget.isSelected
              ? AppColors.primary.withOpacity(0.12)
              : _hovered
                  ? (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04))
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: widget.isSelected
              ? Border.all(
                  color: AppColors.primary.withOpacity(0.30), width: 0.5)
              : Border.all(color: Colors.transparent, width: 0.5),
        ),
        child: Row(
          children: [
            Text(widget.lang.flag, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Text(
              widget.lang.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: widget.isSelected
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: widget.isSelected
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withOpacity(0.80)
                        : Colors.black.withOpacity(0.75)),
              ),
            ),
            const Spacer(),
            if (widget.isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.check, size: 13, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}