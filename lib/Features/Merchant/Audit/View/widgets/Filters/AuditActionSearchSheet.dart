import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Audit/Controllers/MerchantAuditController.dart';

Future<void> showAuditActionSearchSheet(BuildContext context) {
  final controller = Get.find<MerchantAuditController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final textController = TextEditingController(text: controller.actionQuery.value);

  const suggestions = [
    "auth.login",
    "company.update",
    "employee.create",
    "employee.delete",
    "program.update",
    "reward.create",
    "client.update",
  ];

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F26) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                AppText("filter_action".tr, fontSize: 16, fontWeight: FontWeight.w800),
                const SizedBox(height: 4),
                AppText(
                  "filter_action_hint".tr,
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: AppColors.primary.withOpacity(.2)),
                  ),
                  child: Row(
                    children: [
                      Icon(Iconsax.search_normal_1_copy, size: 16, color: AppColors.primary),
                      const SizedBox(width: 9),
                      Expanded(
                        child: TextField(
                          controller: textController,
                          autofocus: true,
                          style: const TextStyle(fontSize: 13.5),
                          decoration: InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: "action_placeholder".tr,
                            hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.withOpacity(.6)),
                          ),
                          onSubmitted: (value) {
                            controller.onActionSearchChanged(value);
                            Navigator.pop(sheetContext);
                          },
                        ),
                      ),
                      if (textController.text.isNotEmpty)
                        InkWell(
                          onTap: () => textController.clear(),
                          child: Icon(Iconsax.close_circle, size: 16, color: Colors.grey.withOpacity(.5)),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppText(
                  "suggested_actions".tr,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.45),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: suggestions.map((s) {
                    return Material(
                      color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () {
                          textController.text = s;
                          controller.onActionSearchChanged(s);
                          Navigator.pop(sheetContext);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                          child: AppText(s, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          textController.clear();
                          controller.onActionSearchChanged("");
                          Navigator.pop(sheetContext);
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          side: BorderSide(color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1)),
                        ),
                        child: AppText("reset".tr, fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          controller.onActionSearchChanged(textController.text);
                          Navigator.pop(sheetContext);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: AppText("apply".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}