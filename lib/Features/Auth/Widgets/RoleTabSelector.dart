import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class RoleTabSelector extends StatelessWidget {
  final RxString selected;
  final Function(String value) onChanged;

  const RoleTabSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.1, // ✅ responsive
        ),
        child: Container(
          padding: EdgeInsets.all(size.width * 0.005),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Row(
            children: isArabic
                ? [_client(context, size), _merchant(context, size)]
                : [_merchant(context, size), _client(context, size)],
          ),
        ),
      );
    });
  }

  Widget _merchant(BuildContext context, Size size) {
    return _tab(
      context: context,
      size: size,
      title: "merchant".tr,
      icon: Iconsax.shop,
      value: "merchant",
    );
  }

  Widget _client(BuildContext context, Size size) {
    return _tab(
      context: context,
      size: size,
      title: "client".tr,
      icon: Iconsax.user,
      value: "client",
    );
  }

  Widget _tab({
    required BuildContext context,
    required Size size,
    required String title,
    required IconData icon,
    required String value,
  }) {
    final isSelected = selected.value == value;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(50),
          onTap: () => onChanged(value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(
              vertical: size.height * 0.012,
              horizontal: size.width * 0.03,
            ),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(50),

              // 🌟 PREMIUM SHADOW ONLY WHEN SELECTED
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: size.width * 0.045,
                  color: isSelected
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
                SizedBox(width: size.width * 0.02),
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: size.width * 0.035,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : Colors.grey.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}