import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Client/Rewards/Controllers/RewardsClientController.dart';
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';
import 'package:vclub/Features/Client/Rewards/Services/RewardsClientService.dart';

enum _ReviewStage { idle, starting, counting, claiming }

class GoogleReviewCard extends StatefulWidget {
  final CompanyReviewEntry entry;

  const GoogleReviewCard({super.key, required this.entry});

  @override
  State<GoogleReviewCard> createState() => _GoogleReviewCardState();
}

class _GoogleReviewCardState extends State<GoogleReviewCard> {
  _ReviewStage _stage = _ReviewStage.idle;
  Timer? _timer;
  int _secondsLeft = 0;
  String? _token;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ImageProvider? _decodeLogo(String? logo) {
    if (logo == null || logo.isEmpty) return null;
    try {
      final b64 = logo.contains(',') ? logo.split(',').last : logo;
      return MemoryImage(base64Decode(b64));
    } catch (_) {
      return null;
    }
  }

  // ── review flow: start -> countdown -> claim -> dialog ──

  Future<void> _startReview(GoogleReviewModel review) async {
    if (_stage != _ReviewStage.idle) return;

    final url = review.googleReviewLink;
    if (url.isEmpty) return;

    setState(() => _stage = _ReviewStage.starting);

    try {
      final companyId = widget.entry.company.companyId;
      final start = await GoogleReviewApiClient.startReview(companyId);
      _token = start.reviewToken;

      // Open the Google review page at the same time the timer starts.
      _openReviewLink(url);

      if (!mounted) return;
      setState(() {
        _secondsLeft = start.minDwellSeconds;
        _stage = _ReviewStage.counting;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsLeft <= 1) {
          timer.cancel();
          _claimReview();
        } else {
          setState(() => _secondsLeft -= 1);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _stage = _ReviewStage.idle);
      AppSnackBar.error("review_start_failed_client".tr);
    }
  }

  Future<void> _claimReview() async {
    if (!mounted) return;
    setState(() => _stage = _ReviewStage.claiming);

    final companyId = widget.entry.company.companyId;
    final rewardName = widget.entry.review?.reward?.name;

    try {
      final result = await GoogleReviewApiClient.claimReview(companyId, _token!);

      if (!mounted) return;
      await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.5),
        builder: (_) => _ReviewResultDialog(
          success: result.claimed,
          title: result.claimed
              ? "review_claim_success_title_client".tr
              : (result.alreadyClaimed
                  ? "review_already_claimed_title_client".tr
                  : "review_claim_failed_title_client".tr),
          message: result.claimed
              ? "${"review_claim_success_message_client".tr} ${rewardName ?? ""}".trim()
              : (result.alreadyClaimed
                  ? "review_already_claimed_message_client".tr
                  : "review_claim_failed_message_client".tr),
        ),
      );
    } catch (_) {
      AppSnackBar.error("review_claim_failed_client".tr);
    } finally {
      if (mounted) setState(() => _stage = _ReviewStage.idle);
      _token = null;
      // Refresh so eligibility/claimed state reflects the server.
      Get.find<GoogleReviewController>().refresh();
    }
  }

  void _openReviewLink(String url) {
    if (url.isEmpty) return;

    final normalized = _normalizeUrl(url);
    if (normalized == null) {
      AppSnackBar.error("invalid_link_client".tr);
      return;
    }

    launchUrlString(normalized, mode: LaunchMode.externalApplication);
  }

  String? _normalizeUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.isEmpty) return null;

    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      trimmed = 'https://$trimmed';
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || uri.host.isEmpty) return null;

    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final review = widget.entry.review;
    final logo = _decodeLogo(widget.entry.company.companyLogo);

    if (review == null) return const SizedBox.shrink();

    final (statusColor, statusLabel, statusIcon) = _statusMeta(review);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? .22 : .04), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── header: company logo + name + status pill ──
          Row(
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: logo == null
                      ? LinearGradient(colors: [AppColors.primary.withOpacity(.2), AppColors.primary.withOpacity(.06)])
                      : null,
                  image: logo != null ? DecorationImage(image: logo, fit: BoxFit.cover) : null,
                  border: Border.all(color: AppColors.primary.withOpacity(.22), width: 1.2),
                ),
                child: logo == null
                    ? Center(
                        child: AppText(
                          widget.entry.company.companyName.isNotEmpty
                              ? widget.entry.company.companyName[0].toUpperCase()
                              : "?",
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AppText(
                  widget.entry.company.companyName.isNotEmpty ? widget.entry.company.companyName : "—",
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(.12),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: statusColor.withOpacity(.28)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 11, color: statusColor),
                    const SizedBox(width: 4),
                    AppText(statusLabel, fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          const SizedBox(height: 14),

          // ── reward info ──
          Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFB930), Color(0xFFFFCB61)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: const Color(0xFFFFB930).withOpacity(.3), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: const Icon(Iconsax.star_1, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      review.reward?.name.isNotEmpty == true ? review.reward!.name : "google_review_reward_label".tr,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    AppText(
                      "${review.rewardPoints} ${"points_label".tr}",
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB08000),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── next eligible date, if locked/claimed with a cooldown ──
          if (review.nextEligibleAt != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(.04) : Colors.black.withOpacity(.025),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Iconsax.calendar_1, size: 13, color: Colors.grey.withOpacity(.7)),
                  const SizedBox(width: 7),
                  AppText(
                    "${"next_eligible_label".tr} ${DateFormat('d MMM yyyy').format(review.nextEligibleAt!)}",
                    fontSize: 11,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ── action button ──
          _buildActionButton(review),
        ],
      ),
    );
  }

  Widget _buildActionButton(GoogleReviewModel review) {
    final canStart = review.eligible && !review.alreadyClaimed && _stage == _ReviewStage.idle;
    final busy = _stage != _ReviewStage.idle;

    Widget content;
    switch (_stage) {
      case _ReviewStage.starting:
        content = _buttonRow(
          child: const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          label: "starting_review_client".tr,
          textColor: Colors.white,
        );
        break;
      case _ReviewStage.counting:
        content = _buttonRow(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: null,
              color: Colors.white,
              backgroundColor: Colors.white.withOpacity(.3),
            ),
          ),
          label: "${"wait_seconds_client".tr} ${_secondsLeft}s",
          textColor: Colors.white,
        );
        break;
      case _ReviewStage.claiming:
        content = _buttonRow(
          child: const SizedBox(
            width: 15,
            height: 15,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          ),
          label: "claiming_reward_client".tr,
          textColor: Colors.white,
        );
        break;
      case _ReviewStage.idle:
        content = _buttonRow(
          child: Icon(
            review.alreadyClaimed ? Iconsax.tick_circle : Iconsax.star_1,
            size: 15,
            color: review.eligible && !review.alreadyClaimed ? Colors.white : Colors.grey.shade700,
          ),
          label: review.alreadyClaimed
              ? "review_already_claimed".tr
              : (review.eligible ? "leave_review_action".tr : "review_locked".tr),
          textColor: review.eligible && !review.alreadyClaimed ? Colors.white : Colors.grey.shade700,
        );
        break;
    }

    final activeColor = busy ? AppColors.primary.withOpacity(.85) : AppColors.primary;

    return SizedBox(
      width: double.infinity,
      height: 42,
      child: Material(
        color: (review.eligible && !review.alreadyClaimed) || busy
            ? activeColor
            : Colors.grey.withOpacity(.25),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canStart ? () => _startReview(review) : null,
          child: Center(child: content),
        ),
      ),
    );
  }

  Widget _buttonRow({required Widget child, required String label, required Color textColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        child,
        const SizedBox(width: 8),
        AppText(label, color: textColor, fontWeight: FontWeight.w700, fontSize: 12.5),
      ],
    );
  }

  (Color, String, IconData) _statusMeta(GoogleReviewModel review) {
    if (review.alreadyClaimed) {
      return (const Color(0xFF00C896), "status_claimed".tr, Iconsax.tick_circle);
    }
    if (review.eligible) {
      return (AppColors.primary, "status_available".tr, Iconsax.star_1);
    }
    return (Colors.grey, "status_locked".tr, Iconsax.lock_1);
  }
}

class _ReviewResultDialog extends StatelessWidget {
  final bool success;
  final String title;
  final String message;

  const _ReviewResultDialog({
    required this.success,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dialogWidth = size.width < 480 ? size.width * 0.82 : 360.0;
    final color = success ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(26),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 30, offset: const Offset(0, 12)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [color, Color.lerp(color, Colors.black, 0.15)!]),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.35), blurRadius: 20, spreadRadius: -2)],
                ),
                child: Icon(
                  success ? Iconsax.tick_circle_copy : Iconsax.info_circle_copy,
                  color: Colors.white,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              AppText(title, fontSize: 17, fontWeight: FontWeight.w800, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              AppText(
                message,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                textAlign: TextAlign.center,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: Material(
                  color: color,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.of(context).pop(),
                    child: Center(
                      child: AppText("ok_client".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}