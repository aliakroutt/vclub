import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';

class AuditScreen extends StatelessWidget {
  const AuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 96,
                  width: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(.16),
                        AppColors.primary.withOpacity(.04),
                      ],
                    ),
                  ),
                  child: Icon(Iconsax.document_text_1, size: 40, color: AppColors.primary.withOpacity(.7)),
                ),
                const SizedBox(height: 24),
                AppText("audit_merchant".tr, fontSize: 17, fontWeight: FontWeight.w800, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                AppText(
                  "feature_coming_soon".tr,
                  fontSize: 13.5,
                  textAlign: TextAlign.center,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.6),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}