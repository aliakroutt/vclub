import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/ClubsClient/View/Clubs.dart' show ClubViewerRole;


/// Small card shown right under [ClubHeader]. Its content depends on
/// who is viewing the screen:
/// - [ClubViewerRole.guest] -> login / signup buttons
/// - [ClubViewerRole.ownerMerchant] / [ClubViewerRole.otherMerchant] ->
///   short text + "View my cards" button
/// - [ClubViewerRole.client] -> a short hint text only
/// - [ClubViewerRole.staff] -> nothing (returns an empty widget)
class ClubRoleActionCard extends StatelessWidget {
  final ClubViewerRole role;
  final VoidCallback? onLogin;
  final VoidCallback? onSignup;
  final VoidCallback? onViewMyCards;

  const ClubRoleActionCard({
    super.key,
    required this.role,
    this.onLogin,
    this.onSignup,
    this.onViewMyCards,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case ClubViewerRole.guest:
        return _CardShell(child: _GuestContent(onLogin: onLogin, onSignup: onSignup));
      case ClubViewerRole.ownerMerchant:
      case ClubViewerRole.otherMerchant:
        return _CardShell(child: _MerchantContent(onViewMyCards: onViewMyCards));
      case ClubViewerRole.client:
        return _CardShell(child: _ClientContent());
      case ClubViewerRole.staff:
        return const SizedBox.shrink();
    }
  }
}

class _CardShell extends StatelessWidget {
  final Widget child;

  const _CardShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.25) : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GuestContent extends StatelessWidget {
  final VoidCallback? onLogin;
  final VoidCallback? onSignup;

  const _GuestContent({this.onLogin, this.onSignup});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          'club_role_card_guest_text'.tr,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.primary.withOpacity(0.7) : AppColors.primaryLight,
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onLogin,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.35)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AppText(
                  'club_role_card_login_button'.tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.primary : AppColors.primaryDark,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: onSignup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: AppText(
                  'club_role_card_signup_button'.tr,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MerchantContent extends StatelessWidget {
  final VoidCallback? onViewMyCards;

  const _MerchantContent({this.onViewMyCards});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          'club_role_card_merchant_text'.tr,
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark ? AppColors.primary.withOpacity(0.7) : AppColors.primaryLight,
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onViewMyCards,
            icon: const Icon(Iconsax.card_copy, size: 18, color: Colors.white),
            label: AppText(
              'club_role_card_merchant_button'.tr,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClientContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Icon(
          Iconsax.magic_star_copy,
          size: 18,
          color: AppColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AppText(
            'club_role_card_client_text'.tr,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.primary.withOpacity(0.8) : AppColors.primaryLight,
          ),
        ),
      ],
    );
  }
}