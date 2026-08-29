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
  final logincontroller = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.08),
      child: SizedBox(
        width: double.infinity,
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

            SizedBox(height: size.height * 0.032),
            FadeSlide(delayMs: 650, child: _OrDivider()),
            SizedBox(height: size.height * 0.032),

            FadeSlide(
              delayMs: 680,
              child: Obx(() => _GoogleSignInButton(
                    isLoading: logincontroller.isGoogleLoading.value,
                    onTap: logincontroller.loginWithGoogle,
                  )),
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

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08);

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'or_continue_with'.tr,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withOpacity(0.45) : Colors.black.withOpacity(0.4),
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, thickness: 1)),
      ],
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _GoogleSignInButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(50),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.05),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _GoogleGlyph(),
                      const SizedBox(width: 12),
                      Text(
                        'continue_with_google'.tr,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
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

/// Multi-color "G" glyph built from stacked colored arcs — avoids needing
/// an external asset/svg package just for the Google mark.
class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = size.width * 0.22;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    void drawArc(double startDeg, double sweepDeg, Color color) {
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        rect,
        startDeg * 3.1415926535 / 180,
        sweepDeg * 3.1415926535 / 180,
        false,
        paint,
      );
    }

    // Four Google brand color arcs, angles approximate the real mark.
    drawArc(-10, 100, const Color(0xFF4285F4)); // blue
    drawArc(90, 80, const Color(0xFF34A853));   // green
    drawArc(170, 80, const Color(0xFFFBBC05));  // yellow
    drawArc(250, 100, const Color(0xFFEA4335)); // red

    // Horizontal bar of the "G"
    final barPaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.42, size.width * 0.42, size.height * 0.16),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}