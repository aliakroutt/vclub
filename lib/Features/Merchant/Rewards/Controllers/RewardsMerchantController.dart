import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Dashboard/Models/RewardsMerchantModel.dart';
import 'package:vclub/Features/Merchant/Rewards/Services/MerchantRewardsService.dart';

class RewardsMerchantController extends GetxController {
  final RxList<RewardModel> rewards = <RewardModel>[].obs;
  final RxBool rewardsLoading = false.obs;
  final RxString rewardsError = "".obs;
  final RxBool initialLoaded = false.obs;

  final RxBool isAddingReward = false.obs;
  final RxBool isValidatingCode = false.obs;
  final RxString deletingRewardId = "".obs;

  final TextEditingController codeController = TextEditingController();
  final TextEditingController newRewardNameController = TextEditingController();
  final RxString newRewardType = "product".obs;

  final List<Map<String, String>> rewardTypes = const [
    {"value": "product", "label": "reward_type_product"},
    {"value": "discount", "label": "reward_type_discount"},
    {"value": "free_item", "label": "reward_type_free_item"},
    {"value": "drink", "label": "reward_type_drink"},
    {"value": "dessert", "label": "reward_type_dessert"},
    {"value": "points_bonus", "label": "reward_type_points_bonus"},
    {"value": "other", "label": "reward_type_other"},
  ];

  @override
  void onInit() {
    super.onInit();
    fetchRewards();
  }

  Future<void> fetchRewards() async {
    try {
      if (!initialLoaded.value) rewardsLoading.value = true;
      rewardsError.value = "";

      final result = await MerchantRewardsApiClient.getRewards();
      rewards.assignAll(result);
    } catch (e) {
      rewardsError.value = "failed_load_rewards".tr;
    } finally {
      rewardsLoading.value = false;
      initialLoaded.value = true;
    }
  }

  Future<void> submitNewReward() async {
    final name = newRewardNameController.text.trim();

    if (name.isEmpty) {
      AppSnackBar.error("reward_name_required".tr);
      return;
    }

    try {
      isAddingReward.value = true;

      final created = await MerchantRewardsApiClient.addReward(
        name: name,
        type: newRewardType.value,
      );

      rewards.insert(0, created);

      newRewardNameController.clear();
      newRewardType.value = "product";

      Get.back(); // close bottom sheet
      AppSnackBar.success("reward_added_success".tr);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "reward_add_failed".tr);
    } catch (e) {
      AppSnackBar.error("reward_add_failed".tr);
    } finally {
      isAddingReward.value = false;
    }
  }

  Future<void> deleteReward(RewardModel reward) async {
    if (reward.id == null) return;

    try {
      deletingRewardId.value = reward.id;
      await MerchantRewardsApiClient.deleteReward(reward.id);
      rewards.removeWhere((r) => r.id == reward.id);
      AppSnackBar.success("reward_deleted_success".tr);
    } on DioException catch (e) {
      final data = e.response?.data;
      final message =
          (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "reward_delete_failed".tr);
    } catch (e) {
      AppSnackBar.error("reward_delete_failed".tr);
    } finally {
      deletingRewardId.value = "";
    }
  }

  Future<void> validateRewardByCode() async {
  final code = codeController.text.trim();

  if (code.isEmpty) {
    AppSnackBar.error("code_required".tr);
    return;
  }

  try {
    isValidatingCode.value = true;

    final result = await MerchantRewardsApiClient.validateRewardByCode(code);

    codeController.clear();
    AppSnackBar.success(
      result["message"]?.toString() ?? "reward_validated_success".tr,
    );
  } on ApiException catch (e) {
    AppSnackBar.error(e.message);
  } on DioException catch (e) {
    final data = e.response?.data;
    String? apiMessage;
    if (data is Map<String, dynamic>) {
      apiMessage = data["message"]?.toString() ?? data["error"]?.toString();
    } else if (data is String && data.isNotEmpty) {
      apiMessage = data;
    }
    AppSnackBar.error(apiMessage ?? "reward_validate_failed".tr);
  } catch (e) {
    AppSnackBar.error("reward_validate_failed".tr);
  } finally {
    isValidatingCode.value = false;
  }
}

  Future<void> validateRewardByScan() async {
    
  }


  void onreset() {
    codeController.clear();
    newRewardNameController.clear();
   
  }
}