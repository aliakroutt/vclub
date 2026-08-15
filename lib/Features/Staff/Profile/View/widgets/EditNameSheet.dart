import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Staff/Profile/Controllers/AgentProfileController.dart';

Future<void> showEditNameSheet(
  BuildContext context, {
  required String currentFirstName,
  required String currentLastName,
}) {
  if (!Get.isRegistered<AgentProfileController>()) {
    Get.put(AgentProfileController());
  }

  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _EditNameSheetContent(
        currentFirstName: currentFirstName,
        currentLastName: currentLastName,
      );
    },
  );
}

class _EditNameSheetContent extends StatefulWidget {
  final String currentFirstName;
  final String currentLastName;

  const _EditNameSheetContent({
    required this.currentFirstName,
    required this.currentLastName,
  });

  @override
  State<_EditNameSheetContent> createState() => _EditNameSheetContentState();
}

class _EditNameSheetContentState extends State<_EditNameSheetContent> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.currentFirstName);
    _lastNameController = TextEditingController(text: widget.currentLastName);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave(BuildContext context, AgentProfileController controller) async {
    final success = await controller.updateName(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );

    if (success && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgentProfileController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1F26) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                    color: isDark ? Colors.white.withOpacity(.15) : Colors.black.withOpacity(.1),
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
                        colors: [AppColors.primary, AppColors.primary.withOpacity(.75)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 12, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: const Icon(Iconsax.user_edit, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText("agent_edit_name_title".tr, fontSize: 16, fontWeight: FontWeight.w800),
                        const SizedBox(height: 3),
                        AppText(
                          "agent_edit_name_subtitle".tr,
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              _NameField(
                controller: _firstNameController,
                label: "agent_first_name_label".tr,
                icon: Iconsax.user,
                isDark: isDark,
              ),

              const SizedBox(height: 14),

              _NameField(
                controller: _lastNameController,
                label: "agent_last_name_label".tr,
                icon: Iconsax.user,
                isDark: isDark,
              ),

              const SizedBox(height: 22),

              Obx(() {
                final saving = controller.isUpdatingName.value;

                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Material(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(15),
                      onTap: saving ? null : () => _handleSave(context, controller),
                      child: Center(
                        child: saving
                            ? LoadingAnimationWidget.fourRotatingDots(color: Colors.white, size: 24)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Iconsax.tick_circle, size: 17, color: Colors.white),
                                  const SizedBox(width: 8),
                                  AppText("save_changes".tr, color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                                ],
                              ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;

  const _NameField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          label,
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
        ),
        const SizedBox(height: 7),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(.05) : Colors.black.withOpacity(.035),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDark ? Colors.white.withOpacity(.08) : Colors.black.withOpacity(.06)),
          ),
          child: Row(
            children: [
              const SizedBox(width: 13),
              Icon(icon, size: 17, color: AppColors.primary.withOpacity(.7)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(width: 13),
            ],
          ),
        ),
      ],
    );
  }
}