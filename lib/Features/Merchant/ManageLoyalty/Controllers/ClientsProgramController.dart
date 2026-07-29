import 'dart:async';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter/widgets.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ClientModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramClientsStatsModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Models/ProgramStatModel.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Services/MerchantProgramsService.dart';

class ProgramClientsController extends GetxController {
  final String programId;
  final String initialProgramName;

  ProgramClientsController({
    required this.programId,
    this.initialProgramName = '',
  });

  // header
  final totalClients = 0.obs;
  final programName = ''.obs;
  final programActive = true.obs;

  // stats
  final isStatsLoading = true.obs;
  final statsError = RxnString();
  final stats = <ProgramStat>[].obs;

  // clients list
  final clients = <ClientModel>[].obs;
  final isClientsLoading = true.obs;
  final isLoadingMore = false.obs;
  final clientsError = RxnString();
  final searchQuery = ''.obs;
  final scrollController = ScrollController();

  int _page = 1;
  int _totalPages = 1;
  Timer? _debounce;
  static const int _limit = 15;

  @override
  void onInit() {
    super.onInit();
    programName.value = initialProgramName;
    fetchStats();
    fetchClients(reset: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final pos = scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      loadMoreClients();
    }
  }

  Future<void> fetchStats() async {
    try {
      isStatsLoading.value = true;
      statsError.value = null;

      final data =
          await MerchantProgramsApiClient.getProgramClientsStats(programId);

      totalClients.value = data.members;
      stats.value = _mapStats(data);
    } catch (e) {
      statsError.value = e.toString();
    } finally {
      isStatsLoading.value = false;
    }
  }

  List<ProgramStat> _mapStats(ProgramClientsStatsModel data) {
    return [
      ProgramStat(icon: Iconsax.people, value: '${data.members}', title: 'stat_members'),
      ProgramStat(icon: Iconsax.tick_circle, value: '${data.active}', title: 'stat_active'),
      ProgramStat(icon: Iconsax.close_circle, value: '${data.inactive}', title: 'stat_inactive'),
      ProgramStat(icon: Iconsax.crown, value: '${data.vip}', title: 'stat_vip'),
      ProgramStat(icon: Iconsax.user_add, value: '${data.newThisMonth}', title: 'stat_new_month'),
      ProgramStat(icon: Iconsax.chart_2, value: '${data.retentionRate}%', title: 'stat_retention'),
      ProgramStat(icon: Iconsax.wallet_2, value: '${data.totals.pointsHeld}', title: 'stat_points_held'),
      ProgramStat(icon: Iconsax.shop, value: '${data.totals.visits}', title: 'stat_visits'),
    ];
  }

  Future<void> fetchClients({bool reset = false}) async {
    try {
      if (reset) {
        isClientsLoading.value = true;
        clientsError.value = null;
        _page = 1;
      }

      final result = await MerchantProgramsApiClient.getProgramClients(
        programId: programId,
        search: searchQuery.value,
        page: _page,
        limit: _limit,
      );

      _totalPages = result.totalPages;
      clients.value = reset ? result.data : [...clients, ...result.data];
      totalClients.value = result.total ; 
    } catch (e) {
      clientsError.value = e.toString();
    } finally {
      isClientsLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> loadMoreClients() async {
    if (isLoadingMore.value || isClientsLoading.value) return;
    if (_page >= _totalPages) return;

    isLoadingMore.value = true;
    _page++;
    await fetchClients();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchClients(reset: true);
    });
  }

  void freezeProgram() {
    programActive.toggle();
    // TODO: call freeze/unfreeze endpoint here
  }
}