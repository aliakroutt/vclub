import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/responsive.dart';
import 'package:vclub/Features/Auth/Controllers/MerchantSignUpController.dart';
import 'package:vclub/Features/Auth/Widgets/BackButtonWidget.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';
import 'package:vclub/Features/Auth/Widgets/LanguageSelector.dart';
import 'package:vclub/Features/Auth/Widgets/NextButton.dart';

class CustomPlanRequestScreen extends StatefulWidget {
  const CustomPlanRequestScreen({super.key});

  @override
  State<CustomPlanRequestScreen> createState() =>
      _CustomPlanRequestScreenState();
}

class _CustomPlanRequestScreenState extends State<CustomPlanRequestScreen> {
  final controller = Get.put(MerchantSignUpController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isArabic = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            /// ===== BACKGROUND CIRCLE =====
            Positioned(
              bottom: -size.height * 0.05,
              left: isArabic ? null : -size.width * 0.2,
              right: isArabic ? -size.width * 0.2 : null,
              child: BackgroundCircle(
                size: size.width * 0.55,
                innerSize: size.width * 0.35,
              ),
            ),

            /// ===== LANGUAGE =====
            Positioned(
              top: size.height * 0.07,
              right: size.width * 0.05,
              child: const LanguageSelector(),
            ),

            /// ===== CONTENT =====
            SafeArea(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.06,
                    vertical: size.height * 0.02,
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.1),

                      /// ===== CARD =====
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF151515)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withOpacity(0.06)
                                : Colors.grey.shade200,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.4)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            /// ===== DECOR CIRCLES =====
                            Positioned(
                              top: -60,
                              right: isArabic ? null : -60,
                              left: isArabic ? -60 : null,
                              child: IgnorePointer(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    BackgroundCircle(
                                      size: size.width * 0.45,
                                      innerSize: size.width * 0.35,
                                    ),
                                    BackgroundCircle(
                                      size: size.width * 0.25,
                                      innerSize: size.width * 0.15,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// ===== FORM =====
                            Padding(
                              padding: EdgeInsets.all(size.width * 0.05),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  /// ICON BADGE
                                  Container(
                                    width: size.width * 0.16,
                                    height: size.width * 0.16,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Icon(
                                      Iconsax.message_text_1,
                                      color: AppColors.primary,
                                      size: size.width * 0.08,
                                    ),
                                  ),

                                  SizedBox(height: size.height * 0.025),

                                  /// TITLE
                                  AppText(
                                    "custom_plan_title".tr,
                                    fontSize: size.width * 0.065,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),

                                  SizedBox(height: size.height * 0.01),

                                  /// SUBTITLE
                                  AppText(
                                    "custom_plan_subtitle".tr,
                                    fontSize: size.width * 0.036,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey,
                                    height: 1.4,
                                  ),

                                  SizedBox(height: size.height * 0.035),

                                  /// MESSAGE LABEL
                                  AppText(
                                    "your_message".tr,
                                    fontSize: Responsive.scaleW(context, 13),
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF2D3142),
                                  ),

                                  SizedBox(height: size.height * 0.01),

                                  /// BIG MESSAGE FIELD
                                  TextField(
                                    controller:
                                        controller.quoteMessageController,
                                    minLines: 7,
                                    maxLines: 10,
                                    textDirection: isArabic
                                        ? TextDirection.rtl
                                        : TextDirection.ltr,
                                    textAlign: isArabic
                                        ? TextAlign.right
                                        : TextAlign.left,
                                    style: TextStyle(
                                      fontSize: Responsive.scaleW(context, 15),
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF2D3142),
                                      fontWeight: FontWeight.w400,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: "describe_your_needs".tr,
                                      hintStyle: TextStyle(
                                        fontSize:
                                            Responsive.scaleW(context, 13),
                                        color: isDark
                                            ? Colors.white38
                                            : const Color(0xFFADB5BD),
                                        fontWeight: FontWeight.w400,
                                      ),
                                      filled: true,
                                      fillColor: isDark
                                          ? Colors.white.withOpacity(0.06)
                                          : const Color(0xFFF4F5F7),
                                      contentPadding: EdgeInsets.all(
                                        Responsive.scaleW(context, 16),
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Responsive.scaleW(context, 16),
                                        ),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Responsive.scaleW(context, 16),
                                        ),
                                        borderSide: BorderSide(
                                          color: isDark
                                              ? Colors.white.withOpacity(0.08)
                                              : const Color(0xFFE2E5EA),
                                          width: 1.2,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                          Responsive.scaleW(context, 16),
                                        ),
                                        borderSide: const BorderSide(
                                          color: AppColors.primary,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: size.height * 0.035),

                                  /// BUTTONS
                                  Row(
                                    children: [
                                      BackButtonWidget(
                                        text: "back",
                                        width: size.width * 0.35,
                                        onTap: () => Get.back(),
                                      ),
                                      const Spacer(),
                                      Obx(
                                        () => NextButton(
                                          text: controller
                                                  .isSubmittingQuote.value
                                              ? "loading".tr
                                              : "submit".tr,
                                          isEnabled: !controller
                                              .isSubmittingQuote.value,
                                          width: size.width * 0.35,
                                          onTap: () =>
                                              controller.submitQuoteRequest(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.04),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}