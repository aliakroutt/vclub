import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Models/MerchantNotificationsSendModel.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/Services/MerchantNotificationsService.dart';


class MerchantNotificationsController extends GetxController {
  final RxList<MerchantNotificationModel> notifications =
      <MerchantNotificationModel>[].obs;

  final RxBool loading = false.obs;
  final RxBool loadingMore = false.obs;
  final RxString error = "".obs;

  final RxBool initialLoaded = false.obs;

  final RxInt currentPage = 1.obs;
  final RxInt totalPages = 1.obs;
  final RxInt totalItems = 0.obs;

  bool get hasMore => currentPage.value < totalPages.value;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 1;
        // notifications.clear();
      }

      if (!initialLoaded.value) {
        loading.value = true;
      }

      error.value = "";

      final result = await MerchantNotificationsApiClient.getNotifications(
        page: currentPage.value,
      );

      notifications.assignAll(result.data);

      totalItems.value = result.total;
      totalPages.value = result.totalPages;

      initialLoaded.value = true;
    } catch (e) {
      error.value = "failed_load_notifications".tr;
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (loadingMore.value) return;
    if (!hasMore) return;

    try {
      loadingMore.value = true;

      currentPage.value++;

      final result =
          await MerchantNotificationsApiClient.getNotifications(
        page: currentPage.value,
      );

      notifications.addAll(result.data);

      totalItems.value = result.total;
      totalPages.value = result.totalPages;
    } finally {
      loadingMore.value = false;
    }
  }

  Future<void> refreshNotifications() async {
    currentPage.value = 1;
    await fetchNotifications(refresh: true);
  }
}