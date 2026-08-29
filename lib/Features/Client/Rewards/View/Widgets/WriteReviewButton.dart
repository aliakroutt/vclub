import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/WriteReviewController.dart';
import 'WriteReviewResultDialog.dart';

class WriteReviewButton extends StatefulWidget {
  final String companyId;
  final String reviewLink;
  final bool enabled;

  const WriteReviewButton({
    super.key,
    required this.companyId,
    required this.reviewLink,
    required this.enabled,
  });

  @override
  State<WriteReviewButton> createState() => _WriteReviewButtonState();
}

class _WriteReviewButtonState extends State<WriteReviewButton> {
  late final WriteReviewController _controller;

  @override
  void initState() {
    super.initState();
    // Unique tag per company so multiple cards' timers never collide.
    _controller = Get.put(WriteReviewController(), tag: 'write_review_${widget.companyId}');
  }

  @override
  void dispose() {
    Get.delete<WriteReviewController>(tag: 'write_review_${widget.companyId}', force: true);
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.writeReview(
      companyId: widget.companyId,
      reviewLink: widget.reviewLink,
      onResult: (result, errorMessage) async {
        if (!mounted) return;

        if (result != null) {
          final success = result.claimed;
          final message = result.alreadyClaimed && !result.claimed
              ? "review_already_claimed_message".tr
              : null;

          await showWriteReviewResultDialog(context, success: success, message: message);
        } else {
          await showWriteReviewResultDialog(context, success: false, message: errorMessage);
        }

        // Refresh the whole review list (all companies) after any outcome.
        if (Get.isRegistered<GoogleReviewController>()) {
          Get.find<GoogleReviewController>().refresh();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stage = _controller.stage.value;
      final seconds = _controller.secondsLeft.value;

      final isLoadingEdge = stage == WriteReviewStage.starting || stage == WriteReviewStage.claiming;
      final isWaiting = stage == WriteReviewStage.waiting;

      return SizedBox(
        width: double.infinity,
        height: 42,
        child: Material(
          color: widget.enabled ? AppColors.primary : Colors.grey.withOpacity(.25),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.enabled && stage == WriteReviewStage.idle ? _handleTap : null,
            child: Center(
              child: isLoadingEdge
                  ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 20)
                  : isWaiting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                                value: null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            AppText(
                              "review_wait_seconds".trParams({"seconds": "$seconds"}),
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Iconsax.star_1,
                              size: 15,
                              color: widget.enabled ? Colors.white : Colors.grey.shade700,
                            ),
                            const SizedBox(width: 7),
                            AppText(
                              "leave_review_action".tr,
                              color: widget.enabled ? Colors.white : Colors.grey.shade700,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                            ),
                          ],
                        ),
            ),
          ),
        ),
      );
    });
  }
}