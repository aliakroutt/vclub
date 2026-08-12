import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Models/GoogleReviewModels.dart';
import 'package:vclub/Features/Merchant/GoogleReview/Services/GoogleReviewApiClient.dart';

class MerchantGoogleReviewController extends GetxController {
  final Rx<LoyaltyProgramModel?> program = Rx<LoyaltyProgramModel?>(null);
  final RxList<RewardModel> rewards = <RewardModel>[].obs;

  final RxBool loading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  final RxString reviewLink = "".obs;
  final Rx<RewardModel?> selectedReward = Rx<RewardModel?>(null);
  final Rx<ReviewTrigger?> selectedTrigger = Rx<ReviewTrigger?>(null);

  final RxBool isSavingLink = false.obs;
  final RxBool isSavingRewardSettings = false.obs;

  bool get hasUnsavedLinkEdit => _originalLink != reviewLink.value.trim();

  /// True when the reward or trigger selection differs from what the
  /// program API originally returned.
  bool get hasUnsavedRewardSettings {
    final rewardChanged = selectedReward.value?.id != _originalRewardId;
    final triggerChanged = selectedTrigger.value?.apiValue != _originalTrigger;
    return rewardChanged || triggerChanged;
  }

  String _originalLink = "";
  String? _originalRewardId;
  String? _originalTrigger;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      loading.value = true;
      hasError.value = false;

      final results = await Future.wait([
        GoogleReviewApiClient.getProgram(),
        GoogleReviewApiClient.getRewards(),
      ]);

      program.value = results[0] as LoyaltyProgramModel;
      rewards.assignAll(results[1] as List<RewardModel>);

      _seedFormState();

      hasError.value = false;
    } catch (e) {
      hasError.value = true;
    } finally {
      loading.value = false;
      initialLoaded.value = true;
    }
  }

  void _seedFormState() {
  final company = MerchantController.to.merchant.value?.company;
  _originalLink = company?.googleReviewLink ?? "";
  reviewLink.value = _originalLink;

  final p = program.value;
  if (p != null) {
    selectedTrigger.value = ReviewTriggerX.fromApi(p.reviewTrigger);
    _originalTrigger = p.reviewTrigger;

    // Match against reviewRewardId (the field we actually update),
    // not rewardId (a different, unrelated program field).
    if (p.reviewRewardId != null && p.reviewRewardId!.isNotEmpty) {
      try {
        selectedReward.value = rewards.firstWhere((r) => r.id == p.reviewRewardId);
      } catch (_) {
        selectedReward.value = null;
      }
    } else {
      selectedReward.value = null;
    }
    _originalRewardId = p.reviewRewardId;
  }
}

  void setReviewLink(String value) {
    reviewLink.value = value;
  }

  void setSelectedReward(RewardModel reward) {
    selectedReward.value = reward;
  }

  void setSelectedTrigger(ReviewTrigger trigger) {
    selectedTrigger.value = trigger;
  }

  Future<bool> saveReviewLinkIfChanged() async {
    final trimmed = reviewLink.value.trim();

    if (trimmed == _originalLink) return true;

    try {
      isSavingLink.value = true;
      await GoogleReviewApiClient.updateGoogleReviewLink(trimmed);

      final profile = MerchantController.to.merchant.value;
      if (profile?.company != null) {
        await MerchantController.to.saveMerchant(profile!.copyWithCompanyLink(trimmed));
      }

      _originalLink = trimmed;
      AppSnackBar.success("review_link_updated".tr);
      return true;
    } catch (e) {
      AppSnackBar.error("review_link_update_failed".tr);
      return false;
    } finally {
      isSavingLink.value = false;
    }
  }

  /// Persists reward + trigger only if at least one actually changed.
  /// Returns true on success (or if nothing needed saving).
  Future<bool> saveRewardSettingsIfChanged() async {
    if (!hasUnsavedRewardSettings) return true;

    final reward = selectedReward.value;
    final trigger = selectedTrigger.value;

    if (reward == null || trigger == null) {
      AppSnackBar.error("reward_settings_incomplete".tr);
      return false;
    }

    try {
      isSavingRewardSettings.value = true;

      await GoogleReviewApiClient.updateProgramReviewSettings(
        reviewRewardId: reward.id,
        reviewTrigger: trigger.apiValue,
      );

      _originalRewardId = reward.id;
      _originalTrigger = trigger.apiValue;

      AppSnackBar.success("reward_settings_updated".tr);
      return true;
    } catch (e) {
      AppSnackBar.error("reward_settings_update_failed".tr);
      return false;
    } finally {
      isSavingRewardSettings.value = false;
    }
  }

  Future<void> refresh() => fetchAll();
}