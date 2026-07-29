import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/API/MerchantApiClient.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';

class CheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const CheckoutWebViewScreen({super.key, required this.checkoutUrl});

  @override
  State<CheckoutWebViewScreen> createState() => _CheckoutWebViewScreenState();
}

class _CheckoutWebViewScreenState extends State<CheckoutWebViewScreen> {
  late final WebViewController _webController;
  double _progress = 0;
  bool _isLoading = true;
  bool _isConfirmingPayment = false;

  void _handlePaymentCancelled() {
    Get.back(); // back to signup flow
    Get.snackbar(
      "payment_cancelled_title".tr,
      "payment_cancelled_message".tr,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  Future<void> _confirmPayment(String sessionId) async {
    setState(() => _isConfirmingPayment = true);

    try {
      final response = await MerchantApiClient.confirmPayment(
        sessionId: sessionId,
      );
      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() => _isConfirmingPayment = false);
        Get.back(); // close the webview
        _showPaymentSuccessDialog();
      } else {
        setState(() => _isConfirmingPayment = false);
        final message = (data is Map<String, dynamic>)
            ? data["message"]?.toString()
            : null;
        _showConfirmFailedSnackbar(message);
      }
    } on DioException catch (e) {
      setState(() => _isConfirmingPayment = false);
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>)
          ? data["message"]?.toString()
          : null;
      _showConfirmFailedSnackbar(message);
    } catch (e, st) {
      setState(() => _isConfirmingPayment = false);
      debugPrint("❌ CONFIRM PAYMENT ERROR: $e");
      debugPrint("$st");
      _showConfirmFailedSnackbar(null);
    }
  }

  void _showPaymentSuccessDialog() {
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6 * anim.value,
            sigmaY: 6 * anim.value,
          ),
          child: FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// ===== SUCCESS ICON =====
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.tick_circle,
                            color: Colors.green,
                            size: 32,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// ===== TITLE =====
                        AppText(
                          "payment_confirmed_title".tr,
                          textAlign: TextAlign.center,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),

                        const SizedBox(height: 8),

                        /// ===== MESSAGE =====
                        AppText(
                          "account_verified_message".tr,
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          height: 1.4,
                        ),

                        const SizedBox(height: 24),

                        /// ===== GO TO LOGIN =====
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back(); // close dialog
                              Get.offAll(() => Login());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AppText(
                              "go_to_login".tr,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showConfirmFailedSnackbar([String? message]) {
    Get.snackbar(
      "payment_confirm_failed_title".tr,
      message ?? "payment_confirm_failed_message".tr,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
    );
  }

  @override
  void initState() {
    super.initState();

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            setState(() => _progress = progress / 100);
          },
          onPageStarted: (_) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) async {
            final url = request.url;

            if (url.startsWith("https://staging.vclub.fr/signup/success")) {
              final sessionId = Uri.parse(url).queryParameters['session_id'];

              if (sessionId != null && sessionId.isNotEmpty) {
                await _confirmPayment(sessionId);
              } else {
                _showConfirmFailedSnackbar();
              }

              return NavigationDecision.prevent;
            }

            if (url.contains("payment-cancel")) {
              _handlePaymentCancelled();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

 

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0E0E0E) : Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              /// ===== CUSTOM APP BAR =====
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151515) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _circleButton(
                      context,
                      icon: Get.locale?.languageCode == 'ar'
                          ? Iconsax.arrow_right_3_copy
                          : Iconsax.arrow_left_2_copy,
                      onTap: () => _confirmExit(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Iconsax.lock_1_copy,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              AppText(
                                "secure_checkout".tr,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          AppText(
                            "powered_by_stripe".tr,
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40), // balances back button
                  ],
                ),
              ),

              /// ===== PROGRESS BAR =====
              if (_isLoading)
                LinearProgressIndicator(
                  value: _progress == 0 ? null : _progress,
                  minHeight: 2.5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),

              /// ===== WEBVIEW =====
              Expanded(
                child: Stack(
                  children: [
                    WebViewWidget(controller: _webController),
                    if (_isConfirmingPayment)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.55),
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 40,
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 32,
                                horizontal: 24,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1C1C1E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(
                                      isDark ? 0.5 : 0.15,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 12),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 46,
                                    height: 46,
                                    child: CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3.5,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  AppText(
                                    "confirming_payment".tr,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1A1A1A),
                                  ),
                                  const SizedBox(height: 6),
                                  AppText(
                                    "please_wait".tr,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: isDark
                                        ? Colors.white60
                                        : Colors.grey.shade600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                    if (_isLoading && _progress < 0.3)
                      Container(
                        color: isDark ? const Color(0xFF0E0E0E) : Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 2.5,
                              ),
                              const SizedBox(height: 16),
                              AppText(
                                "connecting_to_payment".tr,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmExit(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "dismiss",
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);

        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6 * anim.value,
            sigmaY: 6 * anim.value,
          ),
          child: FadeTransition(
            opacity: anim,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1).animate(curved),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.5 : 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// ===== ICON BADGE =====
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.warning_2,
                            color: Colors.redAccent,
                            size: 26,
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// ===== TITLE =====
                        AppText(
                          "cancel_payment_title".tr,
                          textAlign: TextAlign.center,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1A1A1A),
                        ),

                        const SizedBox(height: 8),

                        /// ===== MESSAGE =====
                        AppText(
                          "cancel_payment_message".tr,
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          height: 1.4,
                        ),

                        const SizedBox(height: 24),

                        /// ===== LEAVE (primary destructive) =====
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              Get.back(); // close dialog
                              Get.back(); // close webview
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AppText(
                              "leave".tr,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// ===== STAY (secondary) =====
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              backgroundColor: isDark
                                  ? Colors.white.withOpacity(0.06)
                                  : const Color(0xFFF4F5F7),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AppText(
                              "stay".tr,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF2D3142),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
