import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Features/Client/MyProfile/View/Controllers/UpdtaeProfileController.dart';
import 'package:vclub/Features/Client/MyProfile/View/UpdateProfile/Widgets/PhoneField.dart';
import 'package:vclub/Features/Client/MyProfile/View/UpdateProfile/Widgets/datefield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ClientController controller = Get.find<ClientController>();
  final UpdateProfileController updateController = Get.put(UpdateProfileController());
  final RxBool _isSaving = false.obs;

  late final TextEditingController _firstNameCtrl;
  late final TextEditingController _lastNameCtrl;
  DateTime? _birthday;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    final client = controller.client.value;
    _firstNameCtrl = TextEditingController(text: client?.firstName ?? '');
    _lastNameCtrl = TextEditingController(text: client?.lastName ?? '');
    _birthday = client?.birthday;
    _phone = client?.phone ?? '';
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    super.dispose();
  }

   
  

 

  // ...initState/dispose unchanged...

  Future<void> _save() async {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'field_required'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
      return;
    }

    final success = await updateController.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: _phone,
      birthday: _birthday,
      avatar: controller.client.value?.avatar,
    );

    if (!mounted) return;
    if (success) {
      Get.back();
      Get.snackbar(
        'success'.tr,
        'profile_updated_successfully'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        margin: const EdgeInsets.all(14),
        borderRadius: 14,
      );
    }

  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: KeyboardDismissOnTap(child:  Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Align(
                  alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
                  child: _circleButton(
                    context,
                    icon: isRTL ? Iconsax.arrow_right_3_copy : Iconsax.arrow_left_2_copy,
                    onTap: () => Get.back(),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: MediaQuery.sizeOf(context).width > 600 ? 32 : 20,
                        ).copyWith(top: 12, bottom: 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _StaggerItem(
                              index: 0,
                              child: _PremiumField(
                                controller: _firstNameCtrl,
                                label: 'first_name'.tr,
                                icon: Iconsax.user_copy,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _StaggerItem(
                              index: 1,
                              child: _PremiumField(
                                controller: _lastNameCtrl,
                                label: 'last_name'.tr,
                                icon: Iconsax.user_copy,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _StaggerItem(
                              index: 2,
                              child: AppPhoneField(
                                label: 'phone'.tr,
                                initialPhone: _phone,
                                onChanged: (v) => _phone = v,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _StaggerItem(
                              index: 3,
                              child: AppDateField(
                                label: 'birthday'.tr,
                                value: _birthday,
                                firstDate: DateTime(1930, 1, 1),
                                lastDate: DateTime.now(),
                                onChanged: (d) => setState(() => _birthday = d),
                              ),
                            ),
                            const SizedBox(height: 36),
                            _StaggerItem(
                              index: 4,
                              child: _SaveButton(isSaving: updateController.isSaving, onTap: _save),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

/// Premium text field: floating label, soft depth via layered shadow
/// instead of a flat fill, an icon in its own rounded chip, and a subtle
/// border glow when focused. No built-in validation — required-field
/// checks now happen in `_save()` and surface as a snackbar.
class _PremiumField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;

  const _PremiumField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: _focused
              ? AppColors.primary
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _focused
                ? AppColors.primary.withOpacity(0.16)
                : Colors.black.withOpacity(isDark ? 0.18 : 0.045),
            blurRadius: _focused ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: widget.label,
          hintStyle: TextStyle(
            color: Colors.grey.withOpacity(0.85),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(11),
            child: Icon(widget.icon, size: 15, color: AppColors.primary),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 44),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Fades + slides a child up into place, staggered by [index].
class _StaggerItem extends StatelessWidget {
  final int index;
  final Widget child;

  const _StaggerItem({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + (index * 60)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 18),
          child: child,
        ),
      ),
      child: child,
    );
  }
}

/// Gradient save button with press-scale feedback and an inline
/// loading/idle swap — no layout jump when the spinner appears.
class _SaveButton extends StatefulWidget {
  final RxBool isSaving;
  final VoidCallback onTap;

  const _SaveButton({required this.isSaving, required this.onTap});

  @override
  State<_SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<_SaveButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTapDown: widget.isSaving.value ? null : (_) => setState(() => _scale = 0.97),
        onTapUp: widget.isSaving.value ? null : (_) => setState(() => _scale = 1),
        onTapCancel: () => setState(() => _scale = 1),
        onTap: widget.isSaving.value ? null : widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          child: Container(
            width: double.infinity,
            height: 54,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: widget.isSaving.value
                  ? const SizedBox(
                      key: ValueKey('loading'),
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : Row(
                      key: const ValueKey('idle'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Iconsax.tick_circle, size: 18, color: Colors.white),
                        const SizedBox(width: 8),
                        AppText('save_changes'.tr, fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _circleButton(
  BuildContext context, {
  required IconData icon,
  required VoidCallback onTap,
}) {
  final isDark = Get.isDarkMode;
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(.3) : Colors.black.withOpacity(.2),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 18),
    ),
  );
}