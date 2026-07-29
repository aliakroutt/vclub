import 'package:get/get.dart';

class SignUpController extends GetxController {
  RxString selectedRole = "client".obs;

  void changeRole(String role) {
    selectedRole.value = role;
  }
}