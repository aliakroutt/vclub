import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/API/auth_api_client.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/TokenStorage.dart';
import 'package:vclub/Core/Widgets/AppLoader.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';
import 'package:vclub/Features/Auth/Widgets/Client/Success.dart';

// ─────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────

class OtpController extends GetxController {
  final seconds = 55.obs;
  final canResend = false.obs;
  final isOtpValid = false.obs; // ← reactive, used by Obx safely

  final otpController = TextEditingController();
  Future<void> verifyOtp_api({
    required String email,
    required String code,
  }) async {
    try {
      AppLoader.show();

      final response = await AuthApiClient.verifyOtp(email: email, code: code);

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        AppSnackBar.error("Unexpected server response");
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final accessToken = data["accessToken"] as String?;
        final refreshToken = data["refreshToken"] as String?;

        if (accessToken == null || refreshToken == null) {
          AppLoader.hide();
          AppSnackBar.error("Login response missing tokens");
          return;
        }
        await TokenStorage.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
        AppLoader.hide();
        AppNavigator.to(Success(email: email));
        AppSnackBar.success(
          data["message"]?.toString() ?? "OTP verified successfully",
        );
      } else {
        AppLoader.hide();
        AppSnackBar.error(
          data["message"]?.toString() ?? "OTP verification failed",
        );
      }
    } on DioException catch (e) {
      AppLoader.hide();
      final data = e.response?.data;

      final message = data is Map<String, dynamic>
          ? data["message"]?.toString()
          : null;

      AppSnackBar.error(message ?? "Network error, please try again");
    } catch (e, st) {
      AppLoader.hide();
      debugPrint("❌ VERIFY OTP ERROR: $e");
      debugPrint("$st");

      AppSnackBar.error("Unexpected error occurred");
    }
  }

  Future<void> resendOtp_api({required String email}) async {
    try {
      AppLoader.show();

      final response = await AuthApiClient.resendOtp(email: email);

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        AppSnackBar.error("unexpected_server_response".tr);
        return;
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        AppLoader.hide();
        AppSnackBar.success(
          data["message"]?.toString() ?? "otp_resent_successfully".tr,
        );

        startTimer();
      } else {
        AppLoader.hide();
        AppSnackBar.error(
          data["message"]?.toString() ?? "otp_resend_failed".tr,
        );
      }
    } on DioException catch (e) {
      AppLoader.hide();
      final data = e.response?.data;

      final message = data is Map<String, dynamic>
          ? data["message"]?.toString()
          : null;

      AppSnackBar.error(message ?? "network_error".tr);
    } catch (e, st) {
      AppLoader.hide();
      debugPrint("❌ RESEND OTP ERROR: $e");
      debugPrint("$st");

      AppSnackBar.error("unexpected_error".tr);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // keep isOtpValid in sync with the text field
    otpController.addListener(() {
      isOtpValid.value = otpController.text.length == 6;
    });
    startTimer();
  }

  void startTimer() {
    canResend.value = false;
    seconds.value = 55;

    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (seconds.value == 0) {
        canResend.value = true;
        return false;
      }
      seconds.value--;
      return true;
    });
  }

  Future<void> verifyOtp(String email, String code) async {
    await verifyOtp_api(email: email, code: code);
  }

  void resendOtp() {
    startTimer();
    debugPrint("Resend OTP");
  }

  void editInfo() {
    Get.back();
  }

  @override
  void onClose() {
    otpController.dispose();
    super.onClose();
  }
}

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────

class VerifyCode extends StatefulWidget {
  final String email;
  const VerifyCode({super.key, required this.email});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  late final OtpController controller;

