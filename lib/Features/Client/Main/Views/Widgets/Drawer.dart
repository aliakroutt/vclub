import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Features/Client/Main/Controllers/MainController.dart';

class MainDrawer extends StatelessWidget {
  final MainController controller;
  final ThemeService themeService;

  const MainDrawer({
    super.key,
    required this.controller,
    required this.themeService,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final primary = AppColors.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profilecontroller = Get.find<ClientController>();
    return Drawer(
      backgroundColor: isDark
          ? const Color(0xFF0E0E10)
          : const Color(0xFFF8F8FB),
      child: SafeArea(
        child: Column(
          children: [
            /// ───────────────── HEADER (PREMIUM) ─────────────────
            Padding(
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  child: Container(
    width: double.infinity,
    padding: EdgeInsets.all(size.width * 0.045),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF18181B) : Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: isDark
            ? Colors.white.withOpacity(.06)
            : Colors.black.withOpacity(.05),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? .25 : .04),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Builder(
  builder: (context) {
    final avatarImage = _avatarProvider(profilecontroller.client.value?.avatar);
    final firstName = profilecontroller.client.value?.firstName ?? '';
    final lastName = profilecontroller.client.value?.lastName ?? '';

    return Row(
      children: [
        // ── AVATAR ─────────────────────────────────────────────
        Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: avatarImage == null
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primary.withOpacity(.22), primary.withOpacity(.06)],
                  )
                : null,
            color: avatarImage == null ? null : Colors.transparent,
            image: avatarImage != null ? DecorationImage(image: avatarImage, fit: BoxFit.cover) : null,
            border: Border.all(color: primary.withOpacity(.20), width: 1.6),
          ),
          child: avatarImage == null
              ? Center(
                  child: AppText(
                    _initials(firstName, lastName),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                )
              : null,
        ),

        SizedBox(width: size.width * 0.035),

        // ── TEXT ───────────────────────────────────────────────
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                "$firstName $lastName",
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
              const SizedBox(height: 4),
              AppText(
                profilecontroller.client.value?.email ?? '',
                fontSize: 12.5,
                color: Colors.grey,
              ),
            ],
          ),
        ),

        // ── MERCHANT BADGE ───────────────────────────────────────
      ],
    );
  },
),
  ),
),

            const SizedBox(height: 14),

            /// ───────────────── MENU ─────────────────
            Expanded(
              child: Obx(() {
                return Padding(
                  padding: EdgeInsets.all(size.width * 0.01),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _item(context, Iconsax.home_2, "dashboard".tr, 0),
                      _item(context, Iconsax.card, "my_cards".tr, 1),
                      _item(context, Iconsax.gift, "rewards".tr, 2),
                      _item(context, Iconsax.clock, "history".tr, 4),
                      _item(context, Iconsax.cup, "fortune_wheel".tr, 5),
                      _item(context, Iconsax.notification, "notifications".tr, 6),
                      _item(context, Iconsax.user, "my_profile".tr, 3),
                    ],
                  ),
                );
              }),
            ),

            /// ───────────────── LOGOUT (PREMIUM BUTTON) ─────────────────
            Padding(
              padding: EdgeInsets.all(size.width * 0.04),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.red.withOpacity(.08),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(.08),
                        blurRadius: 15,
                      ),
                    ],
                  ),

                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Iconsax.logout,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      AppText(
                        "logout",
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ───────────────── ITEM (PREMIUM STYLE) ─────────────────
  Widget _item(BuildContext context, IconData icon, String title, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = controller.selectedIndex.value == index;
    final primary = AppColors.primary;

    return GestureDetector(
      onTap: () {
        controller.selectIndex(index);
        Get.back();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          boxShadow: isSelected
              ? [BoxShadow(color: primary.withOpacity(.10), blurRadius: 12)]
              : [],
        ),
        child: Row(
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? primary.withOpacity(.12)
                    : (isDark
                          ? Colors.white.withOpacity(.04)
                          : Colors.grey.withOpacity(.08)),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? primary : Colors.grey,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: AppText(
                title,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? primary : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

ImageProvider? _avatarProvider(String? avatar) {
  if (avatar == null || avatar.isEmpty) return null;
  return NetworkImage(avatar);
}

String _initials(String firstName, String lastName) {
  final f = firstName.isNotEmpty ? firstName[0] : '';
  final l = lastName.isNotEmpty ? lastName[0] : '';
  final combined = (f + l).toUpperCase();
  return combined.isNotEmpty ? combined : '?';
}