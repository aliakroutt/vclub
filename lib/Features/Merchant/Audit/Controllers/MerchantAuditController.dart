import 'dart:async';
import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Audit/Models/MerchantAuditModel.dart';
import 'package:vclub/Features/Merchant/Audit/Services/MerchantAuditApiClient.dart';

class MerchantAuditController extends GetxController {
  final RxList<MerchantAuditItem> logs = <MerchantAuditItem>[].obs;

  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  final RxInt totalItems = 0.obs;

  int _page = 1;
  final int _limit = 20;
  int _totalPages = 1;
  Timer? _debounce;

  bool get hasMore => _page < _totalPages;

  // ===== FILTERS =====
  final RxString actionQuery = "".obs;
  final Rx<DateTime?> fromDate = Rx<DateTime?>(null);
  final Rx<DateTime?> toDate = Rx<DateTime?>(null);

  int get activeFilterCount {
    int count = 0;
    if (actionQuery.value.trim().isNotEmpty) count++;
    if (fromDate.value != null || toDate.value != null) count++;
    return count;
  }

  @override
  void onInit() {
    super.onInit();
    fetchLogs(reset: true);
  }

  Future<void> fetchLogs({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasError.value = false;
      loading.value = true;
    }

    try {
      final result = await MerchantAuditApiClient.getAuditLogs(
        page: _page,
        limit: _limit,
        action: actionQuery.value.trim(),
        from: fromDate.value,
        to: toDate.value,
      );

      _totalPages = result.totalPages;
      totalItems.value = result.total;

      if (reset) {
        logs.assignAll(result.data);
      } else {
        logs.addAll(result.data);
      }

      hasError.value = false;
    } catch (e) {
      if (reset) {
        hasError.value = true;
        logs.clear();
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
    await fetchLogs(reset: false);
  }

  Future<void> refresh() => fetchLogs(reset: true);

  // ===== FILTER ACTIONS =====
  void onActionSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      actionQuery.value = value;
      fetchLogs(reset: true);
    });
  }

  void setDateRange(DateTime? from, DateTime? to) {
    fromDate.value = from;
    toDate.value = to;
    fetchLogs(reset: true);
  }

  void clearAllFilters() {
    actionQuery.value = "";
    fromDate.value = null;
    toDate.value = null;
    fetchLogs(reset: true);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}