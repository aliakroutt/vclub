import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Settings/Utils/PasswordStrength.dart';

class PasswordRequirementsList extends StatelessWidget {
  final String password;

  const PasswordRequirementsList({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final checks = [
      ("password_req_length".tr, PasswordStrength.hasMinLength(password)),
      ("password_req_uppercase".tr, PasswordStrength.hasUppercase(password)),
      ("password_req_number".tr, PasswordStrength.hasNumber(password)),
      ("password_req_special".tr, PasswordStrength.hasSpecialChar(password)),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: checks.map((c) {
          final (label, met) = c;
          final color = met ? const Color(0xFF00C896) : Colors.grey.withOpacity(.5);

          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(met ? Iconsax.tick_circle : Iconsax.close_circle, size: 13, color: color),
              const SizedBox(width: 4),
              AppText(label, fontSize: 10.5, fontWeight: FontWeight.w600, color: color),
            ],
          );
        }).toList(),
      ),
    );
  }
}