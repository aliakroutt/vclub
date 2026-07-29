import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';
import 'package:vclub/Features/Merchant/Clients/Services/MerchantClientSetailsService.dart';


class ClientDetailsController extends GetxController {
  final ClientModel initialClient;
  ClientDetailsController(this.initialClient);

  late final Rx<ClientModel> client = initialClient.obs;
  final isLoading = false.obs;
  final hasError = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDetails();
  }

  Future<void> fetchDetails() async {
    isLoading.value = true;
    hasError.value = false;
    try {
      final result = await MerchantClientDetailsApiClient.getClientDetails(
        initialClient.membershipId,
      );
      client.value = initialClient.mergeMembership(result.membership).copyWithHistory(result.history);
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}