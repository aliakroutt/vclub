import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Avtivity/Models/MerchantActivityModel.dart';
import 'package:vclub/Features/Merchant/Avtivity/Services/MerchantActivityApiClient.dart';

class AgentActivityController extends GetxController {
  final RxList<MerchantActivityItem> activities = <MerchantActivityItem>[].obs;

  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  final RxInt totalItems = 0.obs;

  int _page = 1;
  final int _limit = 20;
  int _totalPages = 1;

  bool get hasMore => _page < _totalPages;

  // ===== FILTERS (type + date range only) =====
  final RxString actionFilter = "".obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);

  int get activeFilterCount {
    int count = 0;
    if (actionFilter.value.isNotEmpty) count++;
    if (fromDate.value != null || toDate.value != null) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    fetchActivities(reset: true);
  }

  Future<void> fetchActivities({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasError.value = false;
      loading.value = true;
    }

    try {
      final result = await MerchantActivityApiClient.getActivity(
        page: _page,
        limit: _limit,
        action: actionFilter.value,
        from: fromDate.value,
        to: toDate.value,
      );

      _totalPages = result.totalPages;
      totalItems.value = result.total;

      if (reset) {
        activities.assignAll(result.data);
      } else {
        activities.addAll(result.data);
      }

      hasError.value = false;
    } catch (e) {
      if (reset) {
        hasError.value = true;
        activities.clear();
      }
    } finally {
      loading.value = false;
      loadingMore.value = false;
      initialLoaded.value = true;
    }
  }

  Future<void> loadMore() async {
    if (loadingMore.value || loading.value || !hasMore) return;
    loadingMore.value = true;
    _page++;
    await fetchActivities(reset: false);
  }

  Future<void> refresh() => fetchActivities(reset: true);

  // ===== FILTER ACTIONS =====
  void setActionFilter(String value) {
    actionFilter.value = value;
    fetchActivities(reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;
    fetchActivities(reset: true);
  }

  void clearAllFilters() {
    actionFilter.value = "";
    fromDate.value = null;
    toDate.value = null;
    fetchActivities(reset: true);
  }
}