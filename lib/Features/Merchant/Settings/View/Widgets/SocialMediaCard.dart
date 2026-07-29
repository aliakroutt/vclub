import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class SocialMediaCard extends StatelessWidget {
  const SocialMediaCard({
    super.key,
    required this.facebookController,
    required this.instagramController,
    required this.linkedinController,
    required this.twitterController,
    required this.youtubeController,
    required this.tiktokController,
  });

  final TextEditingController facebookController;
  final TextEditingController instagramController;
  final TextEditingController linkedinController;
  final TextEditingController twitterController;
  final TextEditingController youtubeController;
  final TextEditingController tiktokController;

  static const _accent = Color(0xFF00B894);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(.06)
              : Colors.black.withOpacity(.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? .22 : .04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ── HEADER ─────────────────────────────
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: _accent.withOpacity(.10),
                ),
                child: Icon(
                  Iconsax.share,
                  color: _accent,
                  size: size.width * .052,
                ),
              ),
              SizedBox(width: size.width * .035),
              Expanded(
                child: AppText(
                  "social_media".tr,
                  fontSize: size.width * .042,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .025),

          _SocialField(
            label: "facebook_url".tr,
            icon: Iconsax.facebook,
            controller: facebookController,
          ),
          SizedBox(height: size.height * .015),

          _SocialField(
            label: "instagram_url".tr,
            icon: Iconsax.instagram,
            controller: instagramController,
          ),
          SizedBox(height: size.height * .015),

          _SocialField(
            label: "linkedin_url".tr,
            icon: Iconsax.link,
            controller: linkedinController,
          ),
          SizedBox(height: size.height * .015),

          _SocialField(
            label: "twitter_url".tr,
            icon: Iconsax.global,
            controller: twitterController,
          ),
          SizedBox(height: size.height * .015),

          _SocialField(
            label: "youtube_url".tr,
            icon: Iconsax.youtube,
            controller: youtubeController,
          ),
          SizedBox(height: size.height * .015),

          _SocialField(
            label: "tiktok_url".tr,
            icon: Icons.tiktok,
            controller: tiktokController,
          ),
        ],
      ),
    );
  }
}

class _SocialField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;

  const _SocialField({
    required this.label,
    required this.icon,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: size.width * .031,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),

        SizedBox(height: 6),

        Container(
          height: size.height * .06,
          padding: EdgeInsets.symmetric(horizontal: size.width * .03),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark
                ? Colors.white.withOpacity(.03)
                : Colors.black.withOpacity(.02),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.06)
                  : Colors.black.withOpacity(.05),
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF00B894)),
              SizedBox(width: size.width * .03),

              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontSize: size.width * .034,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}