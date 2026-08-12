import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';
import 'package:vclub/Features/Auth/Services/MerchantService.dart';
import 'package:vclub/Features/Merchant/Billing/Controllers/InvoicesController.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';
import 'package:vclub/Features/Merchant/Billing/Services/MerchantBillingApiClient.dart';

class SmsAddonController extends GetxController {
  final RxBool enabled = false.obs;
  final Rx<SmsAddonInfoModel?> info = Rx<SmsAddonInfoModel?>(null);

  final RxBool loadingInfo = false.obs;
  final RxBool toggling = false.obs;
  final RxBool hasError = false.obs;

  final RxBool isReactivating = false.obs;
  final RxBool isCanceling = false.obs;

  Worker? _merchantWorker;

  @override
  void onInit() {
    super.onInit();

    // Seed immediately in case merchant data is already loaded.
    _syncEnabledFromMerchant(MerchantController.to.merchant.value);

    // Keep in sync any time the merchant profile changes/refreshes
    // (initial load completing late, after toggle, cancel, reactivate, etc.).
    _merchantWorker = ever<MerchantProfileModel?>(
      MerchantController.to.merchant,
      _syncEnabledFromMerchant,
    );

    fetchInfo();
  }

  void _syncEnabledFromMerchant(MerchantProfileModel? merchant) {
    enabled.value = merchant?.company?.smsAddon ?? false;
  }

  Future<void> fetchInfo() async {
    try {
      loadingInfo.value = true;
      hasError.value = false;
      info.value = await MerchantBillingApiClient.getSmsAddonInfo();
    } catch (e) {
      hasError.value = true;
    } finally {
      loadingInfo.value = false;
    }
  }

  Future<SmsAddonToggleResult?> toggle(bool value) async {
    try {
      toggling.value = true;
      final result = await MerchantBillingApiClient.toggleSmsAddon(value);
      enabled.value = result.enabled;
      return result;
    } catch (e) {
      return null;
    } finally {
      toggling.value = false;
    }
  }

  Future<bool> reactivateSubscription() async {
    try {
      isReactivating.value = true;
      await MerchantBillingApiClient.reactivateSubscription();
      await refreshProfile();
      AppSnackBar.success("reactivate_success".tr);
      return true;
    } catch (e) {
      AppSnackBar.error("reactivate_failed".tr);
      return false;
    } finally {
      isReactivating.value = false;
    }
  }

  Future<bool> cancelSubscription({required bool immediate}) async {
    try {
      isCanceling.value = true;
      await MerchantBillingApiClient.cancelSubscription(immediate: immediate);
      await refreshProfile();
      AppSnackBar.success(
        immediate ? "cancel_immediate_success".tr : "cancel_period_end_success".tr,
      );
      return true;
    } catch (e) {
      AppSnackBar.error("cancel_plan_failed".tr);
      return false;
    } finally {
      isCanceling.value = false;
    }
  }

  Future<void> refreshProfile() async {
  final profile = await MerchantService.profile();

  if (profile == null) {
    AppSnackBar.error("Failed to load profile");
    return;
  }
  await MerchantController.to.saveMerchant(profile);

  // Keep billing stats/invoice list in sync whenever the profile refreshes
  // (init, after SMS toggle, cancel, reactivate, or change-plan).
  if (Get.isRegistered<InvoicesController>()) {
    await Get.find<InvoicesController>().fetchInvoices(reset: true);
  }
}
final RxBool isOpeningPortal = false.obs;

Future<String?> fetchBillingPortalUrl() async {
  try {
    isOpeningPortal.value = true;
    final url = await MerchantBillingApiClient.getBillingPortalUrl();

    if (url == null || url.isEmpty) {
      AppSnackBar.error("portal_link_failed".tr);
      return null;
    }

    return url;
  } catch (e) {
    AppSnackBar.error("portal_link_failed".tr);
    return null;
  } finally {
    isOpeningPortal.value = false;
  }
}

  @override
  void onClose() {
    _merchantWorker?.dispose();
    super.onClose();
  }
}