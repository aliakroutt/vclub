import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/RewardsMerchantModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Services/MerchantLoyaltyPrograms.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ProgramCreatedDialog.dart';
import 'package:vclub/Features/Merchant/Rewards/Services/MerchantRewardsService.dart';

enum LoyaltyMode { points, stamps, cashback }

class BonusRule {
  String type;
  int points; // maps to API "value"
  bool enabled;

  BonusRule({required this.type, this.points = 0, this.enabled = true});
}

class LoyaltyModeController extends GetxController {
  // ── PROGRAM NAME ──────────────────────────────
  final nameController = TextEditingController();

  // ── VIP CONFIGURATION ────────────────────────────
  final RxBool vipEnabled = false.obs; // disabled by default
  final vipThresholdController = TextEditingController();
  final reviewPointsController = TextEditingController();
  final reviewCooldownController = TextEditingController();

  void toggleVipEnabled(bool value) {
    vipEnabled.value = value;
  }

  // ── MODE ───────────────────────────────────────
  final Rx<LoyaltyMode> selectedMode = LoyaltyMode.points.obs;
  void selectMode(LoyaltyMode mode) => selectedMode.value = mode;

  // ── REWARDS (dynamic list + selection) ────────
  final RxList<RewardModel> availableRewards = <RewardModel>[].obs;
  final RxBool rewardsLoading = false.obs;
  final Rxn<RewardModel> selectedReward = Rxn<RewardModel>();

  Future<void> fetchRewardsForPicker() async {
    try {
      rewardsLoading.value = true;
      final result = await MerchantRewardsApiClient.getRewards();
      availableRewards.assignAll(result);
    } catch (_) {
      // silently fail, picker will just show empty state
    } finally {
      rewardsLoading.value = false;
    }
  }

  void selectReward(RewardModel reward) => selectedReward.value = reward;

  // ── POINTS ──────────────────────────────────────
  final pointsPerEuroController =
      TextEditingController(); // pointsPerCurrencyUnit
  final pointsPerRewardController = TextEditingController(); // pointsPerReward
  final minimumPurchaseController = TextEditingController(); // minPurchase
  final expiryMonthsController =
      TextEditingController(); // pointsExpiryDays (in days)

  // ── STAMPS ──────────────────────────────────────
  final stampsPerVisitController = TextEditingController(); // stampsPerVisit
  final stampsRequiredController = TextEditingController(); // stampsPerReward
  final rewardOfferedController =
      TextEditingController(); // stampReward (free text fallback)
  final stampsExpiryController = TextEditingController(); // stampsExpiryDays

  // ── CASHBACK ────────────────────────────────────
  final cashbackRateController = TextEditingController(); // cashbackPercent
  final cashbackMinimumController =
      TextEditingController(); // cashbackMinPurchase
  final cashbackExpiryController =
      TextEditingController(); // cashbackExpiryDays

  // ── BONUS RULES ─────────────────────────────────
  final RxList<BonusRule> bonusRules = <BonusRule>[].obs;

  void addRule(String type) => bonusRules.add(BonusRule(type: type));
  void removeRule(int i) => bonusRules.removeAt(i);
  void toggleRule(int i) {
    bonusRules[i].enabled = !bonusRules[i].enabled;
    bonusRules.refresh();
  }

  void updatePoints(int i, int value) => bonusRules[i].points = value;

  // ── LIMITS ──────────────────────────────────────
  final maxPointsPerDay = TextEditingController();
  final maxPointsPerTransaction = TextEditingController();
  final maxRewardsPerMonth = TextEditingController();
  final maxStampsPerDay = TextEditingController();

  // ── VIP LEVELS ──────────────────────────────────
  final Map<String, TextEditingController> vipNameControllers = {};
  final Map<String, TextEditingController> vipPointsControllers = {};
  final Map<String, Color> vipColors = {
    "bronze": const Color(0xFFCD7F32),
    "silver": const Color(0xFFB0BEC5),
    "gold": const Color(0xFFFFC107),
    "platinum": const Color(0xFFE5E4E2),
  };

  final List<String> vipLevelOrder = ["bronze", "silver", "gold", "platinum"];

  // ── SUBMIT STATE ────────────────────────────────
  final RxBool isSubmitting = false.obs;
  // ── VIP LEVELS (dynamic — starts empty) ──────────

