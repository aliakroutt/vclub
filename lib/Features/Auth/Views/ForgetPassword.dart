import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Features/Auth/Controllers/ForgetPasswordController.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';
import 'package:vclub/Features/Auth/Widgets/ForgetPasswordWidgets/Steps.dart';
import 'package:vclub/Features/Auth/Widgets/ForgetPasswordWidgets/StepsDots.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final controller = Get.put(ForgotPasswordController());
  final PageController pageController = PageController();
  Future<void> nextStep() async {
    if (controller.currentStep.value >= ForgotPasswordController.totalSteps - 1)
      return;

    controller.currentStep.value++;

    await pageController.animateToPage(
      controller.currentStep.value,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> previousStep() async {
    if (controller.currentStep.value == 0) return;

    controller.currentStep.value--;

    await pageController.animateToPage(
      controller.currentStep.value,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> goToStep(int step) async {
    if (step < 0 || step >= ForgotPasswordController.totalSteps) return;

    controller.currentStep.value = step;

    await pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeInOutCubic,
    );
  }

  Future<void> sendCode() async {
    final success = await controller.sendCode();
    if (success) {
      nextStep();
    }
  }

  Future<void> verifyOtpStep() async {
    final success = await controller.verifyOtp();
    if (success) {
      nextStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return KeyboardDismissOnTap(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SingleChildScrollView(
          // ✅ scroll when keyboard appears
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            height: size.height, // ✅ full screen height
            child: Stack(
              children: [
                Positioned(
                  top: -size.height * 0.05,
                  right: -size.width * 0.25,
                  child: BackgroundCircle(
                    size: size.width * 0.7,
                    innerSize: size.width * 0.45,
                  ),
                ),

                Positioned(
                  bottom: -size.height * 0.05,
                  left: -size.width * 0.20,
                  child: BackgroundCircle(
                    size: size.width * 0.55,
                    innerSize: size.width * 0.35,
                  ),
                ),

                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 25),

                      ForgotPasswordSteps(() {
                        previousStep();
                      }),

                      const SizedBox(height: 35),

                      Expanded(
                        child: PageView(
                          controller: pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            EmailStep(sendCode),
                            OtpStep(verifyOtpStep),
                            const NewPasswordStep(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
