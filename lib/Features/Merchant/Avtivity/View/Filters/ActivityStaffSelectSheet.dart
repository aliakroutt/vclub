import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Avtivity/Controllers/MerchantActivityController.dart';
import 'package:vclub/Features/Merchant/Employee/Controllers/EmployeeController.dart';
import 'package:vclub/Features/Merchant/Employee/Models/EmployesModel.dart';


Future<void> showActivityStaffSelectSheet(BuildContext context) {
  final activityController = Get.find<MerchantActivityController>();
  final staffController = Get.find<EmployeeController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return DraggableScrollableSheet(
        initialChildSize: .75,
        minChildSize: .5,
        maxChildSize: .92,
        expand: false,
        builder: (context, scrollController) {
          return  SafeArea(
            child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F26) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
            ),
            child: Column(
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
                  child: Row(children: [AppText("filter_staff".tr, fontSize: 16, fontWeight: FontWeight.w800)]),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Iconsax.search_normal_1_copy, size: 15, color: Colors.grey.withOpacity(.6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: staffController.onSearchChanged,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "search_staff".tr,
                              hintStyle: TextStyle(fontSize: 13.5, color: Colors.grey.withOpacity(.6)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Obx(() {
                    if (staffController.isLoading.value) {
                      return Center(child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 38));
                    }

                    if (staffController.hasError.value) {
                      return Center(child: AppText("failed_load_staff".tr, fontSize: 13, color: Colors.redAccent));
                    }

                    return ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        Obx(() => _StaffRow(
                              selected: activityController.staffFilter.value == null,
                              name: "all_staff".tr,
                              subtitle: "",
                              onTap: () {
                                activityController.setStaffFilter(null);
                                Navigator.pop(sheetContext);
                              },
                            )),
                        const SizedBox(height: 8),
                        if (staffController.employees.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Center(
                              child: AppText(
                                "no_staff_found".tr,
                                fontSize: 13,
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                              ),
                            ),
                          )
                        else
                          ...staffController.employees.map((EmployeeModel staff) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Obx(() => _StaffRow(
                                    selected: activityController.staffFilter.value?.id == staff.id,
                                    name: "${staff.firstName} ${staff.lastName}".trim(),
                                    subtitle: staff.email,
                                    onTap: () {
                                      activityController.setStaffFilter(staff);
                                      Navigator.pop(sheetContext);
                                    },
                                  )),
                            );
                          }),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ));
        },
      );
    },
  );
}

class _StaffRow extends StatelessWidget {
  final bool selected;
  final String name;
  final String subtitle;
  final VoidCallback onTap;

  const _StaffRow({required this.selected, required this.name, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initials =
        name.trim().isNotEmpty ? name.trim().split(" ").map((e) => e.isNotEmpty ? e[0] : "").take(2).join().toUpperCase() : "?";

    return Material(
      color: selected ? AppColors.primary.withOpacity(.1) : (isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025)),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppColors.primary.withOpacity(.12),
                child: AppText(initials, fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(name, fontSize: 13.5, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                    if (subtitle.isNotEmpty)
                      AppText(subtitle, fontSize: 11.5, overflow: TextOverflow.ellipsis, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5)),
                  ],
                ),
              ),
              Icon(selected ? Iconsax.tick_circle : Iconsax.arrow_circle_right_copy, size: 19, color: selected ? AppColors.primary : Colors.grey.withOpacity(.4)),
            ],
          ),
        ),
      ),
    );
  }
}