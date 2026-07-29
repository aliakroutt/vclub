import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Features/Auth/Controllers/ForgetPasswordController.dart';

class ForgotPasswordSteps extends GetView<ForgotPasswordController> {
  final VoidCallback previous ; 
  const ForgotPasswordSteps(this.previous, {super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;

    return Obx(() {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * .05,
          vertical: size.height * .0,
        ),
        child: Row(
          children: [
            // Back Button
            AnimatedOpacity(
              opacity: controller.currentStep.value == 0 ? 1 : 1,
              duration: const Duration(milliseconds: 250),
              child:InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    if (controller.currentStep.value == 0) {
                      Get.back();
                    } else {
                      previous();
                    }
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.primary,
                      // border: Border.all(
                      //   color: isDark
                      //       ? Colors.white.withOpacity(.08)
                      //       : Colors.grey.shade200,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      Get.locale?.languageCode == "ar"
                          ? Iconsax.arrow_circle_right
                          : Iconsax.arrow_circle_left,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            

            SizedBox(width: size.width * .05),

            // Progress
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  ForgotPasswordController.totalSteps,
                  (index) {
                    final current = controller.currentStep.value;

                    final active = index == current;
                    final completed = index < current;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      width: active ? 34 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        color: completed
                            ? primary.withOpacity(.8)
                            : active
                                ? primary
                                : (isDark
                                    ? Colors.white12
                                    : Colors.grey.shade300),
                        boxShadow: active
                            ? [
                                BoxShadow(
                          color: AppColors.primary,
                          blurRadius: 28,
                          offset: const Offset(0, 8),
                        ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Balance
            const SizedBox(width: 48),
          ],
        ),
      );
    });
  }
}