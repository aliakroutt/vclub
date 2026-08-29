import 'dart:io';
import 'package:get/get.dart';
import 'package:vclub/Core/Cloudinary/CloudinaryService.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/ClientController.dart';
import 'package:vclub/Core/Widgets/AppLoader.dart';
import 'package:vclub/Features/Client/MyProfile/View/Service/ClientUpdateService.dart';

class UpdateAvatarController extends GetxController {
  final RxBool isUploading = false.obs;

  Future<bool> uploadAvatar(File file) async {
    if (isUploading.value) return false;

    try {
      isUploading.value = true;
      AppLoader.show();

      final avatarUrl = await CloudinaryService.uploadImage(file);

      if (avatarUrl == null) {
        AppLoader.hide();
        AppSnackBar.error("avatar_upload_failed".tr);
        return false;
      }

      final updatedClient = await UpdateProfileApiClient.updateProfile({
        "avatar": avatarUrl,
      });

      await ClientController.to.saveClient(updatedClient);
      ClientController.to.client.value = updatedClient;

      AppLoader.hide();
      AppSnackBar.success("avatar_updated".tr);
      return true;
    } catch (e) {
      AppLoader.hide();
      AppSnackBar.error("avatar_update_failed".tr);
      return false;
    } finally {
      isUploading.value = false;
    }
  }
}