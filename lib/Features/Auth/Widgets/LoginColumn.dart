import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/AppButton.dart';
import 'package:vclub/Core/Widgets/PasswordField.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Core/Widgets/app_text_field.dart';
import 'package:vclub/Features/Auth/Controllers/Login_Controller.dart';
import 'package:vclub/Features/Auth/Views/ForgetPassword.dart';
import 'package:vclub/Features/Auth/Views/SignUp.dart';
import 'package:vclub/Features/Auth/Widgets/DontHaveAccountText.dart';
import 'package:vclub/Features/Auth/Widgets/ForgotPassword.dart';
import 'package:vclub/Features/Auth/Widgets/LoginHeader.dart';

class LoginColumn extends StatefulWidget {
  const LoginColumn({super.key});

  @override
  State<LoginColumn> createState() => _LoginColumnState();
}

class _LoginColumnState extends State<LoginColumn> {
  // final emailController = TextEditingController();
  // final passwordController = TextEditingController();
  // final isPasswordObscure = true.obs; // ← owns the state
  // final is_loading = false.obs;
  // void togglePassword() => isPasswordObscure.value = !isPasswordObscure.value;
  final logincontroller = Get.put(LoginController());
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: SizedBox(
        width: double.infinity, // ✅ IMPORTANT FIX
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FadeSlide(
              delayMs: 200,
              child: AuthHeader(
                title: 'sign_in',
                subtitle: 'welcome_back_to_vclub',
              ),
            ),

            SizedBox(height: size.height * 0.05),

            FadeSlide(
              delayMs: 300,
              child: AppTextField(
                label: 'email'.tr,
                hint: "enter_email".tr,
                controller: logincontroller.emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Iconsax.sms,
              ),
            ),

            SizedBox(height: size.height * 0.03),

            FadeSlide(
              delayMs: 400,
              child: AppPasswordField(
                label: 'password'.tr,
                hint: '••••••••',
                controller: logincontroller.passwordController,
                isObscure: logincontroller.isPasswordHidden,
                onToggle: logincontroller.togglePassword,
                prefixIcon: Iconsax.lock,
              ),
            ),
            SizedBox(height: size.height * 0.015),
            FadeSlide(delayMs: 500, child: ForgetPasswordText(onTap: () {
             AppNavigator.to(ForgetPassword());
            })),
            SizedBox(height: size.height * 0.042),
            FadeSlide(
              delayMs: 600,
              child: AppButton(
                borderRadius: 50,
                text: "sign_in_bt",
                onPressed: logincontroller.login,
                isLoading: logincontroller.isLoading,
              ),
            ),
            SizedBox(height: size.height * 0.042),
            FadeSlide(delayMs: 700, child: AuthFooterText(onTap: () {
               

            AppNavigator.to(SignUp());
            })),
          ],
        ),
      ),
    );
  }
}
