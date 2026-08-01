// fortune_controller.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Controllers/FortuneWheelHomeController.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/FortuneSegmentModel.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/UpdateWheelConfigDto.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/WheelSegmentDto.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Services/FortuneWheelApiClient.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/Widgets/PlageHoraire.dart';

// ── Segment Model ─────────────────────────────────────────────────────────────

class FortuneSegment {
  final TextEditingController nameController;
  final TextEditingController percentController;
  final TextEditingController maxWinnersController;
  final TextEditingController discountController;
  final TextEditingController pointsController;
  final TextEditingController cashbackController;

  FortuneSegment({
    String name = '',
    String percent = '',
    String maxWinners = '',
    String discount = '',
    String points = '',
    String cashback = '',
    Color color = const Color(0xFF3B6D11),
    String type = 'gift',
  }) : nameController = TextEditingController(text: name),
       percentController = TextEditingController(text: percent),
       maxWinnersController = TextEditingController(text: maxWinners),
       discountController = TextEditingController(text: discount),
       pointsController = TextEditingController(text: points),
       cashbackController = TextEditingController(text: cashback),
       _color = color,
       _type = type;

  Color _color;
  Color get color => _color;
  set color(Color v) => _color = v;

  String _type;
  String get type => _type;
  set type(String v) => _type = v;

  bool get hasMaxWinners => _type != 'no_win';

  void dispose() {
    nameController.dispose();
    percentController.dispose();
    maxWinnersController.dispose();
    discountController.dispose();
    pointsController.dispose();
    cashbackController.dispose();
  }
}

// ── Controller ────────────────────────────────────────────────────────────────

class FortuneController extends GetxController {
   final bool isEdit;

  FortuneController({this.isEdit = false});

  @override
  void onInit() {
    super.onInit();
    if (isEdit) {
      _populateFromExistingConfig();
    }
  }

  // Reverse maps (API enum → internal UI value)
  static const _typeMapReverse = {
    'gift': 'gift',
    'discount': 'discount',
    'points': 'bonus_points',
    'cashback': 'cashback',
    'no_win': 'no_win',
  };

  static const _triggerMapReverse = {
    'purchase': 'purchase',
    'google_review': 'google_review',
    'inscription': 'registration',
    'event': 'special_event',
  };

  void _populateFromExistingConfig() {
    FortuneWheelConfigModel? existing;
    try {
      existing = FortuneWheelHomeController.to.config.value;
    } catch (_) {
      existing = null; // home controller not registered yet — nothing to prefill
    }

    if (existing == null) return;

    // ── Active toggle ──────────────────────────────────────────────────
    isWheelActive.value = existing.active;

    // ── Segments ──────────────────────────────────────────────────────
    for (final s in segments) {
      s.dispose();
    }
    segments.clear();

    for (final apiSeg in existing.segments) {
      final uiType = _typeMapReverse[apiSeg.type] ?? 'gift';

      final seg = FortuneSegment(
        name: apiSeg.label,
        percent: apiSeg.probability.toString(),
        maxWinners: apiSeg.maxWinnersPerDay.toString(),
        discount: uiType == 'discount' ? apiSeg.value : '',
        points: uiType == 'bonus_points' ? apiSeg.value : '',
        cashback: uiType == 'cashback' ? apiSeg.value : '',
        color: apiSeg.color,
        type: uiType,
      );
      segments.add(seg);
    }

    // ── Triggers ──────────────────────────────────────────────────────
    _selectedTriggers.clear();
    for (final apiTrigger in existing.triggers) {
      final uiTrigger = _triggerMapReverse[apiTrigger];
      if (uiTrigger != null) _selectedTriggers.add(uiTrigger);
    }

    // ── Participation limits ────────────────────────────────────────────
    maxPerDayController.text =
        existing.maxPerDay > 0 ? existing.maxPerDay.toString() : '';
    maxPerWeekController.text =
        existing.maxPerWeek > 0 ? existing.maxPerWeek.toString() : '';

    // ── Game time slot ─────────────────────────────────────────────────
    gameTimeEnabled.value = existing.activeHoursEnabled;
    if (existing.activeHoursEnabled) {
      startTime.value = existing.activeHoursStart;
      endTime.value = existing.activeHoursEnd;
    }
  }
  final isWheelActive = true.obs;

  void toggleWheelActive() => isWheelActive.value = !isWheelActive.value;
  static const int maxSegments = 8;
  final maxPerDayController = TextEditingController();
  final maxPerWeekController = TextEditingController();
  // Add these members to your FortuneController class
  // (alongside the existing selectedTriggers state)

  // ─── Game Time Slot ────────────────────────────────────────────────────────

  final gameTimeEnabled = false.obs;
  final startTime = "".obs;
  final endTime = "".obs;

