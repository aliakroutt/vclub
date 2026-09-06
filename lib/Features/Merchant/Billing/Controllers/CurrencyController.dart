// lib/Features/Merchant/Billing/Controllers/CurrencyController.dart
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/Currency/CurrencyExchangeService.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';
import 'package:vclub/Features/Auth/Services/MerchantService.dart';
import 'package:vclub/Features/Merchant/Billing/Models/CurrencyOption.dart';
import 'package:vclub/Features/Merchant/Billing/Services/MerchantBillingApiClient.dart';


class CurrencyController extends GetxController {
  static CurrencyController get to => Get.find();

  final RxBool isChangingCurrency = false.obs;
  final Rxn<CurrencyOption> pendingOption = Rxn<CurrencyOption>();

  /// Live rates relative to EUR, refreshed on init and after currency change.
  final RxMap<String, double> rates = <String, double>{}.obs;
  final RxBool ratesLoading = false.obs;

  CurrencyOption? get currentCurrency =>
      CurrencyOptionX.fromCurrencyCode(
        MerchantController.to.merchant.value?.company?.currencyCode,
      );

  @override
  void onInit() {
    super.onInit();
    refreshRates();
  }

  Future<void> refreshRates() async {
    try {
      ratesLoading.value = true;
      final result = await CurrencyExchangeService.getRates();
      rates.assignAll(result);
    } finally {
      ratesLoading.value = false;
    }
  }

  /// Converts [amountInEur] to the merchant's current display currency
  /// and formats it with the right symbol — e.g. "45.30 DT", "$49.99".
  /// Falls back to plain EUR formatting if rates aren't loaded yet or
  /// the merchant has no currency set.
  String formatAmount(num amountInEur) {
    final current = currentCurrency ?? CurrencyOption.eur;

    if (current == CurrencyOption.eur) {
      return "${amountInEur.toStringAsFixed(2)} ${current.symbol}";
    }

    final rate = rates[current.currencyCode];
    if (rate == null) {
      // Rates not loaded yet — show EUR as a safe fallback rather than
      // a wrong/unconverted number labeled with the wrong symbol.
      return "${amountInEur.toStringAsFixed(2)} €";
    }

    final converted = amountInEur * rate;
    return "${converted.toStringAsFixed(2)} ${current.symbol}";
  }

  Future<bool> changeCurrency(CurrencyOption option) async {
    if (isChangingCurrency.value) return false;

    try {
      isChangingCurrency.value = true;
      pendingOption.value = option;

      await MerchantBillingApiClient.updateCompanyCountry(option.countryCode);

      final profile = await MerchantService.profile();
      if (profile == null) {
        AppSnackBar.error("failed_load_profile".tr);
        return false;
      }
      await MerchantController.to.saveMerchant(profile);
      await refreshRates(); // ensure fresh rates for the new currency

      AppSnackBar.success("currency_updated".tr);
      return true;
    } on DioException catch (e) {
      final data = e.response?.data;
      final message = (data is Map<String, dynamic>) ? data["message"]?.toString() : null;
      AppSnackBar.error(message ?? "currency_update_failed".tr);
      return false;
    } catch (e) {
      AppSnackBar.error("currency_update_failed".tr);
      return false;
    } finally {
      isChangingCurrency.value = false;
      pendingOption.value = null;
    }
  }
}