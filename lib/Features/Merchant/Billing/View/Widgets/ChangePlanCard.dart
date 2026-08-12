import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'ChangePlanSheet.dart';

class ChangePlanCard extends StatelessWidget {
  final bool isFreePlan;

  const ChangePlanCard({super.key, required this.isFreePlan});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.06)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? .3 : .05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withOpacity(.7)],
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 6))],
                ),
                child: const Icon(Iconsax.crown_1, color: Colors.white, size: 21),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      isFreePlan ? "choose_a_plan_title".tr : "change_plan_title".tr,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w800,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      isFreePlan ? "choose_a_plan_subtitle".tr : "change_plan_subtitle".tr,
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                    ),
                   
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(13),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(13),
                          onTap: () => showChangePlanSheet(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.arrow_swap_horizontal, size: 16, color: Colors.white),
                              const SizedBox(width: 8),
                              AppText(
                                isFreePlan ? "view_plans".tr : "change_plan_button".tr,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}