import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/responsive.dart';

/// Minimal country model. Flag is derived from [iso2] at runtime (regional
/// indicator symbols), so no image/emoji assets are needed.
class Country {
  final String iso2;
  final String dialCode;
  final String nameEn;
  final String nameFr;
  final String nameAr;

  const Country({
    required this.iso2,
    required this.dialCode,
    required this.nameEn,
    required this.nameFr,
    required this.nameAr,
  });

  String get flag => String.fromCharCodes(
        iso2.toUpperCase().codeUnits.map((c) => 0x1F1E6 + (c - 65)),
      );

  String nameFor(String locale) {
    switch (locale) {
      case 'fr':
        return nameFr;
      case 'ar':
        return nameAr;
      default:
        return nameEn;
    }
  }
}

/// Feel free to extend this list — it currently covers the Maghreb / MENA
/// region plus the most common international destinations.
const List<Country> kCountries = [
  Country(iso2: 'TN', dialCode: '+216', nameEn: 'Tunisia', nameFr: 'Tunisie', nameAr: 'تونس'),
  Country(iso2: 'DZ', dialCode: '+213', nameEn: 'Algeria', nameFr: 'Algérie', nameAr: 'الجزائر'),
  Country(iso2: 'MA', dialCode: '+212', nameEn: 'Morocco', nameFr: 'Maroc', nameAr: 'المغرب'),
  Country(iso2: 'LY', dialCode: '+218', nameEn: 'Libya', nameFr: 'Libye', nameAr: 'ليبيا'),
  Country(iso2: 'EG', dialCode: '+20', nameEn: 'Egypt', nameFr: 'Égypte', nameAr: 'مصر'),
  Country(iso2: 'MR', dialCode: '+222', nameEn: 'Mauritania', nameFr: 'Mauritanie', nameAr: 'موريتانيا'),
  Country(iso2: 'SA', dialCode: '+966', nameEn: 'Saudi Arabia', nameFr: 'Arabie saoudite', nameAr: 'السعودية'),
  Country(iso2: 'AE', dialCode: '+971', nameEn: 'United Arab Emirates', nameFr: 'Émirats arabes unis', nameAr: 'الإمارات'),
  Country(iso2: 'QA', dialCode: '+974', nameEn: 'Qatar', nameFr: 'Qatar', nameAr: 'قطر'),
  Country(iso2: 'KW', dialCode: '+965', nameEn: 'Kuwait', nameFr: 'Koweït', nameAr: 'الكويت'),
  Country(iso2: 'BH', dialCode: '+973', nameEn: 'Bahrain', nameFr: 'Bahreïn', nameAr: 'البحرين'),
  Country(iso2: 'OM', dialCode: '+968', nameEn: 'Oman', nameFr: 'Oman', nameAr: 'عُمان'),
  Country(iso2: 'JO', dialCode: '+962', nameEn: 'Jordan', nameFr: 'Jordanie', nameAr: 'الأردن'),
  Country(iso2: 'LB', dialCode: '+961', nameEn: 'Lebanon', nameFr: 'Liban', nameAr: 'لبنان'),
  Country(iso2: 'IQ', dialCode: '+964', nameEn: 'Iraq', nameFr: 'Irak', nameAr: 'العراق'),
  Country(iso2: 'SY', dialCode: '+963', nameEn: 'Syria', nameFr: 'Syrie', nameAr: 'سوريا'),
  Country(iso2: 'YE', dialCode: '+967', nameEn: 'Yemen', nameFr: 'Yémen', nameAr: 'اليمن'),
  Country(iso2: 'PS', dialCode: '+970', nameEn: 'Palestine', nameFr: 'Palestine', nameAr: 'فلسطين'),
  Country(iso2: 'SD', dialCode: '+249', nameEn: 'Sudan', nameFr: 'Soudan', nameAr: 'السودان'),
  Country(iso2: 'FR', dialCode: '+33', nameEn: 'France', nameFr: 'France', nameAr: 'فرنسا'),
  Country(iso2: 'BE', dialCode: '+32', nameEn: 'Belgium', nameFr: 'Belgique', nameAr: 'بلجيكا'),
  Country(iso2: 'CH', dialCode: '+41', nameEn: 'Switzerland', nameFr: 'Suisse', nameAr: 'سويسرا'),
  Country(iso2: 'DE', dialCode: '+49', nameEn: 'Germany', nameFr: 'Allemagne', nameAr: 'ألمانيا'),
  Country(iso2: 'IT', dialCode: '+39', nameEn: 'Italy', nameFr: 'Italie', nameAr: 'إيطاليا'),
  Country(iso2: 'ES', dialCode: '+34', nameEn: 'Spain', nameFr: 'Espagne', nameAr: 'إسبانيا'),
  Country(iso2: 'GB', dialCode: '+44', nameEn: 'United Kingdom', nameFr: 'Royaume-Uni', nameAr: 'المملكة المتحدة'),
  Country(iso2: 'IE', dialCode: '+353', nameEn: 'Ireland', nameFr: 'Irlande', nameAr: 'أيرلندا'),
  Country(iso2: 'NL', dialCode: '+31', nameEn: 'Netherlands', nameFr: 'Pays-Bas', nameAr: 'هولندا'),
  Country(iso2: 'PT', dialCode: '+351', nameEn: 'Portugal', nameFr: 'Portugal', nameAr: 'البرتغال'),
  Country(iso2: 'LU', dialCode: '+352', nameEn: 'Luxembourg', nameFr: 'Luxembourg', nameAr: 'لوكسمبورغ'),
  Country(iso2: 'SE', dialCode: '+46', nameEn: 'Sweden', nameFr: 'Suède', nameAr: 'السويد'),
  Country(iso2: 'NO', dialCode: '+47', nameEn: 'Norway', nameFr: 'Norvège', nameAr: 'النرويج'),
  Country(iso2: 'DK', dialCode: '+45', nameEn: 'Denmark', nameFr: 'Danemark', nameAr: 'الدنمارك'),
  Country(iso2: 'FI', dialCode: '+358', nameEn: 'Finland', nameFr: 'Finlande', nameAr: 'فنلندا'),
  Country(iso2: 'PL', dialCode: '+48', nameEn: 'Poland', nameFr: 'Pologne', nameAr: 'بولندا'),
  Country(iso2: 'AT', dialCode: '+43', nameEn: 'Austria', nameFr: 'Autriche', nameAr: 'النمسا'),
  Country(iso2: 'GR', dialCode: '+30', nameEn: 'Greece', nameFr: 'Grèce', nameAr: 'اليونان'),
  Country(iso2: 'TR', dialCode: '+90', nameEn: 'Turkey', nameFr: 'Turquie', nameAr: 'تركيا'),
  Country(iso2: 'RU', dialCode: '+7', nameEn: 'Russia', nameFr: 'Russie', nameAr: 'روسيا'),
  Country(iso2: 'UA', dialCode: '+380', nameEn: 'Ukraine', nameFr: 'Ukraine', nameAr: 'أوكرانيا'),
  Country(iso2: 'US', dialCode: '+1', nameEn: 'United States', nameFr: 'États-Unis', nameAr: 'الولايات المتحدة'),
  Country(iso2: 'CA', dialCode: '+1', nameEn: 'Canada', nameFr: 'Canada', nameAr: 'كندا'),
  Country(iso2: 'MX', dialCode: '+52', nameEn: 'Mexico', nameFr: 'Mexique', nameAr: 'المكسيك'),
  Country(iso2: 'BR', dialCode: '+55', nameEn: 'Brazil', nameFr: 'Brésil', nameAr: 'البرازيل'),
  Country(iso2: 'AR', dialCode: '+54', nameEn: 'Argentina', nameFr: 'Argentine', nameAr: 'الأرجنتين'),
  Country(iso2: 'CN', dialCode: '+86', nameEn: 'China', nameFr: 'Chine', nameAr: 'الصين'),
  Country(iso2: 'JP', dialCode: '+81', nameEn: 'Japan', nameFr: 'Japon', nameAr: 'اليابان'),
  Country(iso2: 'KR', dialCode: '+82', nameEn: 'South Korea', nameFr: 'Corée du Sud', nameAr: 'كوريا الجنوبية'),
  Country(iso2: 'IN', dialCode: '+91', nameEn: 'India', nameFr: 'Inde', nameAr: 'الهند'),
  Country(iso2: 'PK', dialCode: '+92', nameEn: 'Pakistan', nameFr: 'Pakistan', nameAr: 'باكستان'),
  Country(iso2: 'BD', dialCode: '+880', nameEn: 'Bangladesh', nameFr: 'Bangladesh', nameAr: 'بنغلاديش'),
  Country(iso2: 'ID', dialCode: '+62', nameEn: 'Indonesia', nameFr: 'Indonésie', nameAr: 'إندونيسيا'),
  Country(iso2: 'MY', dialCode: '+60', nameEn: 'Malaysia', nameFr: 'Malaisie', nameAr: 'ماليزيا'),
  Country(iso2: 'SG', dialCode: '+65', nameEn: 'Singapore', nameFr: 'Singapour', nameAr: 'سنغافورة'),
  Country(iso2: 'PH', dialCode: '+63', nameEn: 'Philippines', nameFr: 'Philippines', nameAr: 'الفلبين'),
  Country(iso2: 'TH', dialCode: '+66', nameEn: 'Thailand', nameFr: 'Thaïlande', nameAr: 'تايلاند'),
  Country(iso2: 'VN', dialCode: '+84', nameEn: 'Vietnam', nameFr: 'Vietnam', nameAr: 'فيتنام'),
  Country(iso2: 'AU', dialCode: '+61', nameEn: 'Australia', nameFr: 'Australie', nameAr: 'أستراليا'),
  Country(iso2: 'NZ', dialCode: '+64', nameEn: 'New Zealand', nameFr: 'Nouvelle-Zélande', nameAr: 'نيوزيلندا'),
  Country(iso2: 'ZA', dialCode: '+27', nameEn: 'South Africa', nameFr: 'Afrique du Sud', nameAr: 'جنوب أفريقيا'),
  Country(iso2: 'NG', dialCode: '+234', nameEn: 'Nigeria', nameFr: 'Nigéria', nameAr: 'نيجيريا'),
  Country(iso2: 'KE', dialCode: '+254', nameEn: 'Kenya', nameFr: 'Kenya', nameAr: 'كينيا'),
  Country(iso2: 'SN', dialCode: '+221', nameEn: 'Senegal', nameFr: 'Sénégal', nameAr: 'السنغال'),
  Country(iso2: 'CI', dialCode: '+225', nameEn: "Ivory Coast", nameFr: "Côte d'Ivoire", nameAr: 'ساحل العاج'),
  Country(iso2: 'CM', dialCode: '+237', nameEn: 'Cameroon', nameFr: 'Cameroun', nameAr: 'الكاميرون'),
];

