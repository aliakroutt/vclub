import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Controllers/MerchantGoogleReviewController.dart';

Future<void> showShareLinkSheet(BuildContext context) {
  final controller = Get.find<MerchantGoogleReviewController>();
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true, // required so the sheet can grow above the keyboard
    builder: (sheetContext) {
      return AnimatedPadding(
        duration: const Duration(milliseconds: 100),
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 0),
            child: Container(
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1F26) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      height: 4,
                      width: 40,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [const Color(0xFF00B894), const Color(0xFF00B894).withOpacity(.7)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Iconsax.share, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText("share_review_link_title".tr, fontSize: 16, fontWeight: FontWeight.w800),
                            const SizedBox(height: 3),
                            AppText(
                              "share_review_link_subtitle".tr,
                              fontSize: 12,
                              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Obx(() {
                    final linkController = TextEditingController(text: controller.reviewLink.value)
                      ..selection = TextSelection.collapsed(offset: controller.reviewLink.value.length);

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primary.withOpacity(.2)),
                      ),
                      child: TextField(
                        controller: linkController,
                        onChanged: controller.setReviewLink,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          isDense: true,
                          border: InputBorder.none,
                          hintText: "review_link_placeholder".tr,
                          hintStyle: TextStyle(fontSize: 13, color: Colors.grey.withOpacity(.6)),
                          prefixIcon: Icon(Iconsax.link_21, size: 16, color: AppColors.primary),
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _ShareActionButton(
                          icon: Iconsax.copy,
                          label: "copy".tr,
                          color: AppColors.primary,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: controller.reviewLink.value));
                            AppSnackBar.success("link_copied".tr);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ShareActionButton(
                          icon: Iconsax.share,
                          label: "share".tr,
                          color: const Color(0xFF00B894),
                          onTap: () {
                            final link = controller.reviewLink.value;
                            if (link.isEmpty) {
                              AppSnackBar.error("review_link_empty".tr);
                              return;
                            }
                            Share.share(link);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFC542).withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFC542).withOpacity(.25)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Iconsax.info_circle, size: 15, color: Color(0xFFB08000)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: AppText(
                            "important_google_review_note".tr,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF7A5500),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Obx(() {
                      final saving = controller.isSavingLink.value;

                      return Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: saving
                              ? null
                              : () async {
                                  final canClose = await controller.saveReviewLinkIfChanged();
                                  if (canClose && sheetContext.mounted) Navigator.pop(sheetContext);
                                },
                          child: Center(
                            child: saving
                                ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 24)
                                : AppText("done".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ShareActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(.1),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        borderRadius: BorderRadius.circular(13),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: color.withOpacity(.22)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 7),
              AppText(
                label,
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
