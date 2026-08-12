import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Billing/Models/InvoiceModel.dart';
import 'package:vclub/Features/Merchant/Billing/Services/MerchantBillingApiClient.dart';

class InvoicesController extends GetxController {
  final RxList<InvoiceModel> invoices = <InvoiceModel>[].obs;
  final Rx<InvoicesSummaryModel?> summary = Rx<InvoicesSummaryModel?>(null);
  
  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  int _page = 1;
  final int _limit = 10;
  int _totalPages = 1;

  bool get hasMore => _page < _totalPages;

  final RxInt total = 0.obs;
  @override
  void onInit() {
    super.onInit();
    fetchInvoices(reset: true);
  }

  Future<void> fetchInvoices({bool reset = false}) async {
    if (reset) {
      _page = 1;
      hasError.value = false;
      loading.value = true;
    }

    try {
      final result = await MerchantBillingApiClient.getInvoices(page: _page, limit: _limit);
       total.value = result.total;
      _totalPages = result.totalPages;
      if (result.summary != null) summary.value = result.summary;

      if (reset) {
        invoices.assignAll(result.data);
      } else {
        invoices.addAll(result.data);
      }

      hasError.value = false;
    } catch (e) {
      if (reset) {
        hasError.value = true;
        invoices.clear();
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
    await fetchInvoices(reset: false);
  }

  Future<void> refresh() => fetchInvoices(reset: true);
}