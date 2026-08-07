import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';

Future<void> showProgramSelectSheet(BuildContext context) {
  final composeController = Get.find<ComposeNotificationController>();
  composeController.ensureProgramsLoaded();
  final programsController = Get.find<MerchantProgramsController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return  DraggableScrollableSheet(
        initialChildSize: .75,
        minChildSize: .5,
        maxChildSize: .92,
        expand: false,
        builder: (context, scrollController) {
          return SafeArea(child:  Container(
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
                  child: Row(
                    children: [
                      Container(
                        height: 34,
                        width: 34,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Iconsax.medal_star, size: 16, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      AppText("select_program".tr, fontSize: 16, fontWeight: FontWeight.w800),
                    ],
                  ),
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
                            onChanged: programsController.onSearchChanged,
                            style: const TextStyle(fontSize: 13.5),
                            decoration: InputDecoration(
                              isDense: true,
                              border: InputBorder.none,
                              hintText: "search_program".tr,
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
                    if (programsController.loading.value && !programsController.initialLoaded.value) {
                      return Center(
                        child: LoadingAnimationWidget.fourRotatingDots(color: AppColors.primary, size: 38),
                      );
                    }

                    if (programsController.programs.isEmpty) {
                      return Center(
                        child: AppText(
                          "no_programs_found".tr,
                          fontSize: 13,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                        ),
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: programsController.programs.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final ProgramModel program = programsController.programs[index];

                        return Obx(() {
                          final selected = composeController.selectedProgram.value?.id == program.id;

                          return _SheetRow(
                            selected: selected,
                            icon: Iconsax.medal_star,
                            title: program.name,
                            subtitle: program.mode,
                            onTap: () {
                              composeController.selectProgram(program);
                              Navigator.pop(sheetContext);
                            },
                          );
                        });
                      },
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

class _SheetRow extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetRow({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? AppColors.primary.withOpacity(.1)
          : (isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025)),
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
                child: Icon(icon, size: 16, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, fontSize: 13.5, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                    if (subtitle.isNotEmpty)
                      AppText(
                        subtitle,
                        fontSize: 11.5,
                        overflow: TextOverflow.ellipsis,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                      ),
                  ],
                ),
              ),
              Icon(
                selected ? Iconsax.tick_circle : Iconsax.arrow_circle_right_copy,
                size: 19,
                color: selected ? AppColors.primary : Colors.grey.withOpacity(.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}