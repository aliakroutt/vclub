import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';

// Adjust this import to wherever GoogleReviewModel actually lives.
import 'package:vclub/Features/Client/Rewards/Models/ClientReviewRewardModel.dart';

enum _ReviewState { locked, claimed, eligible, cooldown, notEligible }

/// A premium, single-glance card that surfaces every field on
/// [GoogleReviewModel]: reward name/type, points, trigger, unlocked
/// state, next-eligible date and the review link itself.
class GoogleReviewRewardCard extends StatefulWidget {
  final GoogleReviewModel review;
  final VoidCallback? onWriteReview;

  const GoogleReviewRewardCard({
    super.key,
    required this.review,
    this.onWriteReview,
  });

  @override
  State<GoogleReviewRewardCard> createState() =>
      _GoogleReviewRewardCardState();
}

class _GoogleReviewRewardCardState extends State<GoogleReviewRewardCard> {
  bool _copied = false;

  GoogleReviewModel get review => widget.review;

  _ReviewState get _state {
    if (!review.unlocked) return _ReviewState.locked;
    if (review.alreadyClaimed) return _ReviewState.claimed;
    if (review.eligible) return _ReviewState.eligible;
    if (review.nextEligibleAt != null) return _ReviewState.cooldown;
    return _ReviewState.notEligible;
  }

  Color _accent(_ReviewState s) {
    switch (s) {
      case _ReviewState.eligible:
        return const Color(0xFFFBBF24);
      case _ReviewState.claimed:
        return const Color(0xFF16A34A);
      case _ReviewState.cooldown:
        return const Color(0xFFF59E0B);
      case _ReviewState.locked:
      case _ReviewState.notEligible:
        return Colors.grey;
    }
  }

  IconData _icon(_ReviewState s) {
    switch (s) {
      case _ReviewState.eligible:
        return Iconsax.star_1;
      case _ReviewState.claimed:
        return Iconsax.tick_circle_copy;
      case _ReviewState.cooldown:
        return Iconsax.clock;
      case _ReviewState.locked:
        return Iconsax.lock_1;
      case _ReviewState.notEligible:
        return Iconsax.info_circle;
    }
  }

  String _statusLabel(_ReviewState s) {
    switch (s) {
      case _ReviewState.eligible:
        return "eligible".tr;
      case _ReviewState.claimed:
        return "claimed".tr;
      case _ReviewState.cooldown:
        return "in_cooldown".tr;
      case _ReviewState.locked:
        return "locked".tr;
      case _ReviewState.notEligible:
        return "not_eligible".tr;
    }
  }

  String _subtitle(_ReviewState s, String localeCode) {
    switch (s) {
      case _ReviewState.locked:
        return "review_locked_subtitle".tr;
      case _ReviewState.claimed:
        return "review_claimed_subtitle".tr;
      case _ReviewState.eligible:
        return "review_eligible_subtitle"
            .trParams({"points": "${review.rewardPoints}"});
      case _ReviewState.cooldown:
        final date = review.nextEligibleAt != null
            ? DateFormat('dd MMM yyyy', localeCode)
                .format(review.nextEligibleAt!.toLocal())
            : '';
        return "review_cooldown_subtitle".trParams({"date": date});
      case _ReviewState.notEligible:
        return "review_not_eligible_subtitle".tr;
    }
  }

