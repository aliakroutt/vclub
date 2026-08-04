import 'dart:async';
import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Compains/Models/CampaignModel.dart';
import 'package:vclub/Features/Merchant/Compains/Services/CampaignApiClient.dart';
import 'package:vclub/Features/Merchant/Employee/Services/ApiErrorHnadler.dart';


class CampaignController extends GetxController {
  final campaigns = <CampaignModel>[].obs;

  final isLoading = false.obs;      // first load
  final isLoadingMore = false.obs;  // pagination
  final hasError = false.obs;
  final isDeletingId = RxnString();

  int _page = 1;
  final int _limit = 10;
  int _totalPages = 1;

  bool get hasMore => _page < _totalPages;

  @override
  void onInit() {
    super.onInit();
    fetchCampaigns(reset: true);
  }

  Future<void> fetchCampaigns({required bool reset}) async {
    if (reset) {
      _page = 1;
      hasError.value = false;
      isLoading.value = true;
    }

    try {
      final result = await CampaignApiClient.getCampaigns(
        page: _page,
        limit: _limit,
      );

      _totalPages = result.totalPages;

      if (reset) {
        campaigns.assignAll(result.data);
      } else {
        campaigns.addAll(result.data);
      }
    } catch (e) {
      if (reset) {
        hasError.value = true;
        campaigns.clear();
      }
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || isLoading.value || !hasMore) return;
    isLoadingMore.value = true;
    _page++;
    await fetchCampaigns(reset: false);
  }

  Future<void> refresh() => fetchCampaigns(reset: true);

  Future<void> deleteCampaign(String id) async {
  isDeletingId.value = id;
  try {
    await CampaignApiClient.deleteCampaign(id);
    campaigns.removeWhere((c) => c.id == id);
  } catch (e) {
    throw ApiErrorHandler.extract(e); // rethrow as a clean message for the dialog
  } finally {
    isDeletingId.value = null;
  }
}
}