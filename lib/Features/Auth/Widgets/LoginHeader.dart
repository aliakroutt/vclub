import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    final width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: isArabic
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.start,
      children: [
        AppText(
          title,
          fontSize: width * 0.08, // ~26-30 on most phones
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.onSurface,
          // letterSpacing: 0.8,
        ),

        SizedBox(height: width * 0.03),

        AppText(
          subtitle,
          fontSize: width * 0.037, // ~14-17 on most phones
          fontWeight: FontWeight.w400,
          color: Colors.grey,
        ),
      ],
    );
  }
}