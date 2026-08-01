import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/Models/HistoryWheelModel.dart';

import 'package:vclub/Features/Merchant/FortuneWheel/Services/FortuneWheelHistoryApiClient.dart';

class FortuneWheelHistoryController extends GetxController {
  static FortuneWheelHistoryController get to => Get.find();

  final RxList<WheelHistorySpinModel> items = <WheelHistorySpinModel>[].obs;
  final RxBool loading = false.obs; // initial / filter reload
  final RxBool loadingMore = false.obs; // pagination
  final RxBool initialLoaded = false.obs;
  final RxString error = "".obs;
  final RxInt totalCount = 0.obs;

  final Rxn<DateTime> startDate = Rxn<DateTime>();
  final Rxn<DateTime> endDate = Rxn<DateTime>();

  final ScrollController scrollController = ScrollController();

  int _page = 1;
  int _totalPages = 1;
  static const int _limit = 15;

  bool get hasMore => _page < _totalPages;
  bool get hasFilters => startDate.value != null || endDate.value != null;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    fetchHistory(reset: true);
  }

  @override
  void onClose() {
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!hasMore || loadingMore.value || loading.value) return;
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 220) {
      loadMore();
    }
  }

  Future<void> fetchHistory({bool reset = false}) async {
  if (reset) {
    _page = 1;
    _totalPages = 1;
    error.value = "";
    loading.value = true;
  }

  try {
    final result = await FortuneWheelHistoryApiClient.getHistory(
      page: _page,
      limit: _limit,
      from: startDate.value,
      to: endDate.value,
    );

    if (reset) {
      items.assignAll(result.items);
    } else {
      items.addAll(result.items);
    }

    _totalPages = result.totalPages;
    totalCount.value = result.total;
  } catch (e) {
    if (reset) error.value = "failed_load_history".tr;
  } finally {
    loading.value = false;
    loadingMore.value = false;
    initialLoaded.value = true;
  }
}

  Future<void> loadMore() async {
    if (!hasMore || loadingMore.value) return;
    loadingMore.value = true;
    _page += 1;
    await fetchHistory();
  }

  Future<void> refresh() => fetchHistory(reset: true);

  void setStartDate(DateTime date) {
    startDate.value = date;
    if (endDate.value != null && endDate.value!.isBefore(date)) {
      endDate.value = null;
    }
    fetchHistory(reset: true);
  }

  void setEndDate(DateTime date) {
    endDate.value = date;
    fetchHistory(reset: true);
  }

  void clearFilters() {
    startDate.value = null;
    endDate.value = null;
    fetchHistory(reset: true);
  }
}