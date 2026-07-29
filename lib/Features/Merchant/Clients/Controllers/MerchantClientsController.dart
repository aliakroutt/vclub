import 'dart:async';
import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Clients/Models/ClientModel.dart';
import 'package:vclub/Features/Merchant/Clients/Services/MerchantClientsApiClient.dart';
import 'package:vclub/Features/Merchant/Clients/View/Widgets/ClientsTabs.dart';

class ClientsController extends GetxController {
  final clients = <ClientModel>[].obs;

  final isLoading = false.obs;      // first load / reset (search, filter, refresh)
  final isLoadingMore = false.obs;  // pagination
  final hasError = false.obs;

  final searchQuery = ''.obs;
  final Rx<ClientTab> selectedTab = ClientTab.all.obs;
  final RxInt totalClients = 0.obs;

  int _page = 1;
  final int _limit = 15;
  int _totalPages = 1;
  Timer? _debounce;

  bool get hasMore => _page < _totalPages;

  @override
  void onInit() {
    super.onInit();
    fetchClients(reset: true);
  }

  Future<void> fetchClients({required bool reset}) async {
    if (reset) {
      _page = 1;
      hasError.value = false;
      isLoading.value = true;
    }

    try {
      final result = await MerchantClientsApiClient.getClients(
        page: _page,
        limit: _limit,
        search: searchQuery.value,
        filter: selectedTab.value,
      );

      _totalPages = result.totalPages;
      totalClients.value = result.total;

      if (reset) {
        clients.assignAll(result.data);
      } else {
        clients.addAll(result.data);
      }
    } catch (e) {
      if (reset) {
        hasError.value = true;
        clients.clear();
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
    await fetchClients(reset: false);
  }

  void changeTab(ClientTab tab) {
    if (selectedTab.value == tab) return;
    selectedTab.value = tab;
    fetchClients(reset: true);
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      searchQuery.value = value;
      fetchClients(reset: true);
    });
  }

  Future<void> refresh() => fetchClients(reset: true);
  Future<void> resetData() async {
  _debounce?.cancel();

  searchQuery.value = '';
  selectedTab.value = ClientTab.all;
  _page = 1;
  _totalPages = 1;
  totalClients.value = 0;
  hasError.value = false;
  clients.clear();

  await fetchClients(reset: true);
}

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}