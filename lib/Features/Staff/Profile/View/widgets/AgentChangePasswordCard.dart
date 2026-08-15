import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/PasswordRequirementsList.dart';
import 'package:vclub/Features/Merchant/Settings/View/Widgets/PasswordStrengthBar.dart';
import 'package:vclub/Features/Staff/Profile/Controllers/AgentPasswordController.dart';

class AgentChangePasswordCard extends StatelessWidget {
  AgentChangePasswordCard({super.key});

  final controller = Get.put(AgentPasswordController());
  static const _accent = Color(0xFFE24B4A);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(size.width * .045),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? .22 : .04), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: size.width * .105,
                height: size.width * .105,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: _accent.withOpacity(.10)),
                child: Icon(Iconsax.lock_1, color: _accent, size: size.width * .052),
              ),
              SizedBox(width: size.width * .035),
              Expanded(child: AppText("change_password".tr, fontSize: size.width * .042, fontWeight: FontWeight.w700)),
            ],
          ),

          SizedBox(height: size.height * .025),

          Obx(() => _PasswordField(
                controller: controller.currentPasswordController,
                label: "current_password".tr,
                obscure: !controller.showCurrent.value,
                onToggle: controller.toggleCurrent,
              )),

          SizedBox(height: size.height * .018),

          Obx(() => _PasswordField(
                controller: controller.newPasswordController,
                label: "new_password".tr,
                obscure: !controller.showNew.value,
                onToggle: controller.toggleNew,
              )),

          Obx(() => PasswordStrengthBar(password: controller.newPasswordValue.value)),
          Obx(() => PasswordRequirementsList(password: controller.newPasswordValue.value)),

          SizedBox(height: size.height * .018),

          Obx(() => _PasswordField(
                controller: controller.confirmPasswordController,
                label: "confirm_password".tr,
                obscure: !controller.showConfirm.value,
                onToggle: controller.toggleConfirm,
              )),

          SizedBox(height: size.height * .022),

          Obx(() {
            final saving = controller.savingPassword.value;

            return SizedBox(
              width: double.infinity,
              height: size.height * .056,
              child: Material(
                color: _accent,
                borderRadius: BorderRadius.circular(14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: saving ? null : controller.updatePassword,
                  child: Center(
                    child: saving
                        ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 22)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Iconsax.shield_tick, size: 17, color: Colors.white),
                              const SizedBox(width: 8),
                              AppText("update_password".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                            ],
                          ),
                  ),
                ),
              ),
            );
          }),
        ],
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
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(label, fontSize: size.width * .031, fontWeight: FontWeight.w600, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65)),
        SizedBox(height: size.height * .008),
        Container(
          height: size.height * .062,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isDark ? Colors.white.withOpacity(.03) : Colors.black.withOpacity(.02),
            border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
          ),
          child: Row(
            children: [
              SizedBox(width: size.width * .035),
              Icon(Iconsax.lock_1, size: size.width * .05, color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65)),
              SizedBox(width: size.width * .03),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscure,
                  style: TextStyle(fontSize: size.width * .034, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(border: InputBorder.none, isCollapsed: true),
                ),
              ),
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    obscure ? Iconsax.eye_slash : Iconsax.eye,
                    size: size.width * .05,
                    color: Colors.grey.withOpacity(.7),
                  ),
                ),
              ),
              SizedBox(width: size.width * .02),
            ],
          ),
        ),
      ],
    );
  }
}