  @override
  void onInit() {
    super.onInit();
    fetchRewardsForPicker();
  }
@override
void onClose() {
  for (final level in vipLevels) {
    level.dispose();
  }
  super.onClose();
}
  int _parseInt(TextEditingController c, [int fallback = 0]) =>
      int.tryParse(c.text.trim()) ?? fallback;

  double _parseDouble(TextEditingController c, [double fallback = 0]) =>
      double.tryParse(c.text.trim()) ?? fallback;

  bool validateProgram() {
    List<String> errors = [];

    // =========================
    // 1️⃣ Program Name
    // =========================
    if (nameController.text.trim().isEmpty) {
      errors.add("program_name_required".tr);
    }

    // =========================
    // 2️⃣ Mode-specific fields
    // =========================
    switch (selectedMode.value) {
      case LoyaltyMode.points:
        if (pointsPerEuroController.text.trim().isEmpty) {
          errors.add("points_per_currency_required".tr);
        }
        if (pointsPerRewardController.text.trim().isEmpty) {
          errors.add("points_per_reward_required".tr);
        }
        if (minimumPurchaseController.text.trim().isEmpty) {
          errors.add("min_purchase_required".tr);
        }
        if (expiryMonthsController.text.trim().isEmpty) {
          errors.add("points_expiry_required".tr);
        }
        break;

      case LoyaltyMode.stamps:
        if (stampsPerVisitController.text.trim().isEmpty) {
          errors.add("stamps_per_visit_required".tr);
        }
        if (stampsRequiredController.text.trim().isEmpty) {
          errors.add("stamps_per_reward_required".tr);
        }
        // if (rewardOfferedController.text.trim().isEmpty) {
        //   errors.add("stamp_reward_required".tr);
        // }
        if (stampsExpiryController.text.trim().isEmpty) {
          errors.add("stamps_expiry_required".tr);
        }
        break;

      case LoyaltyMode.cashback:
        if (cashbackRateController.text.trim().isEmpty) {
          errors.add("cashback_rate_required".tr);
        }
        if (cashbackMinimumController.text.trim().isEmpty) {
          errors.add("cashback_min_purchase_required".tr);
        }
        if (cashbackExpiryController.text.trim().isEmpty) {
          errors.add("cashback_expiry_required".tr);
        }
        break;
    }

    // =========================
    // 3️⃣ Limits & Caps (mode-specific)
    // =========================
    switch (selectedMode.value) {
      case LoyaltyMode.points:
        if (maxPointsPerDay.text.trim().isEmpty) {
          errors.add("max_points_day_required".tr);
        }
        if (maxRewardsPerMonth.text.trim().isEmpty) {
          errors.add("max_rewards_month_required".tr);
        }
        break;

      case LoyaltyMode.stamps:
        if (maxStampsPerDay.text.trim().isEmpty) {
          errors.add("max_stamps_day_required".tr);
        }
        if (maxRewardsPerMonth.text.trim().isEmpty) {
          errors.add("max_rewards_month_required".tr);
        }
        break;

      case LoyaltyMode.cashback:
        if (maxRewardsPerMonth.text.trim().isEmpty) {
          errors.add("max_rewards_month_required".tr);
        }
        break;
    }

    // =========================
    // 4️⃣ VIP Configuration (all types)
    // =========================
    if (vipEnabled.value) {
      if (vipThresholdController.text.trim().isEmpty) {
        errors.add("vip_threshold_required_or_disable".tr);
      }
      if (reviewPointsController.text.trim().isEmpty) {
        errors.add("review_points_required_or_disable".tr);
      }
      if (reviewCooldownController.text.trim().isEmpty) {
        errors.add("review_cooldown_required_or_disable".tr);
      }
    }

    // =========================
    // 5️⃣ VIP Levels (all types)
    // =========================
    if (vipEnabled.value) {
      for (final key in vipLevelOrder) {
        final nameCtrl = vipNameControllers[key];
        final pointsCtrl = vipPointsControllers[key];

        if (nameCtrl == null || nameCtrl.text.trim().isEmpty) {
          errors.add(
            "vip_level_name_required_or_disable".trParams({
              "level": "vip_$key".tr,
            }),
          );
        }
        if (pointsCtrl == null || pointsCtrl.text.trim().isEmpty) {
          errors.add(
            "vip_level_points_required_or_disable".trParams({
              "level": "vip_$key".tr,
            }),
          );
        }
      }
    }

    if (vipEnabled.value) {
      for (int i = 0; i < vipLevels.length; i++) {
        final level = vipLevels[i];
        final position = i + 1;

        if (level.nameController.text.trim().isEmpty) {
          errors.add(
            "vip_level_name_required_at".trParams({'position': '$position'}),
          );
        }
        if (level.pointsController.text.trim().isEmpty) {
          errors.add(
            "vip_level_points_required_at".trParams({'position': '$position'}),
          );
        }
      }
    }

    // =========================
    // ❌ Show errors
    // =========================
    if (errors.isNotEmpty) {
      AppSnackBar.multipleErrors(errors);
      return false;
    }

    return true;
  }

