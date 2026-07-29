import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/LoyaltyModeController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/BonusRulesCard.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/CashBackConfigurationCard.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LimitesCapsCard.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LoyaltyModeSelector.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/PointsConfigurationCard.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ProgramField.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/StampsConfigurationCard.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/VipConfigurationCard.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/VipLevelCard.dart';

class ManageLoyalty extends StatefulWidget {
  const ManageLoyalty({super.key});

  @override
  State<ManageLoyalty> createState() => _ManageLoyaltyState();
}

class _ManageLoyaltyState extends State<ManageLoyalty> {
  final controller = Get.put(LoyaltyModeController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        appBar: AppBar(
          // backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: _circleButton(
              context,
              icon: isRTL
                  ? Iconsax.arrow_right_3_copy
                  : Iconsax.arrow_left_2_copy,
              onTap: () => Get.back(),
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.03),
                  Align(
                    alignment: isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 250,
                      child: AppText(
                        'create_manage_loyalty_subtitle'.tr,
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
                    delayMs: 220,
                    child: ProgramNameField(controller: controller),
                  ),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 300, child: LoyaltyModeSelector()),
                  SizedBox(height: size.height * 0.02),

                  FadeSlide(
                    delayMs: 350,
                    child: Obx(() {
                      switch (controller.selectedMode.value) {
                        case LoyaltyMode.points:
                          return PointsConfigurationCard();

                        case LoyaltyMode.stamps:
                          return StampsConfigurationCard();

                        case LoyaltyMode.cashback:
                          return CashbackConfigurationCard();
                      }
                    }),
                  ),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 400, child: BonusRulesCard()),
                  SizedBox(height: size.height * 0.02),

                  FadeSlide(delayMs: 450, child: VipConfigurationCard()),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 500, child: LimitsCapsCard()),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 550, child: VIPLevelsCard()),
                  SizedBox(height: size.height * 0.02),

                  FadeSlide(
                    delayMs: 550,
                    child: Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: size.height * 0.062,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : controller.submitProgram,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Row(
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
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.05),
                ],
              ),
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
