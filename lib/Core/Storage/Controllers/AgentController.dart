import 'package:get/get.dart';
import 'package:vclub/Core/Storage/AgentStorage.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';

class AgentController extends GetxController {
  static AgentController get to => Get.find();

  final Rxn<MerchantProfileModel> agent = Rxn<MerchantProfileModel>();

  bool get isLogged => agent.value != null;

  /// True when the agent's company has no active paid subscription —
  /// kept for parity with MerchantController in case staff-side screens
  /// ever need to gate features by plan the same way.
  bool get isFreePlan {
    final company = agent.value?.company;
    if (company == null) return true;

    final hasPlan = company.stripePlan != null && company.stripePlan!.isNotEmpty;
    final hasActiveSubscription = company.hasSubscription && company.isSubscriptionActive;

    return !hasPlan || !hasActiveSubscription;
  }

  Future<void> saveAgent(MerchantProfileModel model) async {
    agent.value = model;
    await AgentStorage.saveAgent(model);
  }

  Future<void> loadAgent() async {
    final data = await AgentStorage.getAgent();

    if (data != null) {
      agent.value = data;
    }
  }

  Future<void> clear() async {
    agent.value = null;
    await AgentStorage.clear();
  }
}