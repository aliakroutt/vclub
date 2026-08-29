import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/MyProfile/View/Controllers/ClientPasswordController.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/PasswordRequirementsList.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/PasswordStrengthBar.dart';

Future<void> showChangePasswordSheet(BuildContext context) {
  if (!Get.isRegistered<ClientPasswordController>()) {
    Get.put(ClientPasswordController());
  }

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return const _ChangePasswordSheetContent();
    },
  );
}

class _ChangePasswordSheetContent extends StatelessWidget {
  const _ChangePasswordSheetContent();

  static const _accent = Color(0xFFE24B4A);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ClientPasswordController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1C1F26) : Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
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
                      color: isDark
                          ? Colors.white.withOpacity(.15)
                          : Colors.black.withOpacity(.1),
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
                          colors: [_accent, _accent.withOpacity(.75)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: _accent.withOpacity(.3),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Iconsax.lock_1,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            "change_password".tr,
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                          ),
                          const SizedBox(height: 3),
                          AppText(
                            "change_password_sheet_subtitle".tr,
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).textTheme.bodySmall?.color?.withOpacity(.6),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                Obx(
                  () => _PasswordField(
                    controller: controller.currentPasswordController,
                    label: "current_password".tr,
                    obscure: !controller.showCurrent.value,
                    onToggle: controller.toggleCurrent,
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                  () => _PasswordField(
                    controller: controller.newPasswordController,
                    label: "new_password".tr,
                    obscure: !controller.showNew.value,
                    onToggle: controller.toggleNew,
                  ),
                ),

                Obx(
                  () => PasswordStrengthBar(
                    password: controller.newPasswordValue.value,
                  ),
                ),
                Obx(
                  () => PasswordRequirementsList(
                    password: controller.newPasswordValue.value,
                  ),
                ),

                const SizedBox(height: 16),

                Obx(
                  () => _PasswordField(
                    controller: controller.confirmPasswordController,
                    label: "confirm_password".tr,
                    obscure: !controller.showConfirm.value,
                    onToggle: controller.toggleConfirm,
                  ),
                ),

                const SizedBox(height: 22),

                Obx(() {
                  final saving = controller.savingPassword.value;

                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: Material(
                      color: _accent,
                      borderRadius: BorderRadius.circular(15),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: saving
                            ? null
                            : () async {
                                final success = await controller
                                    .updatePassword();
                                if (success && context.mounted)
                                  Navigator.pop(context);
                              },
                        child: Center(
                          child: saving
                              ? LoadingAnimationWidget.fourRotatingDots(
                                  color: Colors.white,
                                  size: 22,
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Iconsax.shield_tick,
                                      size: 17,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    AppText(
                                      "update_password".tr,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: AppText(
                      "cancel".tr,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
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

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
        ),
        const SizedBox(height: 7),
        Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDark
                ? Colors.white.withOpacity(.05)
                : Colors.black.withOpacity(.035),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.08)
                  : Colors.black.withOpacity(.06),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(width: 13),
              Icon(
                Iconsax.lock_1,
                size: 17,
                color: Theme.of(
                  context,
                ).textTheme.bodySmall?.color?.withOpacity(.65),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                ),
              ),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    obscure ? Iconsax.eye_slash : Iconsax.eye,
                    size: 17,
                    color: Colors.grey.withOpacity(.7),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
      ],
    );
  }
}
