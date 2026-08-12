import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vclub/API/MerchantApiClient.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';

/// Stripe redirects here after billing/change-plan checkout completes.
/// Success example: .../my-billing?checkout=success&session_id=cs_test_...
/// Cancel example (assumed — confirm with backend): .../my-billing?checkout=cancel
const String kBillingCheckoutStatusParam = "checkout";
const String kBillingCheckoutSuccessValue = "success";
const String kBillingCheckoutCancelValue = "cancel";

class BillingCheckoutWebViewScreen extends StatefulWidget {
  final String checkoutUrl;

  const BillingCheckoutWebViewScreen({super.key, required this.checkoutUrl});

  @override
  State<BillingCheckoutWebViewScreen> createState() => _BillingCheckoutWebViewScreenState();
}

class _BillingCheckoutWebViewScreenState extends State<BillingCheckoutWebViewScreen> {
  late final WebViewController _webController;
  double _progress = 0;
  bool _isLoading = true;
  bool _isConfirmingPayment = false;

  // ─────────────────────────────────────────────────────────
  // FLOW HANDLERS
  // ─────────────────────────────────────────────────────────

  void _handlePaymentCancelled() {
    Get.back(); // back to Billing
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
      final response = await MerchantApiClient.confirmPayment(sessionId: sessionId);
      final data = response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Payment confirmed server-side -> pull fresh plan/entitlements.
        await Get.find<SmsAddonController>().refreshProfile();

        if (!mounted) return;
        setState(() => _isConfirmingPayment = false);
        Get.back(); // back to Billing screen first
        _showResultDialog(success: true);
      } else {
        final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
        if (!mounted) return;
        setState(() => _isConfirmingPayment = false);
        Get.back();
        _showResultDialog(success: false, message: message);
      }
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      if (!mounted) return;
      setState(() => _isConfirmingPayment = false);
      Get.back();
      _showResultDialog(success: false, message: message);
    } catch (e, st) {
      debugPrint("❌ CONFIRM PLAN PAYMENT ERROR: $e");
      debugPrint("$st");
      if (!mounted) return;
      setState(() => _isConfirmingPayment = false);
      Get.back();
      _showResultDialog(success: false);
    }
  }

  // ─────────────────────────────────────────────────────────
  // DIALOGS
  // ─────────────────────────────────────────────────────────

  void _showResultDialog({required bool success, String? message}) {
    showGeneralDialog(
      context: Get.context!,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) => const SizedBox.shrink(),
      transitionBuilder: (ctx, anim, secondaryAnim, child) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutBack);
        final color = success ? Colors.green : Colors.redAccent;

        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
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
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
                          child: Icon(
                            success ? Iconsax.tick_circle : Iconsax.close_circle,
                            color: color,
                            size: 32,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppText(
                          success ? "plan_updated_title".tr : "payment_confirm_failed_title".tr,
                          textAlign: TextAlign.center,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          success
                              ? "plan_updated_message".tr
                              : (message ?? "payment_confirm_failed_message".tr),
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          height: 1.4,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () => Get.back(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: color,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: AppText(
                              success ? "done".tr : "close".tr,
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
          filter: ImageFilter.blur(sigmaX: 6 * anim.value, sigmaY: 6 * anim.value),
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
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.12), shape: BoxShape.circle),
                          child: const Icon(Iconsax.warning_2, color: Colors.redAccent, size: 26),
                        ),
                        const SizedBox(height: 18),
                        AppText(
                          "cancel_payment_title".tr,
                          textAlign: TextAlign.center,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                        ),
                        const SizedBox(height: 8),
                        AppText(
                          "cancel_payment_message".tr,
                          textAlign: TextAlign.center,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: isDark ? Colors.white60 : Colors.grey.shade600,
                          height: 1.4,
                        ),
                        const SizedBox(height: 24),
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: AppText("leave".tr, fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: TextButton(
                            onPressed: () => Get.back(),
                            style: TextButton.styleFrom(
                              backgroundColor: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF4F5F7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: AppText(
                              "stay".tr,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : const Color(0xFF2D3142),
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

  // ─────────────────────────────────────────────────────────
  // LIFECYCLE
  // ─────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress / 100);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onNavigationRequest: (request) async {
            final uri = Uri.tryParse(request.url);
            final checkoutStatus = uri?.queryParameters[kBillingCheckoutStatusParam];

            if (checkoutStatus == kBillingCheckoutSuccessValue) {
              final sessionId = uri?.queryParameters['session_id'];

              if (sessionId != null && sessionId.isNotEmpty) {
                await _confirmPayment(sessionId);
              } else {
                Get.back();
                _showResultDialog(success: false);
              }

              return NavigationDecision.prevent;
            }

            if (checkoutStatus == kBillingCheckoutCancelValue) {
              _handlePaymentCancelled();
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  // ─────────────────────────────────────────────────────────
  // UI
  // ─────────────────────────────────────────────────────────

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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF151515) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _circleButton(
                      context,
                      icon: Get.locale?.languageCode == 'ar' ? Iconsax.arrow_right_3_copy : Iconsax.arrow_left_2_copy,
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
                              Icon(Iconsax.lock_1_copy, size: 14, color: AppColors.primary),
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
                              margin: const EdgeInsets.symmetric(horizontal: 40),
                              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
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
                                  SizedBox(
                                    width: 46,
                                    height: 46,
                                    child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3.5),
                                  ),
                                  const SizedBox(height: 20),
                                  AppText(
                                    "confirming_payment".tr,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                                  ),
                                  const SizedBox(height: 6),
                                  AppText(
                                    "please_wait".tr,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    color: isDark ? Colors.white60 : Colors.grey.shade600,
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
                              CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2.5),
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
            color: isDark ? Colors.black.withOpacity(.3) : Colors.black.withOpacity(.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 18),
    ),
  );
}