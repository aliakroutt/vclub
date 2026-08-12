import 'package:dio/dio.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
import 'package:vclub/Features/Merchant/Billing/Models/ChangePlanModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/InvoiceModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/PlanModel.dart';
import 'package:vclub/Features/Merchant/Billing/Models/SmsAddonModel.dart';

class MerchantBillingApiClient {
  MerchantBillingApiClient._();

  static Future<SmsAddonInfoModel> getSmsAddonInfo() async {
    final Response response = await ApiClient.get(ApiRoutes.merchant_SMS);

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SmsAddonInfoModel.fromJson(data);
    }
    throw Exception("Invalid SMS addon response");
  }

  static Future<SmsAddonToggleResult> toggleSmsAddon(bool enabled) async {
    final Response response = await ApiClient.post(
      ApiRoutes.merchant_update_SMS,
      data: {"enabled": enabled},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return SmsAddonToggleResult.fromJson(data);
    }
    throw Exception("Invalid SMS addon toggle response");
  }

  static Future<ReactivateSubscriptionResult> reactivateSubscription() async {
    final Response response = await ApiClient.post(
      ApiRoutes.merchant_reactivate,
      data: {"resumed": true, "cancelAtPeriodEnd": false},
    );

    final data = response.data;
    if (data is Map<String, dynamic>) {
      return ReactivateSubscriptionResult.fromJson(data);
    }
    throw Exception("Invalid reactivate subscription response");
  }

  static Future<CancelSubscriptionResult> cancelSubscription({required bool immediate}) async {
  final Response response = await ApiClient.post(
    ApiRoutes.merchant_cancel_plan,
    data: {"immediate": immediate},
  );

  final data = response.data;
  if (data is Map<String, dynamic>) {
    return CancelSubscriptionResult.fromJson(data);
  }
  throw Exception("Invalid cancel subscription response");
}
static Future<List<PlanPriceModel>> getPlans() async {
  final Response response = await ApiClient.get(ApiRoutes.merchant_plans);

  final data = response.data;
  if (data is List) {
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => PlanPriceModel.fromJson(e))
        .toList();
  }
  throw Exception("Invalid plans response");
}
static Future<ChangePlanResult> changePlan({required String plan, required bool sms}) async {
  final Response response = await ApiClient.post(
    ApiRoutes.merchant_change_plan,
    data: {"plan": plan, "sms": sms},
  );

  final data = response.data;
  if (data is Map<String, dynamic>) {
    return ChangePlanResult.fromJson(data);
  }
  throw Exception("Invalid change plan response");
}
static Future<ChangePlanResult> resubscribe({required String plan, required bool sms}) async {
  final Response response = await ApiClient.post(
    ApiRoutes.merchant_resubscribe,
    data: {"plan": plan, "sms": sms},
  );

  final data = response.data;
  if (data is Map<String, dynamic>) {
    return ChangePlanResult.fromJson(data);
  }
  throw Exception("Invalid resubscribe response");
}
static Future<InvoicesPageResponse> getInvoices({int page = 1, int limit = 10}) async {
  final Response response = await ApiClient.get(
    ApiRoutes.merchant_invoices_history,
    queryParameters: {"page": page, "limit": limit},
  );

  final data = response.data;
  if (data is Map<String, dynamic>) {
    return InvoicesPageResponse.fromJson(data);
  }
  throw Exception("Invalid invoices response");
}
static Future<String?> getBillingPortalUrl() async {
  final Response response = await ApiClient.post(
    ApiRoutes.merchant_portal,
    data: {},
  );

  final data = response.data;
  if (data is Map<String, dynamic>) {
    return data['url']?.toString();
  }
  throw Exception("Invalid billing portal response");
}
}