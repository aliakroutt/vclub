import 'package:get/get.dart';
import 'package:vclub/Features/Staff/Activity/View/StaffActivityScreen.dart';
import 'package:vclub/Features/Staff/Dashboard/View/StaffHomeScreen.dart';
import 'package:vclub/Features/Staff/Profile/View/StaffProfileScreen.dart';

class StaffMainController extends GetxController {
  var selectedIndex = 0.obs;
  var selectedIndexNavbar = 0.obs;

  final pages = [
    StaffHomeScreen(),      // 0 - Home
    StaffActivityScreen(),  // 1 - Activity
    StaffProfileScreen(),   // 2 - Profile
  ];

  void selectIndex(int index) {
    selectedIndex.value = index;
  }

  void selectIndexNavBar(int index) {
    selectedIndexNavbar.value = index;
  }
}