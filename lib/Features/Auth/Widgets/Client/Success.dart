import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Core/Widgets/AppLoader.dart';
import 'package:vclub/Features/Auth/Services/ClientService.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';
import 'package:vclub/Features/Auth/Widgets/NextButton.dart';
import 'package:vclub/Features/Client/Main/Views/MainScreen.dart';

class Success extends StatefulWidget {
  final String email;
  const Success({super.key, required this.email});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {
  Future<void> loadClientProfileAndOpenAccount() async {
    try {
      AppLoader.show();

      final profile = await ClientService.profile();

      if (profile == null) {
        AppSnackBar.error("failed_load_profile".tr);
        return;
      }

      await ClientController.to.saveClient(profile);
      AppLoader.hide();
      AppNavigator.to(MainScreen()); // Replace with your account screen
    } on DioException catch (e) {
      AppLoader.hide();
      final data = e.response?.data;

      final message = data is Map<String, dynamic>
          ? data["message"]?.toString()
          : null;

      AppSnackBar.error(message ?? "network_error_try_again".tr);
    } catch (e, st) {
      AppLoader.hide();
      debugPrint("❌ LOAD CLIENT PROFILE ERROR: $e");
      debugPrint("$st");

      AppSnackBar.error("network_error_try_again".tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;
    final tt = Theme.of(context).textTheme;
    final isArabic = Get.locale?.languageCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screenW = MediaQuery.of(context).size.width;
    final circleSize = (screenW * 0.42).clamp(140.0, 200.0);

    return WillPopScope(
      onWillPop: () async => false,
      child: KeyboardDismissOnTap(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Container(
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
                              color: primary.withOpacity(isDark ? 0.02 : 0.03),
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
                                color: Colors.green.withOpacity(
                                  isDark ? 0.18 : 0.12,
                                ),
                              ),
                              child: const Icon(
                                Iconsax.tick_circle_copy,
                                color: Colors.green,
                                size: 28,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Title
                            AppText(
                              "account_created_successfully".tr,
                              textAlign: TextAlign.center,
                              fontSize: tt.titleLarge?.fontSize ?? 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : Colors.black,
                            ),

                            const SizedBox(height: 16),

                            // Subtitle
                            AppText(
                              "email_verified".tr,
                              textAlign: TextAlign.center,
                              fontSize: tt.bodySmall?.fontSize ?? 13,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey,
                            ),

                            const SizedBox(height: 8),

                            AppText(
                              widget.email,
                              textAlign: TextAlign.center,
                              fontSize: tt.bodyMedium?.fontSize ?? 14,
                              fontWeight: FontWeight.w600,
                              color: primary,
                            ),

                            const SizedBox(height: 16),

                            AppText(
                              "welcome_vclub".tr,
                              textAlign: TextAlign.center,
                              fontSize: tt.bodySmall?.fontSize ?? 13,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? Colors.grey.shade400
                                  : Colors.grey,
                            ),

                            const SizedBox(height: 32),

                            NextButton(
                              text: "go_to_my_space",
                              isEnabled: true,
                              width: double.infinity,
                              onTap: () async {
                                await loadClientProfileAndOpenAccount() ;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
