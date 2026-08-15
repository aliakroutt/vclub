import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Staff/Activity/Controllers/AgentActivityController.dart';

Future<void> showAgentActivityDateRangeSheet(BuildContext context) {
  final controller = Get.find<AgentActivityController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  DateTime? from = controller.fromDate.value;
  DateTime? to = controller.toDate.value;

  String fmt(DateTime? d) => d == null
      ? "select_date".tr
      : "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return SafeArea(
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20 + MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F26) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [AppText("filter_date".tr, fontSize: 16, fontWeight: FontWeight.w800)]),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _DateField(
                          label: "from_date".tr,
                          value: fmt(from),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: from ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setState(() => from = picked);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _DateField(
                          label: "to_date".tr,
                          value: fmt(to),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: to ?? DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) setState(() => to = picked);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              from = null;
                              to = null;
                            });
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
                            controller.setDateRange(from, to);
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
          );
        },
      );
    },
  );
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(label, fontSize: 10.5, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5), fontWeight: FontWeight.w600),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Iconsax.calendar_1, size: 14, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(child: AppText(value, fontSize: 12.5, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}