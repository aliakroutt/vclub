import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

void showLogoutBottomSheet({
  required Future<void> Function() onConfirm,
}) {
  Get.bottomSheet(
    _LogoutBottomSheetContent(onConfirm: onConfirm),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
  );
}

class _LogoutBottomSheetContent extends StatefulWidget {
  final Future<void> Function() onConfirm;
  const _LogoutBottomSheetContent({required this.onConfirm});

  @override
  State<_LogoutBottomSheetContent> createState() => _LogoutBottomSheetContentState();
}

class _LogoutBottomSheetContentState extends State<_LogoutBottomSheetContent> {
  bool _loading = false;

  Future<void> _handleConfirm() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await widget.onConfirm();
      // If onConfirm navigates away (e.g. to Login), this widget will be
      // disposed — guard with mounted before any further setState.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';
    final size = MediaQuery.of(context).size;

    return PopScope(
      canPop: !_loading,
      child: Directionality(
        textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
        child: SafeArea(
          child: Container(
            padding: EdgeInsets.all(size.width * 0.05),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF121212) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                /// TOP INDICATOR
                Container(
                  width: 45,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                /// ICON
                Container(
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.12),
                  ),
                  child: const Icon(Iconsax.logout, color: Colors.red, size: 28),
                ),

                SizedBox(height: size.height * 0.02),

                /// TITLE
                AppText(
                  "logout_title".tr,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.01),

                /// DESCRIPTION
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                  child: AppText(
                    "logout_desc".tr,
                    fontSize: size.width * 0.035,
                    textAlign: TextAlign.center,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: size.height * 0.03),

                /// BUTTONS
                Row(
                  children: [
                    /// CANCEL
                    Expanded(
                      child: GestureDetector(
                        onTap: _loading ? null : () => Get.back(),
                        child: Opacity(
                          opacity: _loading ? 0.4 : 1,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                            ),
                            child: Center(
                              child: AppText("cancel".tr, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: size.width * 0.03),

                    /// CONFIRM
                    Expanded(
                      child: GestureDetector(
                        onTap: _handleConfirm,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Colors.red, Colors.redAccent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      valueColor: AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : AppText(
                                    "logout".tr,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}