import 'dart:async';

import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramsModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Services/MerchantProgramsService.dart';


class MerchantProgramsController extends GetxController {
  static MerchantProgramsController get to => Get.find();

  // =========================
  // FIRST-LOAD FLAG
  // =========================
  final RxBool initialLoaded = false.obs;
  final RxBool isTogglingFreeze = false.obs;

  Future<void> toggleProgramStatus(ProgramModel program) async {
    final wasActive = program.active;
    isTogglingFreeze.value = true;
    try {
      if (wasActive) {
        await MerchantProgramsApiClient.freezeProgram(program.id);
      } else {
        await MerchantProgramsApiClient.unfreezeProgram(program.id);
      }

      final index = programs.indexWhere((p) => p.id == program.id);
      if (index != -1) {
        programs[index] = programs[index].copyWith(active: !wasActive);
      }
    } finally {
      isTogglingFreeze.value = false;
    }
  }
  // =========================
  // LOADING STATES
  // =========================
  final RxBool loading = false.obs;      // first page / full-screen loading
  final RxBool loadingMore = false.obs;  // subsequent pages

  // =========================
  // ERROR STATE
  // =========================
  final RxString error = "".obs;

  // =========================
  // SEARCH
  // =========================
  final RxString searchQuery = "".obs;
  Timer? _debounce;

  // =========================
  // DATA STATE
  // =========================
  final RxList<ProgramModel> programs = <ProgramModel>[].obs;
  final RxInt page = 1.obs;
  final RxInt total = 0.obs;
  final RxInt totalPages = 1.obs;

  static const int _limit = 10;

  bool get hasMore => page.value < totalPages.value;

  // =========================
  // MAIN ENTRY POINT
  // =========================
  Future<void> fetchPrograms({bool refresh = true}) async {
    try {
      if (refresh) {
        if (!initialLoaded.value) loading.value = true;
        error.value = "";
      }

      final result = await MerchantProgramsApiClient.getPrograms(
        search: searchQuery.value,
        page: 1,
        limit: _limit,
      );

      programs.assignAll(result.data);
      page.value = result.page;
      total.value = result.total;
      totalPages.value = result.totalPages;
      loading.value = false;
      initialLoaded.value = true;
    } catch (e) {
      error.value = "failed_load_programs".tr;
      loading.value = false;
      initialLoaded.value = true;
    } finally {
      loading.value = false;
      initialLoaded.value = true;
    }
  }

  // =========================
  // LOAD MORE (PAGINATION)
  // =========================
  Future<void> loadMore() async {
    if (loadingMore.value || loading.value) return;
    if (!hasMore) return;

    try {
      loadingMore.value = true;

      final nextPage = page.value + 1;

      final result = await MerchantProgramsApiClient.getPrograms(
        search: searchQuery.value,
        page: nextPage,
        limit: _limit,
      );

      programs.addAll(result.data);
      page.value = result.page;
      total.value = result.total;
      totalPages.value = result.totalPages;
       loadingMore.value = false;
    } catch (e) {
      // AppSnackBar.error("failed_load_programs".tr);
       loadingMore.value = false;
    } finally {
      loadingMore.value = false;
    }
  }

  // =========================
  // SEARCH (DEBOUNCED)
  // =========================
  void onSearchChanged(String query) {
    searchQuery.value = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchPrograms(refresh: true);
    });
  }

  // =========================
  // RESET
  // =========================
  void resetControllerData() {
    initialLoaded.value = false;
    loading.value = false;
    loadingMore.value = false;
    error.value = "";
    searchQuery.value = "";
    programs.clear();
    page.value = 1;
    total.value = 0;
    totalPages.value = 1;
    _debounce?.cancel();
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}