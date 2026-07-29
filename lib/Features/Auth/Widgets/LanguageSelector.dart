import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Translations/language_service.dart';


class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final langService = Get.find<LanguageService>();

    final currentLangCode =
        Get.locale?.languageCode ?? "fr";

    final currentLang = AppLanguages.languages.firstWhere(
      (e) => e.code == currentLangCode,
    );

    return PopupMenuButton<String>(
      onSelected: langService.changeLanguage,

      offset: const Offset(0, 45),

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),

      color: Theme.of(context).scaffoldBackgroundColor,

      elevation: 10,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentLang.flag,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: AppColors.primary,
              size: 18,
            ),
          ],
        ),
      ),

      itemBuilder: (context) {
        return AppLanguages.languages.map((lang) {
          final isSelected = lang.code == currentLangCode;

          return PopupMenuItem(
            value: lang.code,
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary)
              ),
              child: Row(
                children: [
                  Text(
                    lang.flag,
                    style: const TextStyle(fontSize: 18),
                  ),

                  const SizedBox(width: 12),

                  Text(
                    lang.label,
                    style: TextStyle(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : null,
                    ),
                  ),

                  const Spacer(),

                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }
}



class LanguageModel {
  final String code;
  final String label;
  final String flag;

  final Locale locale;

  const LanguageModel({
    required this.code,
    required this.label,
    required this.flag,
    required this.locale,
  });
}



class AppLanguages {
  static const languages = [
    LanguageModel(
      code: "fr",
      label: "Français",
      flag: "🇫🇷",
      locale: Locale("fr", "FR"),
    ),
    LanguageModel(
      code: "en",
      label: "English",
      flag: "🇺🇸",
      locale: Locale("en", "US"),
    ),
    LanguageModel(
      code: "ar",
      label: "العربية",
      flag: "🇸🇦",
      locale: Locale("ar", "AR"),
    ),
  ];
}