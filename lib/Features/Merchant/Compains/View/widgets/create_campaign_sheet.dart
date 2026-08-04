import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Compains/Controllers/CampaignController.dart';
import 'package:vclub/Features/Merchant/Employee/Services/ApiErrorHnadler.dart';
import 'package:vclub/Features/Merchant/Compains/Services/CampaignApiClient.dart';

// ---------------- Option definitions ----------------

class _Option {
  final String value;
  final String labelKey;
  final IconData icon;
  const _Option(this.value, this.labelKey, this.icon);
}

const _campaignTypes = [
  _Option('promotion', 'campaign_type_promotion', Iconsax.percentage_circle),
  _Option('points_multiplier', 'campaign_type_points_multiplier', Iconsax.medal_star),
  _Option('bonus_points', 'campaign_type_bonus_points', Iconsax.gift),
  _Option('discount', 'campaign_type_discount', Iconsax.tag),
  _Option('free_reward', 'campaign_type_free_reward', Iconsax.crown),
  _Option('birthday', 'campaign_type_birthday', Iconsax.cake),
  _Option('winback', 'campaign_type_winback', Iconsax.refresh),
  _Option('event', 'campaign_type_event', Iconsax.calendar_1),
];

const _channels = [
  _Option('push', 'channel_push', Iconsax.notification),
  _Option('sms', 'channel_sms', Iconsax.message),
  _Option('whatsapp', 'channel_whatsapp', Iconsax.message_2),
  _Option('email', 'channel_email', Iconsax.sms),
];

const _audiences = [
  _Option('all', 'audience_all', Iconsax.people),
  _Option('active', 'audience_active', Iconsax.activity),
  _Option('inactive', 'audience_inactive', Iconsax.pause),
  _Option('vip', 'audience_vip', Iconsax.crown_1),
  _Option('birthday', 'audience_birthday', Iconsax.cake),
];

// ---------------- Design tokens (light / dark aware) ----------------

class _Tokens {
  final bool isDark;
  _Tokens(this.isDark);

  Color get sheetBg => isDark ? const Color(0xFF141416) : Colors.white;
  Color get cardBg => isDark ? Colors.white.withOpacity(0.045) : const Color(0xFFF7F7F9);
  Color get cardBorder => isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.055);
  Color get fieldBg => isDark ? Colors.white.withOpacity(0.05) : Colors.white;
  Color get fieldBorder => isDark ? Colors.white.withOpacity(0.10) : Colors.black.withOpacity(0.08);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF15161A);
  Color get textSecondary => isDark ? Colors.white60 : Colors.black45;
  Color get textFaint => isDark ? Colors.white38 : Colors.black26;
  Color get handle => isDark ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.14);
  Color get divider => isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.05);
  Color get chipBg => isDark ? Colors.white.withOpacity(0.045) : Colors.white;
  Color get errorBg => isDark ? const Color(0xFFFF6B6B).withOpacity(0.10) : const Color(0xFFFFEBEE);
  Color get errorBorder => isDark ? const Color(0xFFFF6B6B).withOpacity(0.35) : const Color(0xFFFFCDD2);
  Color get errorText => isDark ? const Color(0xFFFF8A8A) : const Color(0xFFD32F2F);
}

// ---------------- Entry point ----------------

Future<void> showCreateCampaignSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreateCampaignSheet(),
  );
}

class CreateCampaignSheet extends StatefulWidget {
  const CreateCampaignSheet({super.key});

  @override
  State<CreateCampaignSheet> createState() => _CreateCampaignSheetState();
}

