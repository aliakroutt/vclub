import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';

class BillingPortalWebViewScreen extends StatefulWidget {
  final String portalUrl;

  const BillingPortalWebViewScreen({super.key, required this.portalUrl});

  @override
  State<BillingPortalWebViewScreen> createState() => _BillingPortalWebViewScreenState();
}

class _BillingPortalWebViewScreenState extends State<BillingPortalWebViewScreen> {
  late final WebViewController _webController;
  double _progress = 0;
  bool _isLoading = true;

  Future<void> _handleBack() async {
    Get.back();
    // Re-sync merchant profile + stats/invoices since the portal may have
    // changed payment method, canceled, updated plan, downloaded invoices, etc.
    await Get.find<SmsAddonController>().refreshProfile();
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
            if (mounted) setState(() => _progress = progress / 100);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.portalUrl));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleBack();
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
                      onTap: _handleBack,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.lock_1_copy, size: 14, color: AppColors.primary),
                              const SizedBox(width: 6),
                              AppText(
                                "manage_subscription".tr,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          AppText("powered_by_stripe".tr, fontSize: 11, fontWeight: FontWeight.w400, color: Colors.grey),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
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
                                "connecting_to_portal".tr,
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