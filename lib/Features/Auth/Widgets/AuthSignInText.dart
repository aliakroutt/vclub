import 'package:flutter/material.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class AuthSignInText extends StatelessWidget {
  final VoidCallback onTap;

  const AuthSignInText({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Padding(
      padding: EdgeInsets.only(
        top: size.height * 0.01,
        bottom: size.height * 0.02,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppText(
            "already_have_account",
            fontSize: size.width * 0.035,
            color: Colors.grey.shade600,
          ),

          SizedBox(width: size.width * 0.01),

          GestureDetector(
            onTap: onTap,
            child: AppText(
              "sign_in_",
              fontSize: size.width * 0.036,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}