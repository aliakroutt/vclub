import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Client/Notifications/Models/ClientNotificationsModel.dart';
import 'package:vclub/Features/Client/Notifications/Services/NotificationsApiClient.dart';

class NotificationsController extends GetxController {
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  final RxBool notificationsLoading = false.obs;

  final RxBool loadingMore = false.obs;

  final RxString notificationsError = "".obs;

  final RxInt currentPage = 1.obs;

  final RxInt totalPages = 1.obs;

  final RxInt unread = 0.obs;

  final RxBool initialLoaded = false.obs;
  final RxBool markAllLoading = false.obs;

  // mark all read
  Future<void> markAllNotificationsAsRead() async {
    if (markAllLoading.value) return;

    try {
      markAllLoading.value = true;

      await NotificationsApiClient.markNotificationAsReadAll();

      await fetchNotifications();
      markAllLoading.value = false;
    } catch (e) {
      markAllLoading.value = false;
      debugPrint(e.toString());
    } finally {
    }
  }

  // get notifications
  Future<void> fetchNotifications() async {
    try {
      if (!initialLoaded.value) {
        notificationsLoading.value = true;
      }
      notificationsError.value = "";
      currentPage.value = 1;
      final result = await NotificationsApiClient.getNotifications(
        page: currentPage.value,
        limit: 20,
      );
      notifications.assignAll(result.notifications);
      unread.value = result.unread;
      totalPages.value = result.totalPages;
      initialLoaded.value = true;
    } catch (e) {
      notificationsError.value = "failed_load_notifications".tr;
      AppSnackBar.error("failed_load_notifications".tr);
    } finally {
      notificationsLoading.value = false;
    }
  }

  // load more
  Future<void> loadMoreNotifications() async {
    if (loadingMore.value) return;
    if (currentPage.value >= totalPages.value) {
      return;
    }
    try {
      loadingMore.value = true;
      final nextPage = currentPage.value + 1;
      final result = await NotificationsApiClient.getNotifications(
        page: nextPage,
        limit: 20,
      );
      notifications.addAll(result.notifications);
      currentPage.value = result.page;
      totalPages.value = result.totalPages;
    } catch (e) {
      AppSnackBar.error("failed_load_notifications".tr);
    } finally {
      loadingMore.value = false;
    }
  }

  // mark notif use read
  Future<void> markNotificationAsRead(String notifId) async {
    try {
      await NotificationsApiClient.markNotificationAsRead(notifId);

      // reload notifications after success
      await fetchNotifications();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void resetNotifications() {
    // Clear list
    notifications.clear();

    // Reset pagination
    currentPage.value = 1;
    totalPages.value = 1;

    // Reset counters
    unread.value = 0;
    // Reset states
    notificationsLoading.value = false;
    loadingMore.value = false;
    notificationsError.value = "";
    // Reset first load
    initialLoaded.value = false;
  }
}
