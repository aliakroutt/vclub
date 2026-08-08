import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Redemptions/Models/MerchantRedemptionModel.dart';
import 'package:vclub/Features/Merchant/Redemptions/Services/MerchantRedemptionsApiClient.dart';

class MerchantRedemptionsController extends GetxController {
  final RxList<MerchantRedemptionItem> redemptions = <MerchantRedemptionItem>[].obs;

  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  final RxInt totalItems = 0.obs;

  int _page = 1;
  final int _limit = 20;
  int _totalPages = 1;

  bool get hasMore => _page < _totalPages;

  // ===== FILTERS =====
  final Rx<RedemptionStatus> statusFilter = RedemptionStatus.unknown.obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);

  int get activeFilterCount {
    int count = 0;
    if (statusFilter.value != RedemptionStatus.unknown) count++;
    if (fromDate.value != null || toDate.value != null) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    fetchRedemptions(reset: true);
  }

  Future<void> fetchRedemptions({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasError.value = false;
      loading.value = true;
    }

    try {
      final result = await MerchantRedemptionsApiClient.getRedemptions(
        page: _page,
        limit: _limit,
        status: statusFilter.value.apiValue,
        from: fromDate.value,
        to: toDate.value,
      );

      _totalPages = result.totalPages;
      totalItems.value = result.total;

      if (reset) {
        redemptions.assignAll(result.data);
      } else {
        redemptions.addAll(result.data);
      }

      hasError.value = false;
    } catch (e) {
      if (reset) {
        hasError.value = true;
        redemptions.clear();
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
    await fetchRedemptions(reset: false);
  }

  Future<void> refresh() => fetchRedemptions(reset: true);

  // ===== FILTER ACTIONS =====
  void setStatusFilter(RedemptionStatus status) {
    statusFilter.value = status;
    fetchRedemptions(reset: true);
  }

  void setDateRange(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;
    fetchRedemptions(reset: true);
  }

  void clearAllFilters() {
    statusFilter.value = RedemptionStatus.unknown;
    fromDate.value = null;
    toDate.value = null;
    fetchRedemptions(reset: true);
  }
}