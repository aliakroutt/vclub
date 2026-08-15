import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/SessionsCard.dart';
import 'package:vclub/Features/Staff/Profile/View/widgets/AgentChangePasswordCard.dart';
import 'package:vclub/Features/Staff/Profile/View/widgets/EditNameSheet.dart';

class StaffProfileScreen extends StatelessWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return KeyboardDismissOnTap(child:  Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .015),

              Align(
                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: FadeSlide(
                  delayMs: 150,
                  child: AppText("agent_profile_title".tr, fontSize: 22, fontWeight: FontWeight.w800),
                ),
              ),

              const SizedBox(height: 8),

              Align(
                alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                child: FadeSlide(
                  delayMs: 200,
                  child: AppText(
                    "agent_profile_subtitle".tr,
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
                  ),
                ),
              ),

              SizedBox(height: size.height * .03),

              FadeSlide(
                delayMs: 260,
                child: const _AgentProfileCard(),
              ),

              SizedBox(height: size.height * 0.02),
              FadeSlide(delayMs: 320, child: AgentChangePasswordCard()),

              SizedBox(height: size.height * 0.02),
              FadeSlide(delayMs: 380, child: SessionsCard()),

              SizedBox(height: size.height * 0.15),
             
            ],
          ),
        ),
      ),
    ));
  }
}

class _AgentProfileCard extends StatelessWidget {
  const _AgentProfileCard();

  ImageProvider? _decodeLogo(String? logo) {
    if (logo == null || logo.isEmpty) return null;
    try {
      final base64Str = logo.contains(',') ? logo.split(',').last : logo;
      return MemoryImage(base64Decode(base64Str));
    } catch (_) {
      return null;
    }
  }

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return "?";
    return trimmed.split(" ").map((e) => e.isNotEmpty ? e[0] : "").take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final agent = AgentController.to.agent.value;
      final fullName = agent != null ? "${agent.firstName} ${agent.lastName}".trim() : "";
      final email = agent?.email ?? "";
      final companyName = agent?.company?.name ?? "";
      final companyLogo = _decodeLogo(agent?.company?.logo);

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1C1C22), const Color(0xFF17171B)]
                : [Colors.white, const Color(0xFFFCFBFF)],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.primary.withOpacity(isDark ? .18 : .12)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(isDark ? .1 : .06),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? .25 : .03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
           Row(
  children: [
    // ── AVATAR ──
    Container(
      height: 52,
      width: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: companyLogo == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary.withOpacity(.22), AppColors.primary.withOpacity(.06)],
              )
            : null,
        border: Border.all(color: AppColors.primary.withOpacity(.25), width: 1.6),
        image: companyLogo != null ? DecorationImage(image: companyLogo, fit: BoxFit.cover) : null,
      ),
      child: companyLogo == null
          ? Center(
              child: AppText(_initials(fullName), fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.primary),
            )
          : null,
    ),

    const SizedBox(width: 13),

    // ── NAME + ROLE BADGE ──
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            fullName.isNotEmpty ? fullName : "—",
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Iconsax.shield_tick, size: 10, color: AppColors.primary),
                const SizedBox(width: 4),
                AppText("agent_role_label".tr, fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    ),

    // ── EDIT NAME BUTTON ──
    Material(
      color: AppColors.primary.withOpacity(.1),
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        borderRadius: BorderRadius.circular(11),
        onTap: () => showEditNameSheet(
          context,
          currentFirstName: agent?.firstName ?? "",
          currentLastName: agent?.lastName ?? "",
        ),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: Icon(Iconsax.edit_2, size: 16, color: AppColors.primary),
        ),
      ),
    ),
  ],
),

            const SizedBox(height: 14),
            Divider(height: 1, color: isDark ? Colors.white.withOpacity(.07) : Colors.black.withOpacity(.05)),
            const SizedBox(height: 12),

            // ── EMAIL + COMPANY (compact rows) ──
            _InfoRow(icon: Iconsax.sms, label: "agent_email_label".tr, value: email.isNotEmpty ? email : "—"),
            const SizedBox(height: 9),
            _InfoRow(icon: Iconsax.shop, label: "agent_company_label".tr, value: companyName.isNotEmpty ? companyName : "—"),
          ],
        ),
      );
    });
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          height: 30,
          width: 30,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 14, color: AppColors.primary),
        ),
        const SizedBox(width: 10),
        // AppText(
        //   label,
        //   fontSize: 11.5,
        //   fontWeight: FontWeight.w600,
        //   color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.5),
        // ),
        // const Spacer(),
        Flexible(
          child: AppText(
            value,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