  Map<String, dynamic> _buildPayload() {
    final payload = {
      "name": nameController.text.trim(),
      "mode": selectedMode.value.name,

      "pointsPerCurrencyUnit": _parseDouble(pointsPerEuroController, 1),
      "pointsPerReward": _parseInt(pointsPerRewardController, 100),
      "pointsReward": "",
      "minPurchase": _parseDouble(minimumPurchaseController, 0),
      "pointsExpiryDays": _parseInt(expiryMonthsController, 365),

      "stampsPerVisit": _parseInt(stampsPerVisitController, 1),
      "stampsPerReward": _parseInt(stampsRequiredController, 10),
      "stampReward": rewardOfferedController.text.trim(),
      "stampsExpiryDays": _parseInt(stampsExpiryController, 180),

      "cashbackPercent": _parseDouble(cashbackRateController, 5),
      "cashbackMinPurchase": _parseDouble(cashbackMinimumController, 0),
      "cashbackExpiryDays": _parseInt(cashbackExpiryController, 365),

      // VIP fields — only populated when the merchant enabled VIP.
      "vipThreshold": vipEnabled.value
          ? _parseInt(vipThresholdController, 1000)
          : null,

      "reviewRewardPoints": vipEnabled.value
          ? _parseInt(reviewPointsController, 0)
          : null,
      "reviewRewardCooldownDays": vipEnabled.value
          ? _parseInt(reviewCooldownController, 30)
          : null,
      "reviewRewardId": null,
      "reviewTrigger": "program_end",

      "bonuses": bonusRules
          .map((r) => {"type": r.type, "value": r.points, "enabled": r.enabled})
          .toList(),

      "limits": {
        "maxPointsPerDay": _parseInt(maxPointsPerDay, 0),
        "maxPointsPerTx": _parseInt(maxPointsPerTransaction, 0),
        "maxRewardsPerMonth": _parseInt(maxRewardsPerMonth, 0),
        "maxStampsPerDay": _parseInt(maxStampsPerDay, 0),
      },

      // VIP levels — empty list entirely when VIP is disabled.
      "vipLevels": vipEnabled.value
          ? vipLevels.map((level) {
              final name = level.nameController.text.trim();
              final minPoints =
                  int.tryParse(level.pointsController.text.trim()) ?? 0;
              final hex =
                  "#${level.color.value.toRadixString(16).substring(2).toUpperCase()}";
              return {"name": name, "minPoints": minPoints, "color": hex};
            }).toList()
          : <Map<String, dynamic>>[],
    };

    final rewardId = selectedReward.value?.id;
    if (rewardId != null && rewardId.toString().trim().isNotEmpty) {
      payload["rewardId"] = rewardId;
    }

    return payload;
  }

  Future<void> submitProgram() async {
    if (!validateProgram()) return;
    final controller = MerchantProgramsController.to;
    try {
      isSubmitting.value = true;

      final payload = _buildPayload();
      final response = await MerchantLoyaltyApiClient.createProgram(payload);

      final status = response.statusCode ?? 0;
      if (status < 200 || status >= 300) {
        // Treat non-2xx as failure, even though Dio didn't throw
        final data = response.data;
        String? apiMessage;
        if (data is Map<String, dynamic>) {
          apiMessage = data["message"]?.toString() ?? data["error"]?.toString();
        } else if (data is String && data.isNotEmpty) {
          apiMessage = data;
        }
        AppSnackBar.error(apiMessage ?? "program_create_failed".tr);
        return;
      }

      await controller.fetchPrograms();

      Get.back(); // close the create-program screen
      // AppSnackBar.success("program_created_title".tr);
      ProgramCreatedDialog.show(programName: nameController.text.trim());
    } on DioException catch (e) {
      final data = e.response?.data;
      String? apiMessage;
      if (data is Map<String, dynamic>) {
        apiMessage = data["message"]?.toString() ?? data["error"]?.toString();
      } else if (data is String && data.isNotEmpty) {
        apiMessage = data;
      }
      AppSnackBar.error(apiMessage ?? "program_create_failed".tr);
    } catch (e) {
      AppSnackBar.error("program_create_failed".tr);
    } finally {
      isSubmitting.value = false;
    }
  }

