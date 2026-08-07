import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Avtivity/Controllers/MerchantActivityController.dart';
import 'package:vclub/Features/Merchant/Avtivity/Models/MerchantActivityModel.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/Widgets/ActivityMeta.dart';


Future<void> showActivityTypeSelectSheet(BuildContext context) {
  final controller = Get.find<MerchantActivityController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * .75),
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  AppText("filter_type".tr, fontSize: 16, fontWeight: FontWeight.w800),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Obx(() => _TypeRow(
                        selected: controller.actionFilter.value.isEmpty,
                        icon: Iconsax.category,
                        color: AppColors.primary,
                        label: "all_types".tr,
                        onTap: () {
                          controller.setActionFilter("");
                          Navigator.pop(sheetContext);
                        },
                      )),
                  const SizedBox(height: 6),
                  ...ActivityActionType.values.map((type) {
                    final meta = ActivityMeta.of(type.apiValue);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Obx(() => _TypeRow(
                            selected: controller.actionFilter.value == type.apiValue,
                            icon: meta.icon,
                            color: meta.color,
                            label: meta.labelKey.tr,
                            onTap: () {
                              controller.setActionFilter(type.apiValue);
                              Navigator.pop(sheetContext);
                            },
                          )),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ));
    },
  );
}

class _TypeRow extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _TypeRow({
    required this.selected,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? color.withOpacity(.1)
          : (isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025)),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(color: color.withOpacity(.12), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppText(label, fontSize: 13.5, fontWeight: FontWeight.w700),
              ),
              Icon(
                selected ? Iconsax.tick_circle : Iconsax.arrow_circle_right_copy,
                size: 19,
                color: selected ? color : Colors.grey.withOpacity(.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}