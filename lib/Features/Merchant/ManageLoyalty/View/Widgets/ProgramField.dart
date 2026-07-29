import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';

class ProgramNameField extends StatefulWidget {
  final LoyaltyModeController controller;
  const ProgramNameField({required this.controller});

  @override
  State<ProgramNameField> createState() => ProgramNameFieldState();
}

class ProgramNameFieldState extends State<ProgramNameField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _isFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Container(
      padding: EdgeInsets.all(size.width * 0.04),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: _isFocused
              ? AppColors.primary.withOpacity(0.5)
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05)),
          width: _isFocused ? 1.4 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppColors.primary.withOpacity(0.10)
                : Colors.black.withOpacity(isDark ? 0.22 : 0.04),
            blurRadius: _isFocused ? 20 : 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size.width * 0.11,
            height: size.width * 0.11,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: AppColors.primary.withOpacity(_isFocused ? 0.16 : 0.10),
            ),
            child: Icon(
              Iconsax.crown,
              color: AppColors.primary,
              size: size.width * 0.052,
            ),
          ),
          SizedBox(width: size.width * 0.035),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                AppText(
                  "program_name".tr,
                  fontSize: size.width * 0.028,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 3),
                TextField(
                  controller: widget.controller.nameController,
                  focusNode: _focusNode,
                  textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: isRTL ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    fontSize: size.width * 0.043,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  decoration: InputDecoration(
                    hintText: "enter_program_name".tr,
                    hintStyle: TextStyle(
                      fontSize: size.width * 0.033,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white.withOpacity(0.25)
                          : Colors.black.withOpacity(0.22),
                    ),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    border: InputBorder.none,
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