  @override
  void initState() {
    super.initState();
    // Register once in initState, not inside build()
    controller = Get.put(OtpController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: OtpVerificationCard(
            email: widget.email,
            seconds: controller.seconds,
            canResend: controller.canResend,
            isOtpValid: controller.isOtpValid, // ← passed as RxBool
            otpController: controller.otpController,
            onEditInfo: controller.editInfo,
            controller: controller,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Card widget
// ─────────────────────────────────────────────

class OtpVerificationCard extends StatelessWidget {
  final String email;
  final RxInt seconds;
  final RxBool canResend;
  final RxBool isOtpValid;
  final TextEditingController otpController;
  final VoidCallback onEditInfo;
  final OtpController controller;

  const OtpVerificationCard({
    super.key,
    required this.email,
    required this.seconds,
    required this.canResend,
    required this.isOtpValid,
    required this.otpController,
    required this.onEditInfo,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final tt = Theme.of(context).textTheme;
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenW = MediaQuery.of(context).size.width;
    final circleSize = (screenW * 0.42).clamp(140.0, 200.0);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF151515) : Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.06)
              : primary.withOpacity(.12),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.4)
                : primary.withOpacity(.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // ── Top background circle ──
            Positioned(
              top: -circleSize * 0.4,
              right: isArabic ? null : -circleSize * 0.4,
              left: isArabic ? -circleSize * 0.3 : null,
              child: IgnorePointer(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BackgroundCircle(
                      size: circleSize,
                      innerSize: circleSize * 0.75,
                    ),
                    BackgroundCircle(
                      size: circleSize * 0.5,
                      innerSize: circleSize * 0.25,
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom accent circle ──
            Positioned(
              bottom: -circleSize * 0.25,
              left: isArabic ? null : -circleSize * 0.25,
              right: isArabic ? -circleSize * 0.25 : null,
              child: IgnorePointer(
                child: Container(
                  width: circleSize * 0.4,
                  height: circleSize * 0.4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primary.withOpacity(isDark ? 0.03 : 0.03),
                  ),
                ),
              ),
            ),

            // ── Main content ──
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Icon
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withOpacity(isDark ? 0.15 : 0.12),
                    ),
                    child: Icon(Iconsax.sms, color: primary, size: 28),
                  ),

                  const SizedBox(height: 16),

                  // Title
                  AppText(
                    "verify_your_email".tr,
                    textAlign: TextAlign.center,
                    fontSize: tt.titleLarge?.fontSize ?? 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),

                  const SizedBox(height: 14),

                  // Subtitle
                  AppText(
                    "otp_sent_to".tr,
                    textAlign: TextAlign.center,
                    fontSize: tt.bodySmall?.fontSize ?? 13,
                    fontWeight: FontWeight.w400,
                    color: isDark ? Colors.grey.shade400 : Colors.grey,
                  ),

                  const SizedBox(height: 4),

                  // Email
                  AppText(
                    email,
                    textAlign: TextAlign.center,
                    fontSize: tt.bodyMedium?.fontSize ?? 14,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),

                  const SizedBox(height: 20),

                  // OTP input
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    style: const TextStyle(
                      letterSpacing: 8,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "------",
                      hintStyle: TextStyle(
                        letterSpacing: 8,
                        color: isDark
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(
                          color: isDark
                              ? Colors.white.withOpacity(0.06)
                              : primary.withOpacity(.2),
                        ),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: primary),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Obx(() {
                      final valid = isOtpValid.value;

                      return ElevatedButton(
                        onPressed: valid
                            ? () {
                                controller.verifyOtp(
                                  email,
                                  otpController.text.trim(),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: valid
                              ? primary
                              : primary.withOpacity(.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: AppText(
                          "verify_code".tr,
                          color: valid ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 20),

                  // Resend timer / button
                  Obx(() {
                    if (canResend.value) {
                      return GestureDetector(
                        onTap: () {
                          controller.resendOtp_api(email: email);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.refresh, color: primary, size: 18),
                            const SizedBox(width: 6),
                            AppText(
                              "resend_code".tr,
                              fontSize: 14,
                              color: primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ],
                        ),
                      );
                    }

                    return AppText(
                      "resend_in".trParams({
                        "seconds": seconds.value.toString(),
                      }),
                      color: isDark ? Colors.grey.shade400 : Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    );
                  }),

                  const SizedBox(height: 16),

                  // Edit info
                  InkWell(
                    onTap: onEditInfo,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isArabic
                              ? Iconsax.arrow_right_1_copy
                              : Iconsax.arrow_left_copy,
                          size: 18,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        AppText(
                          "edit_information".tr,
                          color: Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
