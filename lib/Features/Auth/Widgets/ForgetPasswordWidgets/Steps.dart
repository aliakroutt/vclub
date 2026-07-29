import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/PasswordField.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Core/Widgets/app_text_field.dart';
import 'package:vclub/Features/Auth/Controllers/ForgetPasswordController.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class EmailStep extends GetView<ForgotPasswordController> {
  final VoidCallback next ; 
   EmailStep(this.next, {super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final primary = Theme.of(context).primaryColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * .07,
          vertical: height * .02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * .03),

            /// ── ICON
            FadeSlide(
              delayMs: 100,
              child: Center(
                child: Container(
                  width: width * .22,
                  height: width * .22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(.08),
                    border: Border.all(
                      color: primary.withOpacity(.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(.08),
                        blurRadius: 35,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Iconsax.lock,
                    size: width * .10,
                    color: primary,
                  ),
                ),
              ),
            ),

            SizedBox(height: height * .038),

            /// ── TITLE
            FadeSlide(
              delayMs: 200,
              child: Center(
                child: AppText(
                  "title_email",
                  fontSize: width * .075,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: height * .015),

            /// ── SUBTITLE
            FadeSlide(
              delayMs: 300,
              child: Center(
                child: AppText(
                  "subtitle_email",
                  textAlign: TextAlign.center,
                  fontSize: width * .040,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(.65),
                  maxLines: 3,
                ),
              ),
            ),

            SizedBox(height: height * .055),

            /// ── EMAIL FIELD
            FadeSlide(
              delayMs: 400,
              child: AppTextField(
                label: "label_email".tr,
                hint: "hint_email".tr,
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Iconsax.sms,
              ),
            ),

            SizedBox(height: height * .05),

            /// ── BUTTON
            FadeSlide(
              delayMs: 500,
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Iconsax.sms_notification),
                      const SizedBox(width: 10),
                      AppText(
                        "btn_send_code",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
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



class OtpStep extends GetView<ForgotPasswordController> {
  final VoidCallback next ;
  const OtpStep(this.next, {super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final primary = Theme.of(context).primaryColor;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * .07,
          vertical: height * .02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: height * .03),

            /// ───────── ICON
            FadeSlide(
              delayMs: 100,
              child: Container(
                width: width * .22,
                height: width * .22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withOpacity(.08),
                  border: Border.all(color: primary.withOpacity(.15)),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(.08),
                      blurRadius: 35,
                    )
                  ],
                ),
                child: Icon(
                  Iconsax.sms_tracking,
                  size: width * .1,
                  color: primary,
                ),
              ),
            ),

            SizedBox(height: height * .038),

            /// ───────── TITLE
            FadeSlide(
              delayMs: 200,
              child: AppText(
                "title_otp",
                fontSize: width * .07,
                fontWeight: FontWeight.w700,
                textAlign: TextAlign.center,
              ),
            ),

            SizedBox(height: height * .015),

            /// ───────── SUBTITLE
            FadeSlide(
              delayMs: 300,
              child: AppText(
                "subtitle_otp".trParams({
                  "email": controller.emailController.text,
                }),
                textAlign: TextAlign.center,
                fontSize: width * .04,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(.6),
              ),
            ),

            SizedBox(height: height * .05),

            /// ───────── LABEL
            FadeSlide(
              delayMs: 350,
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppText(
                  "label_otp",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),

            SizedBox(height: height * .015),

            /// ───────── OTP FIELDS
            FadeSlide(
              delayMs: 450,
              child: _OtpFields(controller: controller),
            ),

            SizedBox(height: height * .04),

            /// ───────── RESEND
            FadeSlide(
  delayMs: 550,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      AppText(
        "resend_question".tr,
        fontSize: 13,
        color: Colors.grey,
      ),
      const SizedBox(width: 5),
      GestureDetector(
        onTap: controller.resendCode,
        child: AppText(
          "resend_action".tr,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).primaryColor,
        ),
      ),
    ],
  ),
),

            SizedBox(height: height * .05),

            /// ───────── VERIFY BUTTON
            FadeSlide(
              delayMs: 650,
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: AppText(
                    "btn_verify_code",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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

class NewPasswordStep extends StatelessWidget {
  const NewPasswordStep({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    final primary = Theme.of(context).primaryColor;

    final controller = Get.find<ForgotPasswordController>();

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * .07,
          vertical: height * .02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: height * .03),

            /// ───────── ICON
            FadeSlide(
              delayMs: 100,
              child: Center(
                child: Container(
                  width: width * .22,
                  height: width * .22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(.08),
                    border: Border.all(
                      color: primary.withOpacity(.15),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: primary.withOpacity(.08),
                        blurRadius: 35,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Iconsax.lock_1,
                    size: width * .10,
                    color: primary,
                  ),
                ),
              ),
            ),

            SizedBox(height: height * .04),

            /// ───────── TITLE
            FadeSlide(
              delayMs: 200,
              child: Center(
                child: AppText(
                  "title_password",
                  fontSize: width * .075,
                  fontWeight: FontWeight.w700,
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            SizedBox(height: height * .015),

            /// ───────── SUBTITLE
            FadeSlide(
              delayMs: 300,
              child: Center(
                child: AppText(
                  "subtitle_password",
                  textAlign: TextAlign.center,
                  fontSize: width * .04,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withOpacity(.65),
                ),
              ),
            ),

            SizedBox(height: height * .055),

            /// ───────── NEW PASSWORD
            FadeSlide(
              delayMs: 400,
              child: AppPasswordField(
                label: "label_new_password".tr,
                hint: "••••••••",
                controller: controller.newPasswordController,
                isObscure: controller.isNewPasswordHidden,
                onToggle: controller.toggleNewPassword,
                prefixIcon: Iconsax.lock,
              ),
            ),

            SizedBox(height: height * .02),

            /// ───────── CONFIRM PASSWORD
            FadeSlide(
              delayMs: 500,
              child: AppPasswordField(
                label: "label_confirm_password".tr,
                hint: "••••••••",
                controller: controller.confirmPasswordController,
                isObscure: controller.isConfirmPasswordHidden,
                onToggle: controller.toggleConfirmPassword,
                prefixIcon: Iconsax.lock,
              ),
            ),

            SizedBox(height: height * .05),

            /// ───────── BUTTON
            FadeSlide(
              delayMs: 650,
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  onPressed: controller.resetPassword,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: AppText(
                    "btn_reset_password",
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
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


class _OtpFields extends StatelessWidget {
  final ForgotPasswordController controller;

  const _OtpFields({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => _OtpBox(
          index: index,
          width: width,
          controller: controller,
        ),
      ),
    );
  }
}
class _OtpBox extends StatefulWidget {
  final int index;
  final double width;
  final ForgotPasswordController controller;

  const _OtpBox({
    super.key,
    required this.index,
    required this.width,
    required this.controller,
  });

  @override
  State<_OtpBox> createState() => _OtpBoxState();
}

class _OtpBoxState extends State<_OtpBox> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();

    widget.controller.otpFocus[widget.index].addListener(() {
      if (mounted) {
        setState(() {
          _focused = widget.controller.otpFocus[widget.index].hasFocus;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      width: widget.width * .12,
      height: widget.width * .14,
      decoration: BoxDecoration(
        color: primary.withOpacity(_focused ? .12 : .06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _focused ? primary : primary.withOpacity(.35),
          width: _focused ? 2 : 1.3,
        ),
        boxShadow: _focused
            ? [
                BoxShadow(
                  color: primary.withOpacity(.20),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller.otpControllers[widget.index],
        focusNode: widget.controller.otpFocus[widget.index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        cursorColor: primary,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primary,
        ),
        decoration: const InputDecoration(
          counterText: "",
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
        onChanged: (value) {
          final index = widget.index;

          if (value.isNotEmpty) {
            if (index < 5) {
              FocusScope.of(context)
                  .requestFocus(widget.controller.otpFocus[index + 1]);
            } else {
              // Last digit -> hide keyboard
              FocusScope.of(context).unfocus();

              // Optional:
              // widget.controller.verifyOtp();
            }
          } else {
            if (index > 0) {
              FocusScope.of(context)
                  .requestFocus(widget.controller.otpFocus[index - 1]);
            }
          }
        },
      ),
    );
  }
}