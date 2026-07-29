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
  final vipThresholdController = TextEditingController(); // already existed
  final reviewPointsController = TextEditingController(); // reviewRewardPoints
  final reviewCooldownController =
      TextEditingController(); // reviewRewardCooldownDays

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

  @override
  void onInit() {
    super.onInit();
    fetchRewardsForPicker();

    // Sensible defaults matching your sample payload
    if (bonusRules.isEmpty) {
      bonusRules.addAll([
        BonusRule(type: "birthday", points: 100, enabled: true),
        BonusRule(type: "first_purchase", points: 200, enabled: true),
        BonusRule(type: "multiplier", points: 2, enabled: false),
      ]);
    }
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
    if (vipThresholdController.text.trim().isEmpty) {
      errors.add("vip_threshold_required".tr);
    }
    if (reviewPointsController.text.trim().isEmpty) {
      errors.add("review_points_required".tr);
    }
    if (reviewCooldownController.text.trim().isEmpty) {
      errors.add("review_cooldown_required".tr);
    }

    // =========================
    // 5️⃣ VIP Levels (all types)
    // =========================
    for (final key in vipLevelOrder) {
      final nameCtrl = vipNameControllers[key];
      final pointsCtrl = vipPointsControllers[key];

      if (nameCtrl == null || nameCtrl.text.trim().isEmpty) {
        errors.add(
          "vip_level_name_required".trParams({"level": "vip_$key".tr}),
        );
      }
      if (pointsCtrl == null || pointsCtrl.text.trim().isEmpty) {
        errors.add(
          "vip_level_points_required".trParams({"level": "vip_$key".tr}),
        );
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
      "mode": selectedMode.value.name, // "points" | "stamps" | "cashback"

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

      "vipThreshold": _parseInt(vipThresholdController, 1000),

      "reviewRewardPoints": _parseInt(reviewPointsController, 0),
      "reviewRewardCooldownDays": _parseInt(reviewCooldownController, 30),
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

      "vipLevels": vipLevelOrder.map((key) {
        final name = vipNameControllers[key]?.text.trim() ?? key;
        final minPoints = _parseInt(
          vipPointsControllers[key] ?? TextEditingController(),
          0,
        );
        final color = vipColors[key];
        final hex = color != null
            ? "#${color.value.toRadixString(16).substring(2).toUpperCase()}"
            : "#CCCCCC";
        return {"name": name, "minPoints": minPoints, "color": hex};
      }).toList(),
    };

    // Only include rewardId if a reward was actually selected
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
    vipThresholdController.clear();
    reviewPointsController.clear();
    reviewCooldownController.clear();
    for (final c in vipNameControllers.values) c.clear();
    for (final c in vipPointsControllers.values) c.clear();
  }
}
