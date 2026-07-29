import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/responsive.dart';

class AppPhoneField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String initialCountryCode;
  final ValueChanged<PhoneNumber> onChanged;
  final String? errorText;

  const AppPhoneField({
    super.key,
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hint,
    this.initialCountryCode = 'FR',
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(bottom: Responsive.scaleH(context, 8)),
          child: AppText(
            label,
            fontSize: Responsive.scaleW(context, 13),
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),

        // ── Field ──────────────────────────────────────────────
        Directionality(
          // Flips the flag/dropdown side for Arabic layouts
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: IntlPhoneField(
            controller: controller,
            initialCountryCode: initialCountryCode,
            disableLengthCheck: true,
            showDropdownIcon: true,
            dropdownIconPosition: IconPosition.trailing,
            flagsButtonPadding: EdgeInsets.symmetric(
              horizontal: Responsive.scaleW(context, 8),
            ),
            searchText: "search_country".tr,
            style: TextStyle(
              fontSize: Responsive.scaleW(context, 15),
              color: isDark ? Colors.white : const Color(0xFF2D3142),
              fontWeight: FontWeight.w400,
            ),
            dropdownTextStyle: TextStyle(
              fontSize: Responsive.scaleW(context, 15),
              color: isDark ? Colors.white : const Color(0xFF2D3142),
            ),
            decoration: InputDecoration(
              hintText: hint ?? "enter_phone".tr,
              errorText: errorText,
              hintStyle: TextStyle(
                fontSize: Responsive.scaleW(context, 13),
                color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.white.withOpacity(0.06)
                  : const Color(0xFFF4F5F7),
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.scaleW(context, 18),
                vertical: Responsive.scaleH(context, 14),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.scaleW(context, 16),
                ),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.scaleW(context, 16),
                ),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE2E5EA),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.scaleW(context, 16),
                ),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 1.5,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.scaleW(context, 16),
                ),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.2,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  Responsive.scaleW(context, 16),
                ),
                borderSide: const BorderSide(
                  color: Colors.redAccent,
                  width: 1.5,
                ),
              ),
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}