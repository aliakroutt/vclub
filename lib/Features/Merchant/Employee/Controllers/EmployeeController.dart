import 'dart:async';
import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Employee/Models/EmployesModel.dart';
import 'package:vclub/Features/Merchant/Employee/Services/ApiErrorHnadler.dart';
import 'package:vclub/Features/Merchant/Employee/Services/MerchantEmployeeApiClient.dart';

class EmployeeController extends GetxController {
  final employees = <EmployeeModel>[].obs;

  final isLoading = false.obs;       // first load / search reset
  final isLoadingMore = false.obs;   // pagination
  final hasError = false.obs;

  final searchQuery = ''.obs;

  int _page = 1;
  final int _limit = 10;
  int _totalPages = 1;
  Timer? _debounce;

  bool get hasMore => _page < _totalPages;

  @override
  void onInit() {
    super.onInit();
    fetchEmployees(reset: true);
  }

  Future<void> fetchEmployees({required bool reset}) async {
    if (reset) {
      _page = 1;
      hasError.value = false;
      isLoading.value = true;
    }

    try {
      final result = await MerchantEmployeeApiClient.getEmployees(
        page: _page,
        limit: _limit,
        search: searchQuery.value,
      );

      _totalPages = result.totalPages;

      if (reset) {
        employees.assignAll(result.data);
      } else {
        employees.addAll(result.data);
      }
    } catch (e) {
      if (reset) {
        hasError.value = true;
        employees.clear();
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
    await fetchEmployees(reset: false);
  }

  void onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 450), () {
      searchQuery.value = value;
      fetchEmployees(reset: true);
    });
  }

  Future<void> refresh() => fetchEmployees(reset: true);

  Future<bool> deleteEmployee(String id) async {
  try {
    await MerchantEmployeeApiClient.deleteEmployee(id);
    employees.removeWhere((e) => e.id == id);
    return true;
  } catch (e) {
    AppSnackBar.error(ApiErrorHandler.extract(e));
    return false;
  }
}

  final RxBool isSubmitting = false.obs;

Future<bool> createEmployee(Map<String, dynamic> payload) async {
  try {
    isSubmitting.value = true;
    final created = await MerchantEmployeeApiClient.createEmployee(payload);
    employees.insert(0, created);
    return true;
  } catch (e) {
    AppSnackBar.error(ApiErrorHandler.extract(e));
    return false;
  } finally {
    isSubmitting.value = false;
  }
}

Future<bool> updateEmployee(String id, Map<String, dynamic> payload) async {
  try {
    isSubmitting.value = true;
    final updated = await MerchantEmployeeApiClient.updateEmployee(id, payload);
    final index = employees.indexWhere((e) => e.id == id);
    if (index != -1) employees[index] = updated;
    return true;
  } catch (e) {
    AppSnackBar.error(ApiErrorHandler.extract(e));
    return false;
  } finally {
    isSubmitting.value = false;
  }
}

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}