class _CreateCampaignSheetState extends State<CreateCampaignSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();

  String? _selectedType;
  String? _selectedAudience;
  final Set<String> _selectedChannels = {};

  DateTime? _startDate;
  DateTime? _endDate;

  bool _channelsTouched = false;
  bool _typeTouched = false;
  bool _audienceTouched = false;
  bool _datesTouched = false;

  bool _isSubmitting = false;
  String? _submitError;

  static DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  bool get _channelsValid => _selectedChannels.isNotEmpty;
  bool get _typeValid => _selectedType != null;
  bool get _audienceValid => _selectedAudience != null;
  bool get _datesValid =>
      _startDate != null && _endDate != null && !_endDate!.isBefore(_startDate!);

  Future<void> _pickDate({required bool isStart}) async {
    final today = _today;
    // Start date can never be before today. End date can never be before
    // the chosen start date (or today, if no start date is set yet).
    final firstDate = isStart ? today : (_startDate ?? today);
    final rawInitial = isStart ? (_startDate ?? today) : (_endDate ?? _startDate ?? today);
    final initial = rawInitial.isBefore(firstDate) ? firstDate : rawInitial;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate,
      lastDate: DateTime(today.year + 5),
      locale: Get.locale,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light()).copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _datesTouched = true;
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) _endDate = null;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _submit() async {
    setState(() {
      _channelsTouched = true;
      _typeTouched = true;
      _audienceTouched = true;
      _datesTouched = true;
      _submitError = null;
    });

    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || !_channelsValid || !_typeValid || !_audienceValid || !_datesValid) {
      HapticFeedback.lightImpact();
      return;
    }

    setState(() => _isSubmitting = true);

    final payload = <String, dynamic>{
      'name': _nameCtrl.text.trim(),
      'type': _selectedType,
      'startDate': DateFormat('yyyy-MM-dd').format(_startDate!),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate!),
      'targetAudience': _selectedAudience,
      'channels': _selectedChannels.toList(),
    };

    if (_descCtrl.text.trim().isNotEmpty) {
      payload['description'] = _descCtrl.text.trim();
    }
    if (_valueCtrl.text.trim().isNotEmpty) {
      payload['value'] = num.tryParse(_valueCtrl.text.trim());
    }

    try {
      final campaign = await CampaignApiClient.createCampaign(payload);
      final controller = Get.find<CampaignController>();
      controller.campaigns.insert(0, campaign);
      if (mounted) {
        Get.back();
        AppSnackBar.success('campaign_created_success'.tr);
      }
    } catch (e) {
      setState(() {
        _submitError = ApiErrorHandler.extract(e);
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = _Tokens(isDark);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height * 0.92),
        decoration: BoxDecoration(
          color: t.sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.4 : 0.10),
              blurRadius: 30,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        // Bottom safe-area (home indicator on iOS / gesture bar on Android)
        // is applied inside the sheet itself, separate from the keyboard inset above.
        child: KeyboardDismissOnTap(
      child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 40,
                height: 4.5,
                decoration: BoxDecoration(
                  color: t.handle,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 14, 10),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.primary, AppColors.primary.withOpacity(0.65)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Iconsax.magicpen, color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppText(
                        'new_campaign',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: t.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting ? null : () => Get.back(),
                      icon: Icon(Iconsax.close_circle, color: t.textSecondary),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: t.divider),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionCard(
                          tokens: t,
                          children: [
                            _FieldLabel('campaign_name', tokens: t),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _nameCtrl,
                              maxLength: 80,
                              style: TextStyle(color: t.textPrimary, fontSize: 14),
                              decoration: _inputDecoration(t, hint: 'campaign_name_hint'.tr),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return 'field_required'.tr;
                                if (v.trim().length > 80) return 'max_80_chars'.tr;
                                return null;
                              },
                            ),

                            const SizedBox(height: 16),
                            _FieldLabel('campaign_type', tokens: t),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _campaignTypes.map((opt) {
                                final selected = _selectedType == opt.value;
                                return _SelectChip(
                                  label: opt.labelKey.tr,
                                  icon: opt.icon,
                                  selected: selected,
                                  tokens: t,
                                  onTap: () => setState(() {
                                    _selectedType = opt.value;
                                    _typeTouched = true;
                                  }),
                                );
                              }).toList(),
                            ),
                            if (_typeTouched && !_typeValid) _ErrorLine('select_campaign_type'.tr, tokens: t),
                          ],
                        ),

                        const SizedBox(height: 14),
                        _SectionCard(
                          tokens: t,
                          children: [
                            _FieldLabel('send_channels', tokens: t),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _channels.map((opt) {
                                final selected = _selectedChannels.contains(opt.value);
                                return _SelectChip(
                                  label: opt.labelKey.tr,
                                  icon: opt.icon,
                                  selected: selected,
                                  tokens: t,
                                  onTap: () => setState(() {
                                    _channelsTouched = true;
                                    selected ? _selectedChannels.remove(opt.value) : _selectedChannels.add(opt.value);
                                  }),
                                );
                              }).toList(),
                            ),
                            if (_channelsTouched && !_channelsValid)
                              _ErrorLine('select_at_least_one_channel'.tr, tokens: t),
                          ],
                        ),

                        const SizedBox(height: 14),
                        _SectionCard(
                          tokens: t,
                          children: [
                            _FieldLabel('value_offer_optional', tokens: t),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _valueCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))],
                              style: TextStyle(color: t.textPrimary, fontSize: 14),
                              decoration: _inputDecoration(t, hint: 'value_offer_hint'.tr),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) return null;
                                final n = num.tryParse(v.trim());
                                if (n == null) return 'invalid_number'.tr;
                                if (n < 0) return 'value_must_be_positive'.tr;
                                return null;
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        _SectionCard(
                          tokens: t,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _DateField(
                                    labelKey: 'start_date',
                                    date: _startDate,
                                    tokens: t,
                                    onTap: () => _pickDate(isStart: true),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _DateField(
                                    labelKey: 'end_date',
                                    date: _endDate,
                                    tokens: t,
                                    onTap: () => _pickDate(isStart: false),
                                  ),
                                ),
                              ],
                            ),
                            if (_datesTouched && !_datesValid)
                              _ErrorLine(
                                _startDate == null || _endDate == null
                                    ? 'select_start_end_dates'.tr
                                    : 'end_date_after_start'.tr,
                                tokens: t,
                              ),
                          ],
                        ),

                        const SizedBox(height: 14),
                        _SectionCard(
                          tokens: t,
                          children: [
                            _FieldLabel('target_audience', tokens: t),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _audiences.map((opt) {
                                final selected = _selectedAudience == opt.value;
                                return _SelectChip(
                                  label: opt.labelKey.tr,
                                  icon: opt.icon,
                                  selected: selected,
                                  tokens: t,
                                  onTap: () => setState(() {
                                    _selectedAudience = opt.value;
                                    _audienceTouched = true;
                                  }),
                                );
                              }).toList(),
                            ),
                            if (_audienceTouched && !_audienceValid)
                              _ErrorLine('select_target_audience'.tr, tokens: t),
                          ],
                        ),

                        const SizedBox(height: 14),
                        _SectionCard(
                          tokens: t,
                          children: [
                            _FieldLabel('message_description_optional', tokens: t),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _descCtrl,
                              maxLength: 300,
                              maxLines: 4,
                              style: TextStyle(color: t.textPrimary, fontSize: 14),
                              decoration: _inputDecoration(t, hint: 'message_description_hint'.tr),
                              validator: (v) {
                                if (v != null && v.trim().length > 300) return 'max_300_chars'.tr;
                                return null;
                              },
                            ),
                          ],
                        ),

                        if (_submitError != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: t.errorBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: t.errorBorder),
                            ),
                            child: Row(
                              children: [
                                Icon(Iconsax.info_circle, color: t.errorText, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _submitError!,
                                    style: TextStyle(fontSize: 12.5, color: t.errorText, fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 22),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              gradient: LinearGradient(
                                colors: [AppColors.primary, AppColors.primary.withOpacity(0.82)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withOpacity(_isSubmitting ? 0 : 0.35),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15),
                                onTap: _isSubmitting ? null : _submit,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            key: ValueKey('loading'),
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                                          )
                                        : AppText(
                                            key: const ValueKey('label'),
                                            'create_campaign',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }

  InputDecoration _inputDecoration(_Tokens t, {required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(fontSize: 13.5, color: t.textFaint),
      filled: true,
      fillColor: t.fieldBg,
      counterText: '',
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.fieldBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: t.fieldBorder)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.primary, width: 1.4)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.2)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.red, width: 1.4)),
      errorStyle: TextStyle(color: t.errorText, fontSize: 11.5, fontWeight: FontWeight.w600),
    );
  }
}

