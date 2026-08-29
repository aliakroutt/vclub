import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Client/Cards/Services/GoogleWalletApiClient.dart';


class GoogleWalletController extends GetxController {
  final RxBool isLoading = false.obs;

  Future<void> addToGoogleWallet(String cardId) async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;
      final result = await GoogleWalletApiClient.getGoogleWalletSaveUrl(cardId);

      if (result.saveUrl.isEmpty) {
        AppSnackBar.error("google_wallet_failed".tr);
        return;
      }

      final launched = await launchUrlString(result.saveUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackBar.error("google_wallet_open_failed".tr);
      }
    } catch (e) {
      AppSnackBar.error("google_wallet_failed".tr);
    } finally {
      isLoading.value = false;
    }
  }
}