  // ── ADD REWARD (inline, from picker) ────────────
  final rewardNameController = TextEditingController();
  final RxString rewardTypeSelection = "product".obs;
  final RxBool isAddingRewardFromPicker = false.obs;

  final List<Map<String, String>> rewardTypeOptions = const [
    {"value": "product", "label": "reward_type_product"},
    {"value": "discount", "label": "reward_type_discount"},
    {"value": "free_item", "label": "reward_type_free_item"},
    {"value": "drink", "label": "reward_type_drink"},
    {"value": "dessert", "label": "reward_type_dessert"},
    {"value": "points_bonus", "label": "reward_type_points_bonus"},
    {"value": "other", "label": "reward_type_other"},
  ];

  /// Creates a reward from the inline picker's add-reward sheet, refreshes
  /// the picker's reward list, and auto-selects the newly created reward.
  /// Returns true on success so the sheet knows to close.
  Future<bool> addRewardFromPicker() async {
    final name = rewardNameController.text.trim();

    if (name.isEmpty) {
      AppSnackBar.error("reward_name_required".tr);
      return false;
    }

    try {
      isAddingRewardFromPicker.value = true;

      final created = await MerchantRewardsApiClient.addReward(
        name: name,
        type: rewardTypeSelection.value,
      );

      availableRewards.insert(0, created);
      selectedReward.value = created;

      rewardNameController.clear();
      rewardTypeSelection.value = "product";

      return true;
    } catch (e) {
      AppSnackBar.error("reward_add_failed".tr);
      return false;
    } finally {
      isAddingRewardFromPicker.value = false;
    }
  }

  // ── VIP LEVELS ──────────────────────────────────
  final RxList<VipLevelEntry> vipLevels = <VipLevelEntry>[].obs;

  static const List<Color> _defaultLevelPalette = [
    Color(0xFFCD7F32), // bronze-ish
    Color(0xFFB0BEC5), // silver-ish
    Color(0xFFFFC107), // gold-ish
    Color(0xFFE5E4E2), // platinum-ish
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFEF4444),
  ];

  int _vipLevelSeq = 0;

  /// Adds a new VIP level with an editable default name ("Level N",
  /// translated) and no points set yet.
  void addVipLevel() {
    final index = vipLevels.length;
    final id = 'vip_level_${_vipLevelSeq++}';
    final defaultName = "vip_level_default_name".trParams({
      'number': '${index + 1}',
    });

    vipLevels.add(
      VipLevelEntry(
        id: id,
        nameController: TextEditingController(text: defaultName),
        pointsController: TextEditingController(),
        color: _defaultLevelPalette[index % _defaultLevelPalette.length],
      ),
    );
  }

  void removeVipLevel(String id) {
    final index = vipLevels.indexWhere((l) => l.id == id);
    if (index == -1) return;
    vipLevels[index].dispose();
    vipLevels.removeAt(index);
  }

  void setVipLevelColor(String id, Color color) {
    final level = vipLevels.firstWhereOrNull((l) => l.id == id);
    if (level == null) return;
    level.color = color;
    vipLevels.refresh();
  }

  void reset() {
    nameController.clear();
    pointsPerEuroController.clear();
    pointsPerRewardController.clear();
    minimumPurchaseController.clear();
    expiryMonthsController.clear();
    stampsPerVisitController.clear();
    stampsRequiredController.clear();
    rewardOfferedController.clear();
    stampsExpiryController.clear();
    cashbackRateController.clear();
    cashbackMinimumController.clear();
    cashbackExpiryController.clear();
    maxPointsPerDay.clear();
    maxPointsPerTransaction.clear();
    maxRewardsPerMonth.clear();
    maxStampsPerDay.clear();
    vipEnabled.value = false;
    vipThresholdController.clear();
    reviewPointsController.clear();
    reviewCooldownController.clear();
    rewardNameController.clear();

    for (final level in vipLevels) {
      level.dispose();
    }
    vipLevels.clear();
  }
}

class VipLevelEntry {
  final String id;
  final TextEditingController nameController;
  final TextEditingController pointsController;
  Color color;

  VipLevelEntry({
    required this.id,
    required this.nameController,
    required this.pointsController,
    required this.color,
  });

  void dispose() {
    nameController.dispose();
    pointsController.dispose();
  }
}
