import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class CountryDialCode {
  final String name;
  final String iso2;
  final String dialCode;
  const CountryDialCode({required this.name, required this.iso2, required this.dialCode});

  /// Flag emoji computed from the ISO-3166 alpha-2 code — no image assets
  /// or packages needed.
  String get flag {
    const base = 0x1F1E6;
    final chars = iso2.toUpperCase().codeUnits.map((c) => base + (c - 'A'.codeUnitAt(0)));
    return String.fromCharCodes(chars);
  }
}

/// Common countries, Tunisia first since it's the app's primary market.
/// Extend freely — this list is intentionally not exhaustive.
const List<CountryDialCode> kCountries = [
  CountryDialCode(name: 'Tunisia', iso2: 'TN', dialCode: '216'),
  CountryDialCode(name: 'Algeria', iso2: 'DZ', dialCode: '213'),
  CountryDialCode(name: 'Morocco', iso2: 'MA', dialCode: '212'),
  CountryDialCode(name: 'Libya', iso2: 'LY', dialCode: '218'),
  CountryDialCode(name: 'Egypt', iso2: 'EG', dialCode: '20'),
  CountryDialCode(name: 'France', iso2: 'FR', dialCode: '33'),
  CountryDialCode(name: 'Belgium', iso2: 'BE', dialCode: '32'),
  CountryDialCode(name: 'Switzerland', iso2: 'CH', dialCode: '41'),
  CountryDialCode(name: 'Germany', iso2: 'DE', dialCode: '49'),
  CountryDialCode(name: 'Italy', iso2: 'IT', dialCode: '39'),
  CountryDialCode(name: 'Spain', iso2: 'ES', dialCode: '34'),
  CountryDialCode(name: 'Netherlands', iso2: 'NL', dialCode: '31'),
  CountryDialCode(name: 'United Kingdom', iso2: 'GB', dialCode: '44'),
  CountryDialCode(name: 'Saudi Arabia', iso2: 'SA', dialCode: '966'),
  CountryDialCode(name: 'United Arab Emirates', iso2: 'AE', dialCode: '971'),
  CountryDialCode(name: 'Qatar', iso2: 'QA', dialCode: '974'),
  CountryDialCode(name: 'Kuwait', iso2: 'KW', dialCode: '965'),
  CountryDialCode(name: 'Turkey', iso2: 'TR', dialCode: '90'),
  CountryDialCode(name: 'United States', iso2: 'US', dialCode: '1'),
  CountryDialCode(name: 'Canada', iso2: 'CA', dialCode: '1'),
];

/// Modern phone field: flag + dial-code pill on one side, free-typed
/// national number on the other. Tapping the pill opens a searchable
/// bottom sheet of countries. Emits the full E.164-ish string
/// ("+216XXXXXXXX") through [onChanged]. Styled to match the elevated
/// card language used by the rest of the edit-profile form (layered
/// shadow, icon chip, focus glow) instead of a flat filled box.
class AppPhoneField extends StatefulWidget {
  final String label;
  final String? initialPhone;
  final ValueChanged<String> onChanged;

  const AppPhoneField({
    super.key,
    required this.label,
    this.initialPhone,
    required this.onChanged,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField> {
  late CountryDialCode _country;
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _country = kCountries.first;
    String number = widget.initialPhone ?? '';
    if (number.startsWith('+')) {
      final matches = kCountries.where((c) => number.startsWith('+${c.dialCode}')).toList();
      if (matches.isNotEmpty) {
        _country = matches.reduce((a, b) => a.dialCode.length >= b.dialCode.length ? a : b);
        number = number.substring(_country.dialCode.length + 1);
      }
    }
    _controller = TextEditingController(text: number);
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _emit() => widget.onChanged('+${_country.dialCode}${_controller.text.trim()}');

  void _openCountryPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String query = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filtered = kCountries
              .where((c) => c.name.toLowerCase().contains(query.toLowerCase()) || c.dialCode.contains(query))
              .toList();
          return DraggableScrollableSheet(
            initialChildSize: 0.72,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) => ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4.5,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white24 : Colors.black12,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: TextField(
                        onChanged: (v) => setSheetState(() => query = v),
                        decoration: InputDecoration(
                          hintText: 'search_country'.tr,
                          prefixIcon: const Icon(Iconsax.search_normal_1_copy, size: 18),
                          filled: true,
                          fillColor: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final c = filtered[i];
                          final selected = c.dialCode == _country.dialCode && c.iso2 == _country.iso2;
                          return ListTile(
                            leading: AppText(c.flag, fontSize: 22),
                            title: AppText(c.name, fontSize: 14, fontWeight: FontWeight.w600),
                            trailing: selected
                                ? Icon(Iconsax.tick_circle_copy, size: 18, color: AppColors.primary)
                                : AppText('+${c.dialCode}', fontSize: 13, color: Colors.grey),
                            onTap: () {
                              setState(() => _country = c);
                              _emit();
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        border: Border.all(
          color: _focused
              ? AppColors.primary
              : (isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          width: _focused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _focused
                ? AppColors.primary.withOpacity(0.16)
                : Colors.black.withOpacity(isDark ? 0.18 : 0.045),
            blurRadius: _focused ? 18 : 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
            onTap: _openCountryPicker,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(11, 14, 10, 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      // color: AppColors.primary.withOpacity(_focused ? 0.18 : 0.1),
                    ),
                    child: AppText(_country.flag, fontSize: 15),
                  ),
                  const SizedBox(width: 4),
                  AppText('+${_country.dialCode}', fontSize: 14, fontWeight: FontWeight.w700),
                  const SizedBox(width: 4),
                  Icon(Iconsax.arrow_down_1_copy, size: 12, color: Colors.grey),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 26, color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.06)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.phone,
                onChanged: (_) => _emit(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  hintText: widget.label,
                  hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6), fontWeight: FontWeight.w500, fontSize: 13.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}