// fortune_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  })  : nameController = TextEditingController(text: name),
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
    segments.add(FortuneSegment(
      color: _palette[idx % _palette.length],
      type: 'gift',
    ));
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
  void selectAll(List<String> allIds) =>
      _selectedTriggers.addAll(allIds);
 
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
}