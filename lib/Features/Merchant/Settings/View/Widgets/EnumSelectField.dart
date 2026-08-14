import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class EnumOption {
  final String value;
  final String label;
  final IconData? icon;

  const EnumOption({required this.value, required this.label, this.icon});
}

class EnumSelectField extends StatelessWidget {
  final String label;
  final String selectedValue;
  final List<EnumOption> options;
  final String sheetTitle;
  final ValueChanged<String> onSelected;

  const EnumSelectField({
    super.key,
    required this.label,
    required this.selectedValue,
    required this.options,
    required this.sheetTitle,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedOption = options.where((o) => o.value == selectedValue).toList();
    final displayLabel = selectedOption.isNotEmpty ? selectedOption.first.label : "select_option".tr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: size.width * .031,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
        ),
        SizedBox(height: size.height * .008),
        Material(
          color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _showSheet(context),
            child: Container(
              height: size.height * .062,
              padding: EdgeInsets.symmetric(horizontal: size.width * .035),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: AppText(
                      displayLabel,
                      fontSize: size.width * .034,
                      fontWeight: FontWeight.w600,
                      color: selectedOption.isEmpty ? Colors.grey.withOpacity(.6) : null,
                    ),
                  ),
                  Icon(Iconsax.arrow_down_1, size: 16, color: Colors.grey.withOpacity(.5)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F26) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  height: 4,
                  width: 40,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(children: [AppText(sheetTitle, fontSize: 16, fontWeight: FontWeight.w800)]),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: Column(
                    children: options.map((option) {
                      final selected = option.value == selectedValue;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: selected ? AppColors.primary.withOpacity(.1) : (isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025)),
                          borderRadius: BorderRadius.circular(14),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              onSelected(option.value);
                              Navigator.pop(sheetContext);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                              child: Row(
                                children: [
                                  if (option.icon != null) ...[
                                    Icon(option.icon, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 10),
                                  ],
                                  Expanded(child: AppText(option.label, fontSize: 13.5, fontWeight: FontWeight.w700)),
                                  Icon(
                                    selected ? Iconsax.tick_circle : Iconsax.arrow_circle_right_copy,
                                    size: 18,
                                    color: selected ? AppColors.primary : Colors.grey.withOpacity(.4),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}