  void toggleGameTime() => gameTimeEnabled.value = !gameTimeEnabled.value;

  Future<void> pickStartTime() async {
    final context = Get.context;
    if (context == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showPremiumTimePicker(
      context,
      isDark: isDark,
      initialValue: startTime.value,
    );

    if (result != null) startTime.value = result;
  }

  Future<void> pickEndTime() async {
    final context = Get.context;
    if (context == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showPremiumTimePicker(
      context,
      isDark: isDark,
      initialValue: endTime.value,
    );

    if (result != null) endTime.value = result;
  }

  final segments = <FortuneSegment>[].obs;

  // Palette of distinct colors for auto-assignment
  final List<Color> _palette = const [
    Color(0xFF3B6D11),
    Color(0xFFE07B2E),
    Color(0xFF2E6BE0),
    Color(0xFFB02EE0),
    Color(0xFFE02E6B),
    Color(0xFF2EB0E0),
    Color(0xFFE0C82E),
    Color(0xFF2EE0A0),
  ];

  bool get canAdd => segments.length < maxSegments;

  void addSegment() {
    if (!canAdd) return;
    final idx = segments.length;
    segments.add(
      FortuneSegment(color: _palette[idx % _palette.length], type: 'gift'),
    );
  }

  void removeSegment(int index) {
    if (index < 0 || index >= segments.length) return;
    segments[index].dispose();
    segments.removeAt(index);
  }

  void updateSegmentColor(int index, Color color) {
    segments[index].color = color;
    segments.refresh();
  }

  void updateSegmentType(int index, String type) {
    segments[index].type = type;
    segments.refresh();
  }

  void updateSegmentPercent(int index, String value) {
    // No need to set controller text, just refresh for preview
    segments.refresh();
  }

  void updateMaxWinners(int index, String value) {
    segments.refresh();
  }

  @override
  void onClose() {
    for (final s in segments) {
      s.dispose();
    }
    super.onClose();
  }

  // ── State ──────────────────────────────────────────────────────────────────

  /// Set of currently selected trigger IDs.
  final _selectedTriggers = <String>{}.obs;

  // ── Getters ────────────────────────────────────────────────────────────────

  /// Returns the reactive set so the card's Obx() can rebuild on changes.
  RxSet<String> get selectedTriggers => _selectedTriggers;

  /// True if at least one trigger is selected.
  bool get hasTriggers => _selectedTriggers.isNotEmpty;

  /// Number of selected triggers.
  int get selectedCount => _selectedTriggers.length;

  // ── Actions ────────────────────────────────────────────────────────────────

  /// Adds the trigger if absent, removes it if already selected.
  void toggleTrigger(String id) {
    if (_selectedTriggers.contains(id)) {
      _selectedTriggers.remove(id);
    } else {
      _selectedTriggers.add(id);
    }
  }

  /// Selects a trigger without toggling (idempotent).
  void selectTrigger(String id) => _selectedTriggers.add(id);

  /// Deselects a trigger without toggling (idempotent).
  void deselectTrigger(String id) => _selectedTriggers.remove(id);

  /// Selects every available trigger.
  void selectAll(List<String> allIds) => _selectedTriggers.addAll(allIds);

  /// Clears all selected triggers.
  void clearAll() => _selectedTriggers.clear();

  // ── Serialisation helpers ──────────────────────────────────────────────────

  /// Returns the selected trigger IDs as a plain list, ready for an API call.
  List<String> toIdList() => _selectedTriggers.toList();

  /// Restores selected triggers from a saved list (e.g. from a backend response).
  void fromIdList(List<String> ids) {
    _selectedTriggers
      ..clear()
      ..addAll(ids);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ── VALIDATION ──────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────

  List<ValidationIssue> validate() {
    final issues = <ValidationIssue>[];

    // ── Segments ──────────────────────────────────────────────────────────
    if (segments.isEmpty) {
      issues.add(
        const ValidationIssue(
          'add_at_least_one_segment',
          icon: Iconsax.candle_2,
        ),
      );
    } else {
      double totalPercent = 0;
      bool allPercentsValid = true;

      for (int i = 0; i < segments.length; i++) {
        final seg = segments[i];
        final name = seg.nameController.text.trim();
        final percentText = seg.percentController.text.trim();
        final percent = double.tryParse(percentText);

        if (name.isEmpty) {
          issues.add(
            ValidationIssue(
              'segment_name_required',
              params: {'index': '${i + 1}'},
              icon: Iconsax.edit_2,
            ),
          );
        }

        if (percentText.isEmpty || percent == null) {
          issues.add(
            ValidationIssue(
              'segment_percent_required',
              params: {'index': '${i + 1}'},
              icon: Iconsax.percentage_circle,
            ),
          );
          allPercentsValid = false;
        } else {
          totalPercent += percent;
        }
      }

      // Only check the 100% total once every segment has a valid percent —
      // otherwise this error would be noise on top of the missing-field errors.
      if (allPercentsValid && (totalPercent - 100).abs() > 0.01) {
        issues.add(
          ValidationIssue(
            'segment_total_percent',
            params: {'total': _formatPercent(totalPercent)},
            icon: Iconsax.chart_2,
          ),
        );
      }
    }

    // ── Game time slot ────────────────────────────────────────────────────
    if (gameTimeEnabled.value) {
      if (startTime.value.isEmpty || endTime.value.isEmpty) {
        issues.add(
          const ValidationIssue('game_time_required', icon: Iconsax.timer_1),
        );
      }
    }

    return issues;
  }

  bool get isFormValid => validate().isEmpty;

  String _formatPercent(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  // ─────────────────────────────────────────────────────────────────────────
  // ── SUBMIT ──────────────────────────────────────────────────────────────
  // ─────────────────────────────────────────────────────────────────────────

  final isSubmitting = false.obs;
  String _extractApiErrorMessage(Object e) {
    if (e is DioException) {
      final data = e.response?.data;

      if (data is Map<String, dynamic>) {
        final msg = data['message'] ?? data['error'] ?? data['errors'];
        if (msg is String && msg.trim().isNotEmpty) return msg;
        if (msg is List && msg.isNotEmpty) return msg.first.toString();
      }

      if (e.response?.statusMessage != null &&
          e.response!.statusMessage!.trim().isNotEmpty) {
        return e.response!.statusMessage!;
      }

      return e.message ?? 'wheel_config_save_failed'.tr;
    }

    return 'wheel_config_save_failed'.tr;
  }

  // Internal segment-type → API enum
  static const _typeMap = {
    'gift': 'gift',
    'discount': 'discount',
    'bonus_points': 'points',
    'cashback': 'cashback',
    'no_win': 'no_win',
  };

  // Internal trigger id → API enum
  static const _triggerMap = {
    'purchase': 'purchase',
    'google_review': 'google_review',
    'registration': 'inscription',
    'special_event': 'event',
  };

  String _colorToHex(Color c) =>
      '#${c.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

  String _segmentValue(FortuneSegment seg) {
    switch (seg.type) {
      case 'discount':
        return seg.discountController.text.trim();
      case 'bonus_points':
        return seg.pointsController.text.trim();
      case 'cashback':
        return seg.cashbackController.text.trim();
      default:
        return '';
    }
  }

  UpdateWheelConfigDto buildPayload() {
    final segmentDtos = segments.map((seg) {
      final probability =
          double.tryParse(seg.percentController.text.trim()) ?? 0;
      final maxWinners = seg.hasMaxWinners
          ? int.tryParse(seg.maxWinnersController.text.trim()) ?? 0
          : 0;

      return WheelSegmentDto(
        label: seg.nameController.text.trim(),
        type: _typeMap[seg.type] ?? 'gift',
        value: _segmentValue(seg),
        probability: probability,
        color: _colorToHex(seg.color),
        maxWinnersPerDay: maxWinners,
      );
    }).toList();

    final triggerList = _selectedTriggers
        .map((id) => _triggerMap[id])
        .whereType<String>()
        .toList();

    return UpdateWheelConfigDto(
      active: isWheelActive.value,
      segments: segmentDtos,
      triggers: triggerList,
      maxPerDay: int.tryParse(maxPerDayController.text.trim()) ?? 0,
      maxPerWeek: int.tryParse(maxPerWeekController.text.trim()) ?? 0,
      activeHoursEnabled: gameTimeEnabled.value,
      activeHoursStart: gameTimeEnabled.value ? startTime.value : null,
      activeHoursEnd: gameTimeEnabled.value ? endTime.value : null,
    );
  }

  /// Returns true on success, false on failure (and shows a snackbar either way).
  Future<bool> submit() async {
    if (isSubmitting.value) return false;

    isSubmitting.value = true;
    try {
      final payload = buildPayload();
      await FortuneWheelApiClient.updateWheelConfig(payload);

      final homeController = Get.put(FortuneWheelHomeController());
      await homeController.fetchWheelConfig();
      Get.back();
      AppSnackBar.success('wheel_config_saved'.tr);
      return true;
    } catch (e) {
      AppSnackBar.error(_extractApiErrorMessage(e));
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}

class ValidationIssue {
  final String messageKey;
  final Map<String, String>? params;
  final IconData icon;

  const ValidationIssue(
    this.messageKey, {
    this.params,
    this.icon = Iconsax.info_circle,
  });

  String get message =>
      params != null ? messageKey.trParams(params!) : messageKey.tr;
}
