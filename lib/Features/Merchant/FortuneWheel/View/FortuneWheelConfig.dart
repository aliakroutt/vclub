import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/FortuneConfigCard.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/FortuneWheelPreview.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/ParticipationLimitCard.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/PlageHoraire.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/TrigerEventCard.dart';

class FortuneWheelConfig extends StatefulWidget {
  const FortuneWheelConfig({super.key});

  @override
  State<FortuneWheelConfig> createState() => _FortuneWheelConfigState();
}

class _FortuneWheelConfigState extends State<FortuneWheelConfig> {
  final controller = Get.put(FortuneController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.01),

                  Align(
                    alignment: isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 200,
                      child: AppText(
                        "fortune_wheel_configuration",
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: size.height * 0.01),

                  Align(
                    alignment: isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 250,
                      child: AppText(
                        'define_segments_rewards_and_participation_rules',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                 FadeSlide(
                      delayMs: 300,
                      child:  FortuneCard()),
                 SizedBox(height: size.height * 0.02),
                FadeSlide(
                      delayMs: 350,
                      child: FortunePreviewCard()),
                  SizedBox(height: size.height * 0.02),
                FadeSlide(
                      delayMs: 400,
                      child: TriggerEventsCard()),
                 SizedBox(height: size.height * 0.02),
                FadeSlide(
                      delayMs: 450,
                      child:  ParticipationLimitsCard()),
                 SizedBox(height: size.height * 0.02),
                FadeSlide(
                      delayMs: 500,
                      child: GameTimeSlotCard()),
                 SizedBox(height: size.height * 0.02),     
                FadeSlide(delayMs: 550, child:  SizedBox(
                    width: double.infinity,
                    height: size.height * 0.062,
                    child: ElevatedButton(
                      onPressed: () {},
                      style:
                          ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: AppColors.primary.withOpacity(0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ).copyWith(
                            elevation: WidgetStateProperty.resolveWith(
                              (states) =>
                                  states.contains(WidgetState.pressed) ? 0 : 4,
                            ),
                            shadowColor: WidgetStateProperty.all(
                              AppColors.primary.withOpacity(0.35),
                            ),
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Iconsax.tick_circle,
                            size: 20,
                            color: Colors.white,
                          ),
                          SizedBox(width: size.width * 0.025),
                          AppText(
                            "save".tr,
                            fontSize: size.width * 0.038,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  )),
                 

                

                  SizedBox(height: size.height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}