import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

/// Modern date-of-birth field, styled to match the elevated card language
/// used by the rest of the edit-profile form (layered shadow, icon chip,
/// glow while active). Tapping opens a Cupertino bottom-sheet date wheel.
class AppDateField extends StatefulWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const AppDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  bool _active = false;

  String _format(DateTime d, String locale) {
    const monthsEn = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const monthsFr = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin', 'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];
    const monthsAr = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    final months = locale == 'fr' ? monthsFr : (locale == 'ar' ? monthsAr : monthsEn);
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _openPicker(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime temp = widget.value ?? DateTime(2000, 1, 1);

    setState(() => _active = true);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
                child: Row(
                  children: [
                    Expanded(child: AppText(widget.label, fontSize: 16, fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () {
                        widget.onChanged(temp);
                        Navigator.of(context).pop();
                      },
                      child: AppText('done'.tr, fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 216,
                child: CupertinoTheme(
                  data: CupertinoThemeData(brightness: isDark ? Brightness.dark : Brightness.light),
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: temp,
                    minimumDate: widget.firstDate ?? DateTime(1930, 1, 1),
                    maximumDate: widget.lastDate ?? DateTime.now(),
                    onDateTimeChanged: (d) => temp = d,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    if (mounted) setState(() => _active = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Get.locale?.languageCode ?? 'en';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: _active
              ? AppColors.primary
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          width: _active ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _active
                ? AppColors.primary.withOpacity(0.16)
                : Colors.black.withOpacity(isDark ? 0.18 : 0.045),
            blurRadius: _active ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openPicker(context),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(11),
              child: Icon(Iconsax.calendar_1_copy, size: 18, color: AppColors.primary),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
                child: widget.value != null
                    ? AppText(
                        _format(widget.value!, locale),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      )
                    : AppText(
                        widget.label,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.withOpacity(0.85),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Iconsax.arrow_down_1_copy, size: 13, color: Colors.grey.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}