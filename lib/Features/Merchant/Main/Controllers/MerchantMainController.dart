import 'package:get/get.dart';
import 'package:vclub/Features/Merchant/Analytics/View/AnalyticsScreen.dart';
import 'package:vclub/Features/Merchant/Audit/View/AuditScreen.dart';
import 'package:vclub/Features/Merchant/Avtivity/View/ActivityScreen.dart';
import 'package:vclub/Features/Merchant/Billing/View/Billing.dart';
import 'package:vclub/Features/Merchant/Clients/View/MerchantClients.dart';
import 'package:vclub/Features/Merchant/Compains/View/Compains.dart';
import 'package:vclub/Features/Merchant/Dashboard/View/MerchantDashboard.dart';
import 'package:vclub/Features/Merchant/Employee/View/Employe.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/FortuneWheelHome.dart';
import 'package:vclub/Features/Merchant/GoogleReview/View/MerchantGoogleReview.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/ListPrograms.dart';
import 'package:vclub/Features/Merchant/NotificationsMerchant/View/NotificationsSend/NotificationsSend.dart';
import 'package:vclub/Features/Merchant/Redemptions/View/RedemptionsScreen.dart';
import 'package:vclub/Features/Merchant/Rewards/View/MerchantRewards.dart';
import 'package:vclub/Features/Merchant/Settings/View/Settings.dart';



class MerchantMainController extends GetxController {
var selectedIndex = 0.obs;
var selectedIndexNavbar = 0.obs;

  final pages = [
  MerchantDashboard(),        // 0
  ListPrograms(),              // 1
  MerchantRewards(),           // 2
  FortuneWheelHome(),          // 3
  Employe(),                   // 4
  MerchantClients(),           // 5
  Compains(),                  // 6
  AnalyticsScreen(),           // 7
  NotificationsSend(),         // 8
  MerchantGoogleReview(),      // 9
  Settings(),                  // 10
  Billing(),                   // 11
  ActivityScreen(),            // 12 - Traceability: Activity
  RedemptionsScreen(),         // 13 - Traceability: Redemptions
  AuditScreen(),                // 14 - Traceability: Audit
];

  void selectIndex(int index) {
    selectedIndex.value = index;
  }

  void selectIndexNavBar(int index) {
    selectedIndexNavbar.value = index;
  }
 

}