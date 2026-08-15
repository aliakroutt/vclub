import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/QRScanner/Models/ScanModels.dart';
import 'package:vclub/Features/Merchant/QRScanner/Services/ScanApiServices.dart';

class StaffValidateRewardController extends GetxController {
  final RxBool isValidating = false.obs;

  /// Validates a reward by its code. Returns the result on success, or
  /// throws an ApiException carrying the real backend message on failure.
  Future<RedeemResultModel> validateByCode(String code) async {
    final trimmed = code.trim();

    isValidating.value = true;
    try {
      final result = await ScanApiClient.validateCode(trimmed);
      return result;
    } finally {
      isValidating.value = false;
    }
  }
}