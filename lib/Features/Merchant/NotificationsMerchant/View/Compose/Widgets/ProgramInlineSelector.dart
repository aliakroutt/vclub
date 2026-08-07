import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Controllers/ComposeNotificationController.dart';
import 'ComposeStyles.dart';

class ProgramInlineSelector extends StatelessWidget {
  const ProgramInlineSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final composeController = Get.find<ComposeNotificationController>();
    final programsController = Get.find<MerchantProgramsController>();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: composePanelDecoration(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText("select_program".tr, fontSize: 12.5, fontWeight: FontWeight.w700),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: Obx(() {
              if (programsController.loading.value && !programsController.initialLoaded.value) {
                return Center(
                  child: LoadingAnimationWidget.fourRotatingDots(
                    color: AppColors.primary,
                    size: 34,
                  ),
                );
              }

              if (programsController.programs.isEmpty) {
                return Center(
                  child: AppText(
                    "no_programs_found".tr,
                    fontSize: 12.5,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                  ),
                );
              }

              return ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: programsController.programs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 6),
                itemBuilder: (context, index) {
                  final ProgramModel program = programsController.programs[index];

                  return Obx(() {
                    final selected = composeController.selectedProgram.value?.id == program.id;

                    return _SelectableRow(
                      selected: selected,
                      leadingIcon: Iconsax.medal_star,
                      title: program.name,
                      subtitle: program.mode,
                      onTap: () => composeController.selectProgram(program),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SelectableRow extends StatelessWidget {
  final bool selected;
  final IconData leadingIcon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SelectableRow({
    required this.selected,
    required this.leadingIcon,
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
          : (isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02)),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              CircleAvatar(
                radius: 15,
                backgroundColor: AppColors.primary.withOpacity(.12),
                child: Icon(leadingIcon, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(title, fontSize: 13, fontWeight: FontWeight.w700, overflow: TextOverflow.ellipsis),
                    if (subtitle.isNotEmpty)
                      AppText(
                        subtitle,
                        fontSize: 11,
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Icon(
                selected ? Iconsax.tick_circle : Iconsax.tick_circle,
                size: 20,
                color: selected ? AppColors.primary : Colors.grey.withOpacity(.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}