// ---------------- Building blocks ----------------

class _SectionCard extends StatelessWidget {
  final _Tokens tokens;
  final List<Widget> children;
  const _SectionCard({required this.tokens, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tokens.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: tokens.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String labelKey;
  final _Tokens tokens;
  const _FieldLabel(this.labelKey, {required this.tokens});

  @override
  Widget build(BuildContext context) => AppText(
        labelKey,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: tokens.textPrimary,
      );
}

class _ErrorLine extends StatelessWidget {
  final String text;
  final _Tokens tokens;
  const _ErrorLine(this.text, {required this.tokens});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 8, left: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.info_circle, size: 13, color: tokens.errorText),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                text,
                style: TextStyle(fontSize: 11.5, color: tokens.errorText, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _SelectChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final _Tokens tokens;
  final VoidCallback onTap;

  const _SelectChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.tokens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.14) : tokens.chipBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : tokens.fieldBorder,
            width: selected ? 1.3 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: selected ? AppColors.primary : tokens.textSecondary),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.primary : tokens.textPrimary.withOpacity(0.85),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String labelKey;
  final DateTime? date;
  final _Tokens tokens;
  final VoidCallback onTap;

  const _DateField({required this.labelKey, required this.date, required this.tokens, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel(labelKey, tokens: tokens),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
            decoration: BoxDecoration(
              color: tokens.fieldBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasDate ? AppColors.primary.withOpacity(0.45) : tokens.fieldBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(Iconsax.calendar_1, size: 16, color: hasDate ? AppColors.primary : tokens.textFaint),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasDate ? DateFormat('dd MMM yyyy', Get.locale?.languageCode).format(date!) : 'select_date'.tr,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: hasDate ? tokens.textPrimary : tokens.textFaint,
                    ),
                    overflow: TextOverflow.ellipsis,
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