import 'package:get/get.dart';
import 'package:vclub/Core/Storage/UserStorage.dart';
import 'package:vclub/Features/Auth/Models/MerchantModel.dart';

class MerchantController extends GetxController {
  static MerchantController get to => Get.find();

  final Rxn<MerchantProfileModel> merchant = Rxn<MerchantProfileModel>();

  bool get isLogged => merchant.value != null;

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