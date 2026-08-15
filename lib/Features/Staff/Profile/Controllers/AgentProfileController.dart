import 'package:get/get.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/AgentController.dart';
import 'package:vclub/Features/Auth/Services/AgentService.dart';
import 'package:vclub/Features/Staff/Profile/Services/AgentProfileApiClient.dart';

class AgentProfileController extends GetxController {
  final RxBool isUpdatingName = false.obs;

  Future<bool> updateName({required String firstName, required String lastName}) async {
    final trimmedFirst = firstName.trim();
    final trimmedLast = lastName.trim();

    if (trimmedFirst.isEmpty || trimmedLast.isEmpty) {
      AppSnackBar.error("agent_name_required".tr);
      return false;
    }

    try {
      isUpdatingName.value = true;

      await AgentProfileApiClient.updateName(firstName: trimmedFirst, lastName: trimmedLast);

      // Re-fetch and persist the updated profile so the change reflects
      // everywhere (profile card, drawer/app bar greeting, etc.).
      final profile = await AgentService.profile();
      if (profile != null) {
        await AgentController.to.saveAgent(profile);
      }

      AppSnackBar.success("agent_name_updated".tr);
      return true;
    } catch (e) {
      AppSnackBar.error("agent_name_update_failed".tr);
      return false;
    } finally {
      isUpdatingName.value = false;
    }
  }
}