import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Core/Widgets/AppDateField.dart';
import 'package:vclub/Core/Widgets/AppPhoneField.dart';
import 'package:vclub/Core/Widgets/PasswordField.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Core/Widgets/app_text_field.dart';
import 'package:vclub/Features/Auth/Controllers/ClientSignupController.dart';
import 'package:vclub/Features/Auth/Widgets/AuthSignInText.dart';
import 'package:vclub/Features/Auth/Widgets/Merchant/SectionCard.dart';
import 'package:vclub/Features/Auth/Widgets/NextButton.dart';

class ClientData extends StatefulWidget {
  const ClientData({super.key});

  @override
  State<ClientData> createState() => _ClientDataState();
}

class _ClientDataState extends State<ClientData> {
  final controller = Get.put(ClientSignUpController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SizedBox(
      height: size.height * 0.7,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
          child: Column(
            key: const ValueKey("client"),
            children: [
              FadeSlide(
                delayMs: 200,
                child: PremiumSectionCard(
                  title: "join_vclub".tr,
                  subtitle: "create_client_space".tr,
                  icon: Iconsax.user,
                  child: Column(
                    children: [
                      AppTextField(
                        label: "first_name".tr,
                        hint: "enter_first_name".tr,
                        controller: controller.firstNameController,
                        prefixIcon: Iconsax.user,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: "last_name".tr,
                        hint: "enter_last_name".tr,
                        controller: controller.lastNameController,
                        prefixIcon: Iconsax.user_tag,
                      ),

                      const SizedBox(height: 16),

                      AppTextField(
                        label: "email".tr,
                        hint: "enter_email".tr,
                        controller: controller.emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Iconsax.sms,
                      ),

                      const SizedBox(height: 16),

                      // ── Premium phone field with country picker ──────
                      AppPhoneField(
                        label: "phone".tr,
                        hint: "enter_phone".tr,
                        controller: controller.phoneController,
                        defaultIso2: 'TN',
                      ),

                      const SizedBox(height: 16),

                      // ── Premium birthday field with calendar picker ──
                      AppDateField(
                        label: "date_of_birth_optional".tr,
                        hint: "select_date".tr,
                        controller: controller.birthdayController,
                        prefixIcon: Iconsax.calendar,
                        lastDate: DateTime.now(),
                      ),

                      const SizedBox(height: 16),
                      AppPasswordField(
                        label: "password".tr,
                        hint: "••••••••",
                        controller: controller.passwordController,
                        isObscure: controller.isPasswordHidden,
                        onToggle: controller.togglePasswordVisibility,
                        prefixIcon: Iconsax.lock,
                      ),

                      const SizedBox(height: 16),
                      AppPasswordField(
                        label: "confirm_password".tr,
                        hint: "••••••••",
                        controller: controller.confirmPasswordController,
                        isObscure: controller.isConfirmPasswordHidden,
                        onToggle: controller.toggleConfirmPasswordVisibility,
                        prefixIcon: Iconsax.lock,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),
              NextButton(
                text: "continue",
                isEnabled: true,
                width: size.width,
                onTap: () {
                  if (controller.validateRegister()) {
                  controller.signup_api();
                  }
                  
                
                },
              ),
              SizedBox(height: size.height * 0.03),
              AuthSignInText(onTap: () => Get.back()),
              SizedBox(height: size.height * 0.06),
            ],
          ),
        ),
      ),
    );
  }
}