  /// Tries "trigger_<value>".tr first (e.g. add `"trigger_reward_redeem":
  /// "On reward redeem"` to your locale files); falls back to a humanized
  /// version of the raw value so nothing ever looks like a raw enum.
  String _humanizeTrigger(String trigger) {
    if (trigger.isEmpty) return "-";
    final key = "trigger_$trigger";
    final translated = key.tr;
    if (translated != key) return translated;
    return trigger
        .split('_')
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  Future<void> _copyLink() async {
    if (review.googleReviewLink.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: review.googleReviewLink));
    if (!mounted) return;
    setState(() => _copied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Get.find<ThemeService>().isDarkMode.value;
    final localeCode = Get.locale?.languageCode ?? 'en';
    final state = _state;
    final accent = _accent(state);
    final disabled = state == _ReviewState.locked;
    final title = review.reward?.name.isNotEmpty == true
        ? review.reward!.name
        : "review_reward_default_title".tr;

    final borderColor =
        isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.10);
    final dividerColor =
        isDark ? Colors.white.withOpacity(0.06) : Colors.grey.withOpacity(0.08);
    final mutedText = Colors.grey.shade500;

    return Opacity(
      opacity: disabled ? 0.7 : 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Theme.of(context).cardColor,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    size.width * 0.032,
                    size.height * 0.016,
                    size.width * 0.032,
                    size.height * 0.014,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * 0.12,
                        height: size.width * 0.12,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          color: accent.withOpacity(isDark ? 0.20 : 0.12),
                        ),
                        child: Icon(_icon(state),
                            color: accent, size: size.width * 0.052),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AppText(
                              title,
                              fontSize: size.width * 0.038,
                              fontWeight: FontWeight.w700,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: size.height * 0.008),
                            AppText(
                              _subtitle(state, localeCode),
                              fontSize: size.width * 0.028,
                              fontWeight: FontWeight.w500,
                              color: mutedText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: size.width * 0.02),
                      _StatusDot(
                        color: accent,
                        label: _statusLabel(state),
                        size: size,
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, thickness: 1, color: dividerColor),

                // ── Details ─────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.032,
                    vertical: size.height * 0.014,
                  ),
                  child: Column(
                    children: [
                      _MetaRow(
                        icon: Iconsax.coin_1,
                        label: "reward_points".tr,
                        value: "+${review.rewardPoints}",
                        valueColor: accent,
                        size: size,
                      ),
                      if (review.reward != null) ...[
                        SizedBox(height: size.height * 0.011),
                        _MetaRow(
                          icon: Iconsax.gift,
                          label: "reward_type".tr,
                          value: review.reward!.type.isNotEmpty
                              ? _capitalize(review.reward!.type)
                              : "-",
                          size: size,
                        ),
                      ],
                      SizedBox(height: size.height * 0.011),
                      _MetaRow(
                        icon: Iconsax.flash_1,
                        label: "reward_trigger".tr,
                        value: _humanizeTrigger(review.trigger),
                        size: size,
                      ),
                      SizedBox(height: size.height * 0.011),
                      _MetaRow(
                        icon: review.unlocked ? Iconsax.unlock : Iconsax.lock_1,
                        label: "reward_status".tr,
                        value: review.unlocked ? "unlocked".tr : "locked".tr,
                        valueColor: review.unlocked
                            ? const Color(0xFF16A34A)
                            : Colors.grey,
                        size: size,
                      ),
                      if (state == _ReviewState.cooldown &&
                          review.nextEligibleAt != null) ...[
                        SizedBox(height: size.height * 0.011),
                        _MetaRow(
                          icon: Iconsax.calendar_1,
                          label: "next_eligible".tr,
                          value: DateFormat('dd MMM yyyy', localeCode)
                              .format(review.nextEligibleAt!.toLocal()),
                          valueColor: const Color(0xFFF59E0B),
                          size: size,
                        ),
                      ],
                      if (review.googleReviewLink.isNotEmpty) ...[
                        SizedBox(height: size.height * 0.011),
                        _LinkRow(
                          link: review.googleReviewLink,
                          copied: _copied,
                          onCopy: _copyLink,
                          size: size,
                        ),
                      ],
                    ],
                  ),
                ),

                // ── CTA (only when actionable) ───────────────────────
                if (state == _ReviewState.eligible)
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      size.width * 0.032,
                      0,
                      size.width * 0.032,
                      size.height * 0.016,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: _WriteReviewButton(
                        onTap: widget.onWriteReview ?? () {},
                        size: size,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Small pieces
// ─────────────────────────────────────────────────────────────

/// Flat, subtle status indicator — a tinted pill with a small dot,
/// no shadow, per the app's minimal design language.
class _StatusDot extends StatelessWidget {
  final Color color;
  final String label;
  final Size size;

  const _StatusDot({
    required this.color,
    required this.label,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: size.width * 0.024,
        vertical: size.height * 0.007,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size.width * 0.016,
            height: size.width * 0.016,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: size.width * 0.014),
          AppText(
            label,
            fontSize: size.width * 0.024,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

/// One line of the details section: icon + label + value.
/// Kept flat (no nested container/border) to avoid clutter — the
/// hairline card border and divider already give it structure.
class _MetaRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Size size;

  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.size,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: size.width * 0.036, color: Colors.grey.shade500),
        SizedBox(width: size.width * 0.024),
        Expanded(
          child: AppText(
            label,
            fontSize: size.width * 0.030,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
          ),
        ),
        AppText(
          value,
          fontSize: size.width * 0.030,
          fontWeight: FontWeight.w700,
          color: valueColor,
        ),
      ],
    );
  }
}

/// Review link row with a tap-to-copy affordance (no url_launcher
/// dependency — swap the icon action for launchUrl if you add it back).
class _LinkRow extends StatelessWidget {
  final String link;
  final bool copied;
  final VoidCallback onCopy;
  final Size size;

  const _LinkRow({
    required this.link,
    required this.copied,
    required this.onCopy,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Iconsax.link_1, size: size.width * 0.036, color: Colors.grey.shade500),
        SizedBox(width: size.width * 0.024),
        Expanded(
          child: AppText(
            link,
            fontSize: size.width * 0.028,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade500,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: onCopy,
            child: Padding(
              padding: EdgeInsets.all(size.width * 0.012),
              child: Icon(
                copied ? Iconsax.tick_circle_copy : Iconsax.copy,
                size: size.width * 0.036,
                color: copied ? const Color(0xFF16A34A) : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width CTA shown only in the eligible state.
/// Uses Material + InkWell (not GestureDetector) for reliable hit-testing.
class _WriteReviewButton extends StatelessWidget {
  final VoidCallback onTap;
  final Size size;

  const _WriteReviewButton({required this.onTap, required this.size});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFBBF24);
    return Material(
      color: accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.014),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.star_1, size: size.width * 0.042, color: Colors.white),
              SizedBox(width: size.width * 0.02),
              AppText(
                "write_review".tr,
                fontSize: size.width * 0.034,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}