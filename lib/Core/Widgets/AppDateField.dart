import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/responsive.dart';

/// Premium / modern date-of-birth field.
/// Same visual language as [AppTextField] (label above, filled rounded box,
/// dark/light aware) but opens a themed bottom-sheet calendar wheel instead
/// of a keyboard. Fully RTL / locale aware (en, fr, ar).
///
/// The selected date is written into [controller] as an ISO string
/// (yyyy-MM-dd) so it stays compatible with existing String-based
/// controllers (e.g. ClientSignUpController.birthdayController).
class AppDateField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData prefixIcon;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? errorText;
  final ValueChanged<DateTime>? onDateSelected;

  const AppDateField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.prefixIcon = Icons.calendar_month_rounded,
    this.firstDate,
    this.lastDate,
    this.errorText,
    this.onDateSelected,
  });

  @override
  State<AppDateField> createState() => _AppDateFieldState();
}

class _AppDateFieldState extends State<AppDateField> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.controller.text.isNotEmpty) {
      _selectedDate = DateTime.tryParse(widget.controller.text);
    }
  }

  String get _localeCode => Get.locale?.languageCode ?? 'en';

  String _formatted(DateTime date) {
    try {
      return DateFormat('d MMMM yyyy', _localeCode).format(date);
    } catch (_) {
      // Fallback if the locale isn't initialized for intl date symbols.
      return DateFormat('d MMMM yyyy').format(date);
    }
  }

  Future<void> _openPicker(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DateTime temp = _selectedDate ?? DateTime(2000, 1, 1);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1E26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFE2E5EA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: AppText(
                          "cancel".tr,
                          color: isDark ? Colors.white70 : const Color(0xFF6C757D),
                          fontSize: 12,
                        ),
                      ),
                      AppText(
                        "select_date_of_birth".tr,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                        fontSize: 12,
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => _selectedDate = temp);
                          widget.controller.text =
                              temp.toIso8601String().split('T').first;
                          widget.onDateSelected?.call(temp);
                          Navigator.pop(ctx);
                        },
                        child: AppText(
                          "done".tr,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  color: isDark ? Colors.white10 : const Color(0xFFE2E5EA),
                ),
                SizedBox(
                  height: 260,
                  child: CupertinoTheme(
                    data: CupertinoThemeData(
                      brightness: isDark ? Brightness.dark : Brightness.light,
                      textTheme: CupertinoTextThemeData(
                        dateTimePickerTextStyle: TextStyle(
                          fontSize: 18,
                          color: isDark ? Colors.white : const Color(0xFF2D3142),
                        ),
                      ),
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: temp,
                      maximumDate: widget.lastDate ?? DateTime.now(),
                      minimumDate: widget.firstDate ?? DateTime(1900, 1, 1),
                      onDateTimeChanged: (val) => temp = val,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _localeCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      // textDirection: isArabic ? TextDirection.RTL : TextDirection.LTR,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Responsive.scaleH(context, 8)),
          child: AppText(
            widget.label,
            fontSize: Responsive.scaleW(context, 13),
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
          onTap: () => _openPicker(context),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.scaleW(context, 18),
              vertical: Responsive.scaleH(context, 14),
            ),
            decoration: BoxDecoration(
              color:
                  isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
              border: Border.all(
                color: widget.errorText != null
                    ? Colors.redAccent
                    : (isDark
                        ? Colors.white.withOpacity(0.08)
                        : const Color(0xFFE2E5EA)),
                width: 1.2,
              ),
            ),
            child: Row(
              // textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
              children: [
                Icon(
                  widget.prefixIcon,
                  size: Responsive.scaleW(context, 20),
                  color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                ),
                SizedBox(width: Responsive.scaleW(context, 10)),
                Expanded(
                  child: AppText(
                    _selectedDate != null
                        ? _formatted(_selectedDate!)
                        : (widget.hint ?? "select_date".tr),
                    fontSize: Responsive.scaleW(context, 15),
                    fontWeight: FontWeight.w400,
                    color: _selectedDate != null
                        ? (isDark ? Colors.white : const Color(0xFF2D3142))
                        : (isDark ? Colors.white38 : const Color(0xFFADB5BD)),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: Responsive.scaleW(context, 20),
                  color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                ),
              ],
            ),
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: Responsive.scaleH(context, 6), left: 4),
            child: AppText(
              widget.errorText!,
              fontSize: 12,
              color: Colors.redAccent,
            ),
          ),
      ],
    );
  }
}