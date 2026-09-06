// lib/Features/Client/MyProfile/View/Widgets/DeleteAccountSheet.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

void showDeleteAccountSheet({
  required Future<void> Function() onConfirm,
}) {
  Get.bottomSheet(
    _DeleteAccountSheetContent(onConfirm: onConfirm),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
  );
}

class _DeleteAccountSheetContent extends StatefulWidget {
  final Future<void> Function() onConfirm;
  const _DeleteAccountSheetContent({required this.onConfirm});

  @override
  State<_DeleteAccountSheetContent> createState() => _DeleteAccountSheetContentState();
}

class _DeleteAccountSheetContentState extends State<_DeleteAccountSheetContent> {
  bool _loading = false;
  bool _understood = false;

  Future<void> _handleConfirm() async {
    if (_loading || !_understood) return;
    setState(() => _loading = true);
    try {
      await widget.onConfirm();
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
                  child: const Icon(
                    Iconsax.trash,
                    color: Colors.red,
                    size: 28,
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                /// TITLE
                AppText(
                  "delete_account_title".tr,
                  fontSize: size.width * 0.05,
                  fontWeight: FontWeight.w800,
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: size.height * 0.01),

                /// DESCRIPTION
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: size.width * 0.03),
                  child: AppText(
                    "delete_account_desc".tr,
                    fontSize: size.width * 0.035,
                    textAlign: TextAlign.center,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),

                SizedBox(height: size.height * 0.02),

                /// WHAT WILL BE LOST — list
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LossRow(text: "delete_account_loss_1".tr),
                      const SizedBox(height: 8),
                      _LossRow(text: "delete_account_loss_2".tr),
                      const SizedBox(height: 8),
                      _LossRow(text: "delete_account_loss_3".tr),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.022),

                /// CONFIRMATION CHECKBOX
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: _loading ? null : () => setState(() => _understood = !_understood),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            width: 22,
                            height: 22,
                            margin: const EdgeInsets.only(top: 1),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: _understood ? Colors.red : Colors.transparent,
                              border: Border.all(
                                color: _understood ? Colors.red : Colors.grey.withOpacity(0.5),
                                width: 1.6,
                              ),
                            ),
                            child: _understood
                                ? const Icon(Icons.check, size: 15, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppText(
                              "delete_account_confirm_checkbox".tr,
                              fontSize: size.width * 0.033,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: size.height * 0.026),

                /// BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _loading ? null : () => Navigator.of(context).pop(),
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

                    Expanded(
                      child: GestureDetector(
                        onTap: _understood ? _handleConfirm : null,
                        child: Opacity(
                          opacity: _understood ? 1 : 0.4,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: size.height * 0.02),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: const LinearGradient(
                                colors: [Colors.red, Colors.redAccent],
                              ),
                              boxShadow: _understood
                                  ? [
                                      BoxShadow(
                                        color: Colors.red.withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ]
                                  : [],
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
                                      "delete_permanently".tr,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: size.width * 0.033,
                                      textAlign: TextAlign.center,
                                    ),
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

class _LossRow extends StatelessWidget {
  final String text;
  const _LossRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Iconsax.close_circle, size: 15, color: Colors.redAccent),
        const SizedBox(width: 8),
        Expanded(
          child: AppText(
            text,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: Colors.redAccent.shade200,
          ),
        ),
      ],
    );
  }
}