/// Premium / modern phone field with an inline country-code selector.
/// Same visual language as [AppTextField] (label above, filled rounded box,
/// dark/light aware). Fully RTL / locale aware (en, fr, ar).
///
/// [controller] always receives the full international number, e.g.
/// "+21612345678", so it stays compatible with existing String-based
/// controllers (e.g. ClientSignUpController.phoneController).
class AppPhoneField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final String defaultIso2;
  final String? errorText;
  final ValueChanged<String>? onChanged;

  const AppPhoneField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.defaultIso2 = 'TN',
    this.errorText,
    this.onChanged,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late Country _selected;
  late TextEditingController _numberController;

  @override
  void initState() {
    super.initState();
    _selected = kCountries.firstWhere(
      (c) => c.iso2 == widget.defaultIso2,
      orElse: () => kCountries.first,
    );

    final initial = widget.controller.text;
    var number = initial;
    for (final c in kCountries) {
      if (initial.startsWith(c.dialCode)) {
        _selected = c;
        number = initial.substring(c.dialCode.length);
        break;
      }
    }
    _numberController = TextEditingController(text: number);
    _numberController.addListener(_syncValue);
    // Ensure controller starts with a valid international value.
    _syncValue();
  }

  void _syncValue() {
    final full = "${_selected.dialCode}${_numberController.text}";
    widget.controller.text = full;
    widget.onChanged?.call(full);
  }

  @override
  void dispose() {
    _numberController.removeListener(_syncValue);
    _numberController.dispose();
    super.dispose();
  }

  String get _localeCode => Get.locale?.languageCode ?? 'en';

  void _openCountryPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final filtered = kCountries.where((c) {
              final q = query.toLowerCase();
              if (q.isEmpty) return true;
              return c.nameFor(_localeCode).toLowerCase().contains(q) ||
                  c.dialCode.contains(q) ||
                  c.iso2.toLowerCase().contains(q);
            }).toList();

            return  SafeArea(child:  Container(
              height: MediaQuery.of(ctx).size.height * 0.75,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1E26) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : const Color(0xFFE2E5EA),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        "select_country".tr,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (v) => setSheetState(() => query = v),
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                      ),
                      decoration: InputDecoration(
                        hintText: "search_country".tr,
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                        ),
                        prefixIcon: Icon(Icons.search,
                            color: isDark ? Colors.white38 : const Color(0xFFADB5BD)),
                        filled: true,
                        fillColor: isDark
                            ? Colors.white.withOpacity(0.06)
                            : const Color(0xFFF4F5F7),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: isDark ? Colors.white10 : const Color(0xFFE2E5EA),
                      ),
                      itemBuilder: (_, i) {
                        final c = filtered[i];
                        return ListTile(
                          leading: Text(c.flag, style: const TextStyle(fontSize: 24)),
                          title: AppText(
                            c.nameFor(_localeCode),
                            fontSize: 14,
                            color: isDark ? Colors.white : const Color(0xFF2D3142),
                          ),
                          trailing: AppText(
                            c.dialCode,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : const Color(0xFF6C757D),
                          ),
                          onTap: () {
                            setState(() {
                              _selected = c;
                              _syncValue();
                            });
                            Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ));
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = _localeCode == 'ar';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: Responsive.scaleH(context, 8)),
          child: AppText(
            widget.label,
            fontSize: Responsive.scaleW(context, 13),
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white : const Color(0xFF2D3142),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
            border: Border.all(
              color: widget.errorText != null
                  ? Colors.redAccent
                  : (isDark
                      ? Colors.white.withOpacity(0.08)
                      : const Color(0xFFE2E5EA)),
              width: 1.2,
            ),
          ),
          child: Row(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(Responsive.scaleW(context, 16)),
                onTap: () => _openCountryPicker(context),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Responsive.scaleW(context, 14),
                    vertical: Responsive.scaleH(context, 14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selected.flag, style: const TextStyle(fontSize: 20)),
                      SizedBox(width: Responsive.scaleW(context, 6)),
                      AppText(
                        _selected.dialCode,
                        fontSize: Responsive.scaleW(context, 15),
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : const Color(0xFF2D3142),
                      ),
                      SizedBox(width: Responsive.scaleW(context, 4)),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: Responsive.scaleW(context, 18),
                        color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                height: Responsive.scaleH(context, 24),
                width: 1.2,
                color: isDark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E5EA),
              ),
              Expanded(
                child: TextField(
                  controller: _numberController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textDirection: TextDirection.ltr,
                  style: TextStyle(
                    fontSize: Responsive.scaleW(context, 15),
                    color: isDark ? Colors.white : const Color(0xFF2D3142),
                    fontWeight: FontWeight.w400,
                  ),
                  decoration: InputDecoration(
                    hintText: widget.hint ?? "enter_phone".tr,
                    hintStyle: TextStyle(
                      fontSize: Responsive.scaleW(context, 13),
                      color: isDark ? Colors.white38 : const Color(0xFFADB5BD),
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: Responsive.scaleW(context, 12),
                      vertical: Responsive.scaleH(context, 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.errorText != null)
          Padding(
            padding: EdgeInsets.only(top: Responsive.scaleH(context, 6), left: 4),
            child: AppText(
              widget.errorText!,
              fontSize: 12,
              color: Colors.redAccent,
            ),
          ),
      ],
    );
  }
}