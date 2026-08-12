import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Merchant/Billing/Models/ChangePlanModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/PlanModel.dart';
import 'package:vclub/Features/Merchant/Billing/Services/MerchantBillingApiClient.dart';

class PlansController extends GetxController {
  final RxList<PlanDisplayModel> plans = <PlanDisplayModel>[].obs;

  final RxBool loading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  final RxBool isChangingPlan = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    try {
      loading.value = true;
      hasError.value = false;

      final prices = await MerchantBillingApiClient.getPlans();

      final merged = <PlanDisplayModel>[];
      for (final price in prices) {
        final features = PlanFeaturesModel.of(price.key);
        if (features != null) {
          merged.add(PlanDisplayModel(price: price, features: features));
        }
      }

      const order = ["STARTER", "BUSINESS", "PREMIUM"];
      merged.sort((a, b) =>
          order.indexOf(a.price.key.toUpperCase()).compareTo(order.indexOf(b.price.key.toUpperCase())));

      plans.assignAll(merged);
    } catch (e) {
      hasError.value = true;
    } finally {
      loading.value = false;
      initialLoaded.value = true;
    }
  }

  /// Uses /stripe/resubscribe when the merchant currently has no active plan
  /// (free), and /stripe/change-plan when they're switching between plans.
  Future<ChangePlanResult?> changePlan({required String plan, required bool sms}) async {
    try {
      isChangingPlan.value = true;

      final isFreePlan = MerchantController.to.isFreePlan;

      return isFreePlan
          ? await MerchantBillingApiClient.resubscribe(plan: plan, sms: sms)
          : await MerchantBillingApiClient.changePlan(plan: plan, sms: sms);
    } catch (e) {
      AppSnackBar.error("change_plan_failed".tr);
      return null;
    } finally {
      isChangingPlan.value = false;
    }
  }
}