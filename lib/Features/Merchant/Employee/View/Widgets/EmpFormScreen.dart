import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Core/Snackbars.dart';

import 'package:vclub/Features/Merchant/Employee/Controllers/EmployeeController.dart';
import 'package:vclub/Features/Merchant/Employee/Models/EmployesModel.dart';
import 'package:vclub/Features/Merchant/Employee/View/Widgets/EmployeeSavedDialog.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PERMISSION META
// ─────────────────────────────────────────────────────────────────────────────

class _PermMeta {
  final String key;
  final String payloadKey;
  final IconData icon;
  final String labelKey;
  final Color color;

  const _PermMeta({
    required this.key,
    required this.payloadKey,
    required this.icon,
    required this.labelKey,
    required this.color,
  });
}

const _kPerms = [
  _PermMeta(
    key: 'scan_qr',
    payloadKey: 'scanQr',
    icon: Iconsax.scan,
    labelKey: 'scan_qr',
    color: Color(0xFF2E6BE0),
  ),
  _PermMeta(
    key: 'add_points',
    payloadKey: 'addPoints',
    icon: Iconsax.award,
    labelKey: 'add_points',
    color: Color(0xFF3B6D11),
  ),
  _PermMeta(
    key: 'validate_rewards',
    payloadKey: 'validateRewards',
    icon: Iconsax.ticket_discount,
    labelKey: 'validate_rewards',
    color: Color(0xFFB02EE0),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class EmployeeFormScreen extends StatefulWidget {
  final bool isEdit;
  final EmployeeModel? employee;

  const EmployeeFormScreen({
    super.key,
    this.isEdit = false,
    this.employee,
  });

  @override
  State<EmployeeFormScreen> createState() => _EmployeeFormScreenState();
}

class _EmployeeFormScreenState extends State<EmployeeFormScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ✅ Permissions activated by default
  final Map<String, bool> _permissions = {
    for (final p in _kPerms) p.key: true,
  };

  bool _isActive = true;
  bool _isSubmitting = false;

  late final EmployeeController _controller = Get.find<EmployeeController>();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit && widget.employee != null) {
      final e = widget.employee!;
      _firstNameController.text = e.firstName;
      _lastNameController.text = e.lastName;
      _emailController.text = e.email;
      _isActive = e.isActive;
      // If EmployeeModel later exposes permissions, prefill _permissions here.
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _validate() {
    final List<String> errors = [];

    if (_firstNameController.text.trim().isEmpty) {
      errors.add("first_name_required".tr);
    }
    if (_lastNameController.text.trim().isEmpty) {
      errors.add("last_name_required".tr);
    }

    if (_emailController.text.trim().isEmpty) {
      errors.add("email_required".tr);
    } else if (!GetUtils.isEmail(_emailController.text.trim())) {
      errors.add("invalid_email".tr);
    }

    final password = _passwordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (!widget.isEdit && password.isEmpty) {
      errors.add("password_required".tr);
    } else if (password.isNotEmpty && password.length < 6) {
      errors.add("password_too_short".tr);
    }

    if (password.isNotEmpty || confirm.isNotEmpty) {
      if (password != confirm) {
        errors.add("password_mismatch".tr);
      }
    }

    if (!_permissions.containsValue(true)) {
      errors.add("select_one_permission".tr);
    }

    if (errors.isNotEmpty) {
      AppSnackBar.multipleErrors(errors);
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_validate()) return;

    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      "firstName": _firstNameController.text.trim(),
      "lastName": _lastNameController.text.trim(),
      "email": _emailController.text.trim(),
      "permissions": {
        for (final p in _kPerms) p.payloadKey: _permissions[p.key] ?? false,
      },
    };

    if (_passwordController.text.trim().isNotEmpty) {
      payload["password"] = _passwordController.text.trim();
    }

    bool success;
    if (widget.isEdit && widget.employee != null) {
      payload["isActive"] = _isActive;
      success = await _controller.updateEmployee(widget.employee!.id, payload);
    } else {
      success = await _controller.createEmployee(payload);
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      final fullName =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}"
              .trim();
      Get.back(); // ← pop the form screen first
      EmployeeSavedDialog.show(
        isEdit: widget.isEdit,
        employeeName: fullName,
      );
    }
  }

  void _togglePermission(String key) {
    setState(() => _permissions[key] = !(_permissions[key] ?? false));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary;
      final isRTL = Get.locale?.languageCode == 'ar';
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      //   leading: _circleButton(
      //                 context,
      //                 icon: isRTL
      //                     ? Iconsax.arrow_right_3_copy
      //                     : Iconsax.arrow_left_2_copy,
      //                 onTap: () => Get.back(),
      //               )
      //   title: AppText(
      //     widget.isEdit ? 'edit_employee'.tr : 'create_employee'.tr,
      //     fontSize: 17,
      //     fontWeight: FontWeight.w800,
      //   ),
      // ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            size.width * 0.05,
            8,
            size.width * 0.05,
            size.height * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: size.height * 0.01),
              _circleButton(  
                        context,
                        icon: isRTL
                            ? Iconsax.arrow_right_3_copy
                            : Iconsax.arrow_left_2_copy,
                        onTap: () => Get.back(),
                      ),
                       SizedBox(height: size.height * 0.03),
              
              Row(
                children: [
                  Container(
                    width: size.width * 0.14,
                    height: size.width * 0.14,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: primary.withOpacity(0.10),
                    ),
                    child: Icon(
                      Iconsax.user,
                      color: primary,
                      size: size.width * 0.06,
                    ),
                  ),
                  SizedBox(width: size.width * 0.035),
                  Expanded(
                    child: AppText(
                      'employee_subtitle'.tr,
                      fontSize: size.width * 0.033,
                      color: isDark
                          ? Colors.white.withOpacity(0.45)
                          : Colors.black.withOpacity(0.40),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.03),

              _SectionLabel(label: 'personal_info'.tr, isDark: isDark),
              SizedBox(height: size.height * 0.014),

              Row(
                children: [
                  Expanded(
                    child: _PremiumField(
                      controller: _firstNameController,
                      hint: 'first_name'.tr,
                      icon: Iconsax.user,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PremiumField(
                      controller: _lastNameController,
                      hint: 'last_name'.tr,
                      icon: Iconsax.user,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * 0.012),

              _PremiumField(
                controller: _emailController,
                hint: 'email'.tr,
                icon: Iconsax.sms,
                isDark: isDark,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: size.height * 0.026),

              _SectionLabel(label: 'security'.tr, isDark: isDark),
              SizedBox(height: size.height * 0.014),

              _PremiumPasswordField(
                controller: _passwordController,
                hint:
                    widget.isEdit ? 'new_password_optional'.tr : 'password'.tr,
                isDark: isDark,
              ),

              SizedBox(height: size.height * 0.012),

              _PremiumPasswordField(
                controller: _confirmPasswordController,
                hint: 'confirm_password'.tr,
                isDark: isDark,
              ),

              if (widget.isEdit) ...[
                SizedBox(height: size.height * 0.026),
                _SectionLabel(label: 'status'.tr, isDark: isDark),
                SizedBox(height: size.height * 0.014),
                _ActiveToggleRow(
                  isActive: _isActive,
                  isDark: isDark,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
              ],

              SizedBox(height: size.height * 0.03),

              _SectionLabel(label: 'permissions'.tr, isDark: isDark),
              SizedBox(height: size.height * 0.014),

              Column(
                children: List.generate(_kPerms.length, (i) {
                  final p = _kPerms[i];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < _kPerms.length - 1 ? size.height * 0.011 : 0,
                    ),
                    child: _PermissionTile(
                      meta: p,
                      isDark: isDark,
                      selected: _permissions[p.key] ?? false,
                      onTap: () => _togglePermission(p.key),
                    ),
                  );
                }),
              ),

              SizedBox(height: size.height * 0.04),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: GestureDetector(
                  onTap: _isSubmitting ? null : _submit,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: primary,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withOpacity(0.30),
                          blurRadius: 16,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  widget.isEdit
                                      ? Iconsax.edit_2
                                      : Iconsax.user_add,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                AppText(
                                  widget.isEdit
                                      ? 'save_changes'.tr
                                      : 'create_employee'.tr,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            color: isDark
                ? Colors.white.withOpacity(0.28)
                : Colors.black.withOpacity(0.28),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE TOGGLE (edit mode only)
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveToggleRow extends StatelessWidget {
  final bool isActive;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  const _ActiveToggleRow({
    required this.isActive,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isActive),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.025),
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.06),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: AppText(
                'account_active'.tr,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            Switch.adaptive(
              value: isActive,
              onChanged: onChanged,
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;

  const _PremiumField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final _focus = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.isDark
            ? Colors.white.withOpacity(_isFocused ? 0.07 : 0.04)
            : Colors.black.withOpacity(_isFocused ? 0.04 : 0.03),
        border: Border.all(
          color: _isFocused
              ? primary.withOpacity(0.50)
              : widget.isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.07),
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        keyboardType: widget.keyboardType,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: widget.isDark ? Colors.white : const Color(0xFF111111),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            widget.icon,
            size: 18,
            color: _isFocused
                ? primary
                : widget.isDark
                    ? Colors.white.withOpacity(0.28)
                    : Colors.black.withOpacity(0.26),
          ),
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: widget.isDark
                ? Colors.white.withOpacity(0.22)
                : Colors.black.withOpacity(0.22),
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM PASSWORD FIELD
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isDark;

  const _PremiumPasswordField({
    required this.controller,
    required this.hint,
    required this.isDark,
  });

  @override
  State<_PremiumPasswordField> createState() => _PremiumPasswordFieldState();
}

class _PremiumPasswordFieldState extends State<_PremiumPasswordField> {
  final _focus = FocusNode();
  bool _isFocused = false;
  bool _obscure = true;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() => _isFocused = _focus.hasFocus));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: widget.isDark
            ? Colors.white.withOpacity(_isFocused ? 0.07 : 0.04)
            : Colors.black.withOpacity(_isFocused ? 0.04 : 0.03),
        border: Border.all(
          color: _isFocused
              ? primary.withOpacity(0.50)
              : widget.isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.black.withOpacity(0.07),
          width: _isFocused ? 1.5 : 1.0,
        ),
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: primary.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        obscureText: _obscure,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
          color: widget.isDark ? Colors.white : const Color(0xFF111111),
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(
            Iconsax.lock,
            size: 18,
            color: _isFocused
                ? primary
                : widget.isDark
                    ? Colors.white.withOpacity(0.28)
                    : Colors.black.withOpacity(0.26),
          ),
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            color: widget.isDark
                ? Colors.white.withOpacity(0.22)
                : Colors.black.withOpacity(0.22),
          ),
          suffixIcon: GestureDetector(
            onTap: () => setState(() => _obscure = !_obscure),
            child: Icon(
              _obscure ? Iconsax.eye_slash : Iconsax.eye,
              size: 18,
              color: widget.isDark
                  ? Colors.white.withOpacity(0.30)
                  : Colors.black.withOpacity(0.28),
            ),
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PERMISSION TILE
// ─────────────────────────────────────────────────────────────────────────────

class _PermissionTile extends StatelessWidget {
  final _PermMeta meta;
  final bool isDark;
  final bool selected;
  final VoidCallback onTap;

  const _PermissionTile({
    required this.meta,
    required this.isDark,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = meta.color;
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.038,
          vertical: size.width * 0.034,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? color.withOpacity(isDark ? 0.12 : 0.07)
              : isDark
                  ? Colors.white.withOpacity(0.04)
                  : Colors.black.withOpacity(0.025),
          border: Border.all(
            color: selected
                ? color.withOpacity(0.40)
                : isDark
                    ? Colors.white.withOpacity(0.07)
                    : Colors.black.withOpacity(0.06),
            width: selected ? 1.5 : 1.0,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withOpacity(isDark ? 0.15 : 0.10),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: size.width * 0.10,
              height: size.width * 0.10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color:
                    selected ? color.withOpacity(0.18) : color.withOpacity(0.09),
              ),
              child:
                  Icon(meta.icon, color: color, size: size.width * 0.046),
            ),
            SizedBox(width: size.width * 0.035),
            Expanded(
              child: AppText(
                meta.labelKey.tr,
                fontSize: size.width * 0.034,
                fontWeight: FontWeight.w600,
                color: selected
                    ? color
                    : isDark
                        ? Colors.white.withOpacity(0.80)
                        : Colors.black.withOpacity(0.75),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 26,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: selected
                    ? color
                    : isDark
                        ? Colors.white.withOpacity(0.10)
                        : Colors.black.withOpacity(0.08),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.30),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment:
                    selected ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
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
              color: isDark
                  ? Colors.black.withOpacity(.3)
                  : Colors.black.withOpacity(.2),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }