import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Settings/Models/SessionModel.dart';
import 'package:vclub/Features/Merchant/Settings/Services/SettingsApiClient.dart';

class SessionsController extends GetxController {
  final RxList<SessionModel> sessions = <SessionModel>[].obs;

  final RxBool loading = false.obs;
  final RxBool hasError = false.obs;
  final RxBool initialLoaded = false.obs;

  /// jti currently being revoked, so only that row shows a loader.
  final RxString revokingJti = "".obs;

  @override
  void onInit() {
    super.onInit();
    fetchSessions();
  }

  Future<void> fetchSessions() async {
    try {
      loading.value = true;
      hasError.value = false;

      final result = await SettingsApiClient.getSessions();
      sessions.assignAll(result);

      hasError.value = false;
    } catch (e) {
      hasError.value = true;
    } finally {
      loading.value = false;
      initialLoaded.value = true;
    }
  }

  Future<void> revokeSession(String jti) async {
    try {
      revokingJti.value = jti;
      await SettingsApiClient.revokeSession(jti);

      sessions.removeWhere((s) => s.jti == jti);
      AppSnackBar.success("session_revoked".tr);
    } catch (e) {
      AppSnackBar.error("session_revoke_failed".tr);
    } finally {
      revokingJti.value = "";
    }
  }

  Future<void> refresh() => fetchSessions();
}