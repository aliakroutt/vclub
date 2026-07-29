import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/PasswordField.dart';
import 'package:vclub/Core/Widgets/app_text_field.dart';
import 'package:vclub/Features/Auth/Controllers/MerchantSignUpController.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';
import 'package:vclub/Features/Auth/Widgets/AuthSignInText.dart';
import 'package:vclub/Features/Auth/Widgets/BackButtonWidget.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';
import 'package:vclub/Features/Auth/Widgets/LanguageSelector.dart';
import 'package:vclub/Features/Auth/Widgets/Merchant/CompanyData.dart';
import 'package:vclub/Features/Auth/Widgets/NextButton.dart';

class MerchantDetailsForm extends StatefulWidget {
  const MerchantDetailsForm({super.key});

  @override
  State<MerchantDetailsForm> createState() => _MerchantDetailsFormState();
}

class _MerchantDetailsFormState extends State<MerchantDetailsForm> {
  final controller = Get.put(MerchantSignUpController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return KeyboardDismissOnTap(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,

        body: Stack(
          children: [
            /// ===== BACKGROUND CIRCLE =====
            Positioned(
              bottom: -size.height * 0.05,
              left: Get.locale?.languageCode == 'ar' ? null : -size.width * 0.2,
              right: Get.locale?.languageCode == 'ar'
                  ? -size.width * 0.2
                  : null,
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
                      SizedBox(height: size.height * 0.08),

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
                              right: Get.locale?.languageCode == 'ar'
                                  ? null
                                  : -60,
                              left: Get.locale?.languageCode == 'ar'
                                  ? -60
                                  : null,
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
                                  AppText(
                                    "your_details".tr,
                                    fontSize: size.width * 0.065,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),

                                  SizedBox(height: size.height * 0.03),

                                  /// FIRST NAME
                                  AppTextField(
                                    label: "first_name".tr,
                                    hint: "enter_first_name".tr,
                                    controller: controller.firstNameController,
                                    prefixIcon: Iconsax.user,
                                  ),

                                  SizedBox(height: size.height * 0.02),

                                  /// LAST NAME
                                  AppTextField(
                                    label: "last_name".tr,
                                    hint: "enter_last_name".tr,
                                    controller: controller.lastNameController,
                                    prefixIcon: Iconsax.user_tag,
                                  ),

                                  SizedBox(height: size.height * 0.02),

                                  /// EMAIL
                                  AppTextField(
                                    label: "email".tr,
                                    hint: "enter_email".tr,
                                    controller: controller.emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Iconsax.sms,
                                  ),

                                  SizedBox(height: size.height * 0.02),

                                  /// PASSWORD
                                  AppPasswordField(
                                    label: "password".tr,
                                    hint: "••••••••",
                                    controller: controller.passwordController,
                                    isObscure: controller.isPasswordObscure,
                                    onToggle: controller.togglePassword,
                                    prefixIcon: Iconsax.lock,
                                  ),

                                  SizedBox(height: size.height * 0.02),

                                  /// CONFIRM PASSWORD
                                  AppPasswordField(
                                    label: "confirm_password".tr,
                                    hint: "••••••••",
                                    controller:
                                        controller.confirmPasswordController,
                                    isObscure:
                                        controller.isConfirmPasswordObscure,
                                    onToggle: controller.toggleConfirmPassword,
                                    prefixIcon: Iconsax.lock,
                                  ),

                                  SizedBox(height: size.height * 0.03),

                                  /// BUTTONS
                                  Row(
                                    children: [
                                      BackButtonWidget(
                                        text: "back",
                                        width: size.width * 0.35,
                                        onTap: () => Get.back(),
                                      ),
                                      const Spacer(),
                                      NextButton(
                                        text: "next",
                                        isEnabled: true,
                                        width: size.width * 0.35,
                                        onTap: () {
                                          if (controller
                                              .validateMerchantDetails()) {
                                            AppNavigator.to(CompanyData());
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      /// LOGIN LINK
                      AuthSignInText(onTap: () => AppNavigator.to(Login())),

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
