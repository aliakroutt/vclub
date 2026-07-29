// ── AppPasswordField ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/responsive.dart';

class AppPasswordField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final RxBool isObscure;           // pass from your controller
  final VoidCallback onToggle;      // pass controller.toggleVisibility
  final IconData? prefixIcon;
  final String? errorText;

  const AppPasswordField({
    super.key,
    required this.label,
    required this.controller,
    required this.isObscure,
    required this.onToggle,
    this.hint,
    this.prefixIcon,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
       textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
  crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Label ──────────────────────────────────────────────
        Padding(
          padding: EdgeInsets.only(
            // left: isArabic ? 0 : Responsive.scaleW(context, 4),
            // right: isArabic ? Responsive.scaleW(context, 4) : 0,
            bottom: Responsive.scaleH(context, 8),
          ),
          child: AppText(
            label,
            fontSize: Responsive.scaleW(context, 13),
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),

        // ── Field (Obx rebuilds only the suffix icon) ──────────
        Obx(
          () => TextField(
            controller: controller,
            obscureText: isObscure.value,
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isArabic ? TextAlign.right : TextAlign.left,
            style: TextStyle(
              fontSize: Responsive.scaleW(context, 15),
              color: isDark ? Colors.white : const Color(0xFF2D3142),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: hint,
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
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      size: Responsive.scaleW(context, 20),
                      color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                    )
                  : null,
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  isObscure.value ? Iconsax.eye_slash : Iconsax.eye,
                  size: Responsive.scaleW(context, 20),
                  color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE2E5EA),
                  width: 1.2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
                borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}