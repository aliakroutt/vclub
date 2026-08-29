import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/FortuneWheel/Controllers/FortuneWheelController.dart';

class CompanySelectorRow extends StatelessWidget {
  const CompanySelectorRow({super.key});

  ImageProvider? _decodeLogo(String? logo) {
    if (logo == null || logo.isEmpty) return null;
    try {
      final b64 = logo.contains(',') ? logo.split(',').last : logo;
      return MemoryImage(base64Decode(b64));
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FortuneWheelController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final selectedId = controller.selectedCompany.value?.companyId;
      debugPrint("🔄 CompanySelectorRow REBUILT — selectedId=$selectedId, companies=${controller.companies.length}");

      if (controller.companies.isEmpty) return const SizedBox.shrink();

      return SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: controller.companies.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final company = controller.companies[index];
            final selected = company.companyId == selectedId;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                debugPrint("👆 TAPPED company: id=${company.companyId} name=${company.companyName}");
                controller.selectCompany(company);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    height: 58,
                    width: 58,
                    padding: const EdgeInsets.all(2.6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: selected
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.primary.withOpacity(.5)],
                            )
                          : null,
                      border: !selected
                          ? Border.all(color: isDark ? Colors.white.withOpacity(.12) : Colors.black.withOpacity(.08), width: 1.4)
                          : null,
                      boxShadow: selected
                          ? [BoxShadow(color: AppColors.primary.withOpacity(.35), blurRadius: 14, offset: const Offset(0, 6))]
                          : [],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF1C1F26) : Colors.white,
                        gradient: _decodeLogo(company.companyLogo) == null
                            ? LinearGradient(colors: [AppColors.primary.withOpacity(.18), AppColors.primary.withOpacity(.05)])
                            : null,
                        image: _decodeLogo(company.companyLogo) != null
                            ? DecorationImage(image: _decodeLogo(company.companyLogo)!, fit: BoxFit.cover)
                            : null,
                      ),
                      child: _decodeLogo(company.companyLogo) == null
                          ? Center(
                              child: AppText(
                                company.companyName.isNotEmpty ? company.companyName[0].toUpperCase() : "?",
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 66,
                    child: AppText(
                      company.companyName,
                      fontSize: 10.5,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      color: selected ? AppColors.primary : Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.7),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }
}