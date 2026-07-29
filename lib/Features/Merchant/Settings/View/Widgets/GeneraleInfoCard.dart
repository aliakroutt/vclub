import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class GeneralInformationCard extends StatelessWidget {
  const GeneralInformationCard({
    super.key,
    required this.companyController,
    required this.industryController,
    required this.phoneController,
  });

  final TextEditingController companyController;
  final TextEditingController industryController;
  final TextEditingController phoneController;

  static const _accent = Color(0xFF6C5CE7);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.06)
              : Colors.black.withOpacity(.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _accent.withOpacity(.10),
                ),
                child: Icon(
                  Iconsax.building_3,
                  color: _accent,
                  size: size.width * .052,
                ),
              ),
              SizedBox(width: size.width * .035),
              Expanded(
                child: AppText(
                  "general_information".tr,
                  fontSize: size.width * .042,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .025),

          _ModernField(
            controller: companyController,
            label: "company_name".tr,
            icon: Iconsax.building,
          ),

          SizedBox(height: size.height * .018),

          _ModernField(
            controller: industryController,
            label: "industry".tr,
            icon: Iconsax.category,
          ),

          SizedBox(height: size.height * .018),

          _ModernField(
            controller: phoneController,
            label: "phone".tr,
            icon: Iconsax.call,
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

class _ModernField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _ModernField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

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

        Container(
          height: size.height * .062,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isDark
                ? Colors.white.withOpacity(.03)
                : Colors.black.withOpacity(.02),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.06)
                  : Colors.black.withOpacity(.05),
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: size.width * .035),

              Icon(
                icon,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
                size: size.width * .05,
              ),

              SizedBox(width: size.width * .03),

              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  style: TextStyle(
                    fontSize: size.width * .034,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),

              SizedBox(width: size.width * .035),
            ],
          ),
        ),
      ],
    );
  }
}
