import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'dart:ui';

import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/ClientsProgramController.dart';

class HeaderSection extends GetView<ProgramClientsController> {
  const HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final double pad    = size.width * .042;
    final double radius = size.width * .056;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end:   Alignment.bottomRight,
              colors: isDark
                  ? [
                      const Color(0xFF1E2233).withOpacity(.90),
                      const Color(0xFF141726).withOpacity(.95),
                    ]
                  : [
                      Colors.white.withOpacity(.96),
                      Colors.white.withOpacity(.90),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.08)
                  : Colors.white.withOpacity(.80),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(isDark ? .35 : .07),
                blurRadius: 30,
                spreadRadius: -6,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color:      AppColors.primary.withOpacity(.06),
                blurRadius: 24,
                spreadRadius: -8,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon badge
              _IconBadge(size: size, isDark: isDark),

              SizedBox(width: size.width * .034),

              // Texts
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => AppText(
                      controller.programName.value,
                      fontSize:   size.width * .046,
                      fontWeight: FontWeight.w800,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      color: isDark ? Colors.white : const Color(0xFF1A1D29),
                    )),
                    SizedBox(height: size.height * .004),
                    Obx(() => AppText(
                      "program_clients_subtitle".trParams({
                        "count": controller.totalClients.value.toString(),
                      }),
                      fontSize:   size.width * .032,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? Colors.white.withOpacity(.45)
                          : const Color(0xFF6B7280),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Icon badge ───────────────────────────────────────────────────────────────
class _IconBadge extends StatelessWidget {
  final Size size;
  final bool isDark;
  const _IconBadge({required this.size, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final dim = size.width * .118;
    return Container(
      width:  dim,
      height: dim,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(dim * .34),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(.18),
            AppColors.primary.withOpacity(.08),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withOpacity(.22),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color:      AppColors.primary.withOpacity(.16),
            blurRadius: 16,
            spreadRadius: -4,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Icon(
        Iconsax.people,
        color: AppColors.primary,
        size:  dim * .46,
      ),
    );
  }
}