import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/SmsAddonController.dart';

class CompanyHeaderCard extends StatelessWidget {
  const CompanyHeaderCard({
    super.key,
    required this.company,
    this.onManageSubscription,
    this.onCancelSubscription,
  });

  final CompanyModel? company;
  final VoidCallback? onManageSubscription;
  final VoidCallback? onCancelSubscription;

  static const _accent = Color(0xFF7C6FF7);
  static const _activeColor = Color(0xFF00C896);
  static const _inactiveColor = Color(0xFFFF6B6B);
  static const _goldColor = Color(0xFFFFB930);

  ImageProvider? _decodeLogo() {
    final logo = company?.logo;
    if (logo == null || logo.isEmpty) return null;
    try {
      final base64Str = logo.contains(',') ? logo.split(',').last : logo;
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final name = (company?.name.isNotEmpty ?? false) ? company!.name : "—";
    final firstLetter = name.isNotEmpty && name != "—"
        ? name[0].toUpperCase()
        : '?';
    final isActive = company?.isSubscriptionActive ?? false;
    final isPremium = company?.isPremiumPlan ?? false;
    final planLabel = (company?.stripePlan?.isNotEmpty ?? false)
        ? company!.stripePlan!
        : "free_plan".tr;
    final logoImage = _decodeLogo();
    final cancelScheduled = company?.cancelAtPeriodEnd ?? false;

    final surfaceColor = Theme.of(context).colorScheme.surface;
    final borderColor = isDark
        ? Colors.white.withOpacity(.07)
        : Colors.black.withOpacity(.06);

    String? endsDateLabel;
    if (company?.subscriptionEndsAt != null) {
      final formatted = DateFormat(
        'd MMM yyyy',
      ).format(company!.subscriptionEndsAt!);
      endsDateLabel = cancelScheduled
          ? "${"ends_on".tr} $formatted"
          : "${"renews_on".tr} $formatted";
    }

    return Container(
      padding: EdgeInsets.all(size.width * .046),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: surfaceColor,
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .30 : .06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _accent.withOpacity(isDark ? .07 : .04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(
                letter: firstLetter,
                size: size.width * .13,
                image: logoImage,
              ),
              SizedBox(width: size.width * .04),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: AppText(
                            name,
                            fontSize: size.width * .043,
                            fontWeight: FontWeight.w800,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusDot(isActive: isActive),
                      ],
                    ),
                    SizedBox(height: size.height * .005),
                    Row(
                      children: [
                        Icon(
                          Iconsax.hashtag,
                          size: 12,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: AppText(
                            company?.uid ?? "—",
                            fontSize: size.width * .031,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .018),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _PlanChip(label: planLabel, isPremium: isPremium),
              if (cancelScheduled)
                _InfoChip(
                  icon: Iconsax.warning_2,
                  label: "cancels_at_period_end".tr,
                  color: Colors.orangeAccent,
                ),
            ],
          ),

          if (endsDateLabel != null) ...[
            SizedBox(height: size.height * .014),
            Row(
              children: [
                Icon(Iconsax.calendar_1, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 7),
                AppText(
                  endsDateLabel,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color?.withOpacity(.65),
                ),
              ],
            ),
          ],

          SizedBox(height: size.height * .02),
          Divider(height: 1, color: borderColor),
          SizedBox(height: size.height * .018),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: Obx(() {
              final loading =
                  Get.find<SmsAddonController>().isOpeningPortal.value;

              return Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: loading ? null : onManageSubscription,
                  child: Center(
                    child: loading
                        ? LoadingAnimationWidget.fourRotatingDots(
                            color: Colors.white,
                            size: 22,
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Iconsax.card_edit,
                                size: 17,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              AppText(
                                "manage_subscription".tr,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ],
                          ),
                  ),
                ),
              );
            }),
          ),

          if (isActive && !cancelScheduled) ...[
            SizedBox(height: size.height * .012),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: Material(
                color: Colors.redAccent.withOpacity(.08),
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: onCancelSubscription,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.close_circle,
                        size: 17,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      AppText(
                        "cancel_plan".tr,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── AVATAR ──
class _Avatar extends StatelessWidget {
  const _Avatar({required this.letter, required this.size, this.image});
  final String letter;
  final double size;
  final ImageProvider? image;

  static const _accent = Color(0xFF7C6FF7);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: image == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_accent.withOpacity(.22), _accent.withOpacity(.06)],
              )
            : null,
        border: Border.all(color: _accent.withOpacity(.22), width: 1.5),
        image: image != null
            ? DecorationImage(image: image!, fit: BoxFit.cover)
            : null,
      ),
      child: image == null
          ? Center(
              child: AppText(
                letter,
                fontSize: size * .44,
                fontWeight: FontWeight.w900,
                color: _accent,
              ),
            )
          : null,
    );
  }
}

// ── STATUS DOT ──
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? const Color(0xFF00C896) : const Color(0xFFFF6B6B);
    final label = isActive ? 'active_label'.tr : 'inactive_label'.tr;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(.10),
        border: Border.all(color: color.withOpacity(.22), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
          const SizedBox(width: 5),
          AppText(
            label,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── PLAN CHIP ──
class _PlanChip extends StatelessWidget {
  const _PlanChip({required this.label, required this.isPremium});
  final String label;
  final bool isPremium;

  static const _gold = Color(0xFFFFB930);

  @override
  Widget build(BuildContext context) {
    final color = isPremium ? _gold : AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(.10),
        border: Border.all(color: color.withOpacity(.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPremium ? Iconsax.diamonds : Iconsax.medal_star,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 5),
          AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── GENERIC INFO CHIP (used for "cancels at period end") ──
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: color.withOpacity(.10),
        border: Border.all(color: color.withOpacity(.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          AppText(
            label,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ],
      ),
    );
  }
}
