import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Settings/Controllers/SettingsController.dart';

class ChangePasswordCard extends StatefulWidget {
  const ChangePasswordCard({super.key});

  @override
  State<ChangePasswordCard> createState() => _ChangePasswordCardState();
}

class _ChangePasswordCardState extends State<ChangePasswordCard> {
  static const _accent = Color(0xFFE8640C);
  final controller = Get.find<SettingsController>();
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showOld = false;
  bool showNew = false;
  bool showConfirm = false;

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

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
                  Iconsax.lock,
                  color: _accent,
                  size: size.width * .052,
                ),
              ),
              SizedBox(width: size.width * .035),
              Expanded(
                child: AppText(
                  "change_password".tr,
                  fontSize: size.width * .042,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: size.height * .025),

          /// OLD PASSWORD
          Obx(
            () => _PasswordField(
              label: "current_password".tr,
              controller: controller.currentPasswordController,
              obscure: !controller.showCurrent.value,
              onToggle: controller.toggleCurrent,
            ),
          ),

          SizedBox(height: size.height * .018),

          /// NEW PASSWORD
          Obx(
            () => _PasswordField(
              label: "new_password".tr,
              controller: controller.newPasswordController,
              obscure: !controller.showNew.value,
              onToggle: controller.toggleNew,
            ),
          ),

          SizedBox(height: size.height * .018),

          /// CONFIRM PASSWORD
          Obx(
            () => _PasswordField(
              label: "confirm_new_password".tr,
              controller: controller.confirmPasswordController,
              obscure: !controller.showConfirm.value,
              onToggle: controller.toggleConfirm,
            ),
          ),

          SizedBox(height: size.height * .025),

          /// BUTTON
          SizedBox(
            width: double.infinity,
            height: size.height * .06,
            child: ElevatedButton.icon(
              onPressed: controller.updatePassword,
              icon: const Icon(Iconsax.tick_circle, color: Colors.white),
              label: AppText(
                "update_password".tr,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontSize: size.height * .017,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    14,
                  ), // 👈 slight radius (modern)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
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
              Icon(Iconsax.lock, size: 18, color: Colors.grey),

              SizedBox(width: size.width * .03),

              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: TextStyle(
                    fontSize: size.width * .034,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                    hintText: "••••••••••",
                    hintStyle: TextStyle(
                      fontSize: size.width * .040,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.withOpacity(0.4),
                      letterSpacing: 3,
                    ),
                  ),
                ),
              ),

              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscure ? Iconsax.eye_slash : Iconsax.eye,
                  size: 18,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
