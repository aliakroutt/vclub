import 'package:get/get.dart';
import 'package:vclub/Features/Client/FortuneWheel/Models/FortuneWheelModels.dart';
import 'package:vclub/Features/Client/FortuneWheel/Services/FortuneWheelApiClient.dart';

class FortuneWheelController extends GetxController {
  static FortuneWheelController get to => Get.find();

  final RxList<ClientCompanyModel> companies = <ClientCompanyModel>[].obs;
  final Rx<ClientCompanyModel?> selectedCompany = Rx<ClientCompanyModel?>(null);
  final Rx<WheelModel?> wheel = Rx<WheelModel?>(null);
  final RxList<WheelHistoryItemModel> history = <WheelHistoryItemModel>[].obs;

  final RxBool loadingCompanies = false.obs;
  final RxBool loadingWheel = false.obs;
  final RxBool spinning = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  int get totalWins => history.where((h) => h.isWin).length;
  int get availableCompaniesCount => companies.length;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      loadingCompanies.value = true;
      hasError.value = false;

      final results = await Future.wait([
        FortuneWheelApiClient.getMemberships(),
        FortuneWheelApiClient.getHistory(),
      ]);

      final companyList = results[0] as List<ClientCompanyModel>;
      final historyList = results[1] as List<WheelHistoryItemModel>;

      final seen = <String>{};
      final uniqueCompanies = companyList
          .where((c) => c.companyId.isNotEmpty)
          .where((c) => seen.add(c.companyId))
          .toList();

      companies.assignAll(uniqueCompanies);
      history.assignAll(historyList);

      if (uniqueCompanies.isNotEmpty) {
        final keepSelected = selectedCompany.value != null &&
            uniqueCompanies.any((c) => c.companyId == selectedCompany.value!.companyId);

        if (!keepSelected) {
          selectedCompany.value = uniqueCompanies.first;
        }
        await fetchWheel(selectedCompany.value!.companyId);
      }

      hasError.value = false;
    } catch (e) {
      hasError.value = true;
      companies.clear();
    } finally {
      loadingCompanies.value = false;
      initialLoaded.value = true;
    }
  }

  Future<void> fetchWheel(String companyId) async {
    try {
      loadingWheel.value = true;
      wheel.value = await FortuneWheelApiClient.getWheel(companyId);
    } catch (e) {
      wheel.value = null;
    } finally {
      loadingWheel.value = false;
    }
  }

  void selectCompany(ClientCompanyModel company) {
    if (selectedCompany.value?.companyId == company.companyId) return;
    selectedCompany.value = company;
    fetchWheel(company.companyId);
  }

  Future<WheelSpinResult?> spin() async {
    final w = wheel.value;
    if (w == null) return null;

    try {
      spinning.value = true;
      final result = await FortuneWheelApiClient.spin(w.id);
      return result;
    } catch (e) {
      return null;
    } finally {
      spinning.value = false;
    }
  }

  Future<void> refresh() => fetchAll();

  // =========================
  // RESET
  // =========================
  /// Clears companies, wheel, history, and selection state back to initial
  /// values. Call this on logout so the next fetch starts clean and
  /// doesn't briefly flash a previous client's wheel data.
  void resetControllerData() {
    companies.clear();
    selectedCompany.value = null;
    wheel.value = null;
    history.clear();

    loadingCompanies.value = false;
    loadingWheel.value = false;
    spinning.value = false;
    hasError.value = false;
    initialLoaded.value = false;
  }
}