// Features/Merchant/FortuneWheel/Controllers/FortuneWheelHomeController.dart
import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/FortuneSegmentModel.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Services/MerchantWheelApiService.dart';

class FortuneWheelHomeController extends GetxController {
  static FortuneWheelHomeController get to => Get.find();

  final RxBool loading = false.obs;
  final RxBool initialLoaded = false.obs;
  final RxString error = "".obs;
  final Rxn<FortuneWheelConfigModel> config = Rxn<FortuneWheelConfigModel>();

  @override
  void onInit() {
    super.onInit();
    fetchWheelConfig();
  }

  Future<void> fetchWheelConfig() async {
    try {
      if (!initialLoaded.value) loading.value = true;
      error.value = "";

      final result = await MerchantWheelApiClient.getWheelConfig();
      config.value = result;
    } catch (e) {
      error.value = "failed_load_wheel_config".tr;
    } finally {
      loading.value = false;
      initialLoaded.value = true;
    }
  }

  Future<void> refresh() => fetchWheelConfig();
}