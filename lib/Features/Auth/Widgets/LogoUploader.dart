import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class LogoUploader extends StatelessWidget {
  final Rxn<File> logoFile;
  final VoidCallback onPick;

  const LogoUploader({
    super.key,
    required this.logoFile,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = AppColors.primary;

    return Obx(() {
      final file = logoFile.value;

      return Align(
        alignment: Alignment.centerLeft,
        child:  GestureDetector(
        onTap: onPick,
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),

              color: isDark
                  ? const Color(0xFF151515)
                  : Colors.grey.shade50,

              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.grey.shade300,
              ),

              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.35)
                      : primary.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: file == null
                  ? _buildEmptyState(context, size, isDark, primary)
                  : _buildImageState(context, file, isDark, primary),
            ),
          ),
        ),
      ));
    });
  }

  /// ================= EMPTY STATE =================
  Widget _buildEmptyState(
    BuildContext context,
    Size size,
    bool isDark,
    Color primary,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: primary.withOpacity(isDark ? 0.12 : 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Iconsax.gallery_add,
            size: size.width * 0.09,
            color: primary,
          ),
        ),

        const SizedBox(height: 16),

        Text(
          "upload_logo".tr,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          "logo_formats".tr,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: isDark
                ? Colors.grey.shade400
                : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  /// ================= IMAGE STATE =================
  Widget _buildImageState(
    BuildContext context,
    File file,
    bool isDark,
    Color primary,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.file(
          file,
          fit: BoxFit.cover,
        ),

        /// DARK OVERLAY (adaptive)
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.center,
              colors: [
                Colors.black.withOpacity(isDark ? 0.55 : 0.45),
                Colors.transparent,
              ],
            ),
          ),
        ),

        /// DELETE BUTTON
        Positioned(
          top: 12,
          right: 12,
          child: GestureDetector(
            onTap: () => logoFile.value = null,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Iconsax.trash,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),

        /// CHANGE BUTTON
        Positioned(
          left: 12,
          bottom: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.55),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.edit,
                  size: 14,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  "change".tr,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}