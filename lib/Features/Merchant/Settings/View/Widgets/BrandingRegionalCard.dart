import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SettingsController.dart';
import 'ColorField.dart';
import 'EnumSelectField.dart';
import 'SectionUpdateButton.dart';

class BrandingRegionalCard extends StatelessWidget {
  const BrandingRegionalCard({super.key});

  static const _accent = Color(0xFFFFA53E);

  static const _currencyOptions = [
    EnumOption(value: "EUR", label: "Euro (EUR)"),
    EnumOption(value: "TND", label: "Tunisian Dinar (TND)"),
    EnumOption(value: "MAD", label: "Moroccan Dirham (MAD)"),
    EnumOption(value: "DZD", label: "Algerian Dinar (DZD)"),
    EnumOption(value: "USD", label: "US Dollar (USD)"),
  ];

  static const _languageOptions = [
    EnumOption(value: "fr", label: "Français"),
    EnumOption(value: "en", label: "English"),
    EnumOption(value: "ar", label: "العربية"),
  ];

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? .22 : .04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: _accent.withOpacity(.10)),
                child: Icon(Iconsax.brush_1, color: _accent, size: size.width * .052),
              ),
              SizedBox(width: size.width * .035),
              Expanded(child: AppText("branding_regional".tr, fontSize: size.width * .042, fontWeight: FontWeight.w700)),
            ],
          ),
          SizedBox(height: size.height * .025),

          Row(
            children: [
              Expanded(child: ColorField(controller: controller.brandColorController, label: "brand_color".tr)),
              SizedBox(width: size.width * .03),
              Expanded(child: ColorField(controller: controller.secondaryColorController, label: "secondary_color".tr)),
            ],
          ),
          SizedBox(height: size.height * .018),

          _ModernField(controller: controller.countryCodeController, label: "country_code".tr, icon: Iconsax.flag, hint: "TN"),
          SizedBox(height: size.height * .018),

          Obx(() => EnumSelectField(
                label: "currency".tr,
                selectedValue: controller.currencyCode.value,
                options: _currencyOptions,
                sheetTitle: "select_currency".tr,
                onSelected: controller.setCurrencyCode,
              )),
          SizedBox(height: size.height * .018),

          _ModernField(controller: controller.timezoneController, label: "timezone".tr, icon: Iconsax.clock, hint: "Africa/Tunis"),
          SizedBox(height: size.height * .018),

          Obx(() => EnumSelectField(
                label: "language".tr,
                selectedValue: controller.language.value,
                options: _languageOptions,
                sheetTitle: "select_language".tr,
                onSelected: controller.setLanguage,
              )),

          SizedBox(height: size.height * .022),
          Obx(() => SectionUpdateButton(loading: controller.savingBranding.value, onTap: controller.saveBranding)),
        ],
      ),
    );
  }
}

class _ModernField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;

  const _ModernField({required this.controller, required this.label, required this.icon, this.hint});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: size.width * .031, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65)),
        SizedBox(height: size.height * .008),
        Container(
          height: size.height * .062,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
            border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          ),
          child: Row(
            children: [
              SizedBox(width: size.width * .035),
              Icon(icon, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65), size: size.width * .05),
              SizedBox(width: size.width * .03),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(fontSize: size.width * .034, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: hint,
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(.5)),
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