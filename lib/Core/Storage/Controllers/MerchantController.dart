import 'package:get/get.dart';
import 'package:vclub/Core/Storage/UserStorage.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';

class MerchantController extends GetxController {
  static MerchantController get to => Get.find();

  final Rxn<MerchantProfileModel> merchant = Rxn<MerchantProfileModel>();

  bool get isLogged => merchant.value != null;

  /// True when the merchant has no active paid subscription
  /// (no plan selected yet, or subscription isn't active).
  bool get isFreePlan {
    final company = merchant.value?.company;
    if (company == null) return true;

    final hasPlan = company.stripePlan != null && company.stripePlan!.isNotEmpty;
    final hasActiveSubscription = company.hasSubscription && company.isSubscriptionActive;

    return !hasPlan || !hasActiveSubscription;
  }

  Future<void> saveMerchant(MerchantProfileModel model) async {
    merchant.value = model;
    await UserStorage.saveMerchant(model);
  }

  Future<void> loadMerchant() async {
    final data = await UserStorage.getMerchant();

    if (data != null) {
      merchant.value = data;
    }
  }

  Future<void> clear() async {
    merchant.value = null;
    await UserStorage.clear();
  }
}