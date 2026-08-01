import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/ActiveWheelCard.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/FortuneConfigCard.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/FortuneWheelPreview.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/ParticipationLimitCard.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/PlageHoraire.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/PremiumButton.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/TrigerEventCard.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/ValidationDialog.dart';

class FortuneWheelConfig extends StatefulWidget {
  final bool isEdit;
  const FortuneWheelConfig({super.key, required this.isEdit});

  @override
  State<FortuneWheelConfig> createState() => _FortuneWheelConfigState();
}

class _FortuneWheelConfigState extends State<FortuneWheelConfig> {
  late final FortuneController controller;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<FortuneController>()) {
      Get.delete<FortuneController>(force: true);
    }
    controller = Get.put(FortuneController(isEdit: widget.isEdit));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: size.height * 0.01),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _circleButton(
                    context,
                    icon: isRTL
                        ? Iconsax.arrow_right_3_copy
                        : Iconsax.arrow_left_2_copy,
                    onTap: () => Get.back(),
                  ),
                ),
                // Align(
                //   alignment: isRTL
                //       ? Alignment.centerRight
                //       : Alignment.centerLeft,
                //   child: FadeSlide(
                //     delayMs: 200,
                //     child: AppText(
                //       "fortune_wheel_configuration",
                //       fontSize: 22,
                //       fontWeight: FontWeight.w800,
                //     ),
                //   ),
                // ),

                // SizedBox(height: size.height * 0.01),

                // Align(
                //   alignment: isRTL
                //       ? Alignment.centerRight
                //       : Alignment.centerLeft,
                //   child: FadeSlide(
                //     delayMs: 250,
                //     child: AppText(
                //       'define_segments_rewards_and_participation_rules',
                //       fontSize: 14,
                //       fontWeight: FontWeight.w400,
                //       color: Theme.of(
                //         context,
                //       ).textTheme.bodySmall?.color?.withOpacity(0.7),
                //     ),
                //   ),
                // ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 280,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ActiveWheelCard(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 300,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FortuneCard(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 350,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: FortunePreviewCard(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 400,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TriggerEventsCard(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 450,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ParticipationLimitsCard(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 500,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GameTimeSlotCard(),
                  ),
                ),
                SizedBox(height: size.height * 0.02),
                FadeSlide(
                  delayMs: 550,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Obx(
                      () => PremiumButton(
                        label: "save".tr,
                        icon: Iconsax.tick_circle,
                        isLoading: controller.isSubmitting.value,
                        color: AppColors.primary,
                        onTap: () async {
                          final issues = controller.validate();
                          if (issues.isNotEmpty) {
                            showValidationErrorsDialog(context, issues);
                            return;
                          }
                          await controller.submit();
                        },
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _circleButton(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = Get.isDarkMode;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(.3)
                : Colors.black.withOpacity(.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 18),
    ),
  );
}
