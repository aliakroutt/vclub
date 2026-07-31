
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Merchant/Analytics/View/AnalyticsScreen.dart';
import 'package:vclub/Features/Merchant/Billing/View/Billing.dart';
import 'package:vclub/Features/Merchant/Clients/View/MerchantClients.dart';
import 'package:vclub/Features/Merchant/Dashboard/View/MerchantDashboard.dart';
import 'package:vclub/Features/Merchant/Employee/View/Employe.dart';
import 'package:vclub/Features/Merchant/FortuneWheel/View/FortuneWheelHome.dart';
import 'package:vclub/Features/Merchant/GoogleReview/View/MerchantGoogleReview.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/ListPrograms.dart';
import 'package:vclub/Features/Merchant/Rewards/View/MerchantRewards.dart';
import 'package:vclub/Features/Merchant/Settings/View/Settings.dart';


class MerchantMainController extends GetxController {
var selectedIndex = 0.obs;
var selectedIndexNavbar = 0.obs;

  final pages = [
  MerchantDashboard(),
  ListPrograms(),
  MerchantRewards(),
  FortuneWheelHome(),
  Employe(),
  MerchantClients(),
  Center(child: AppText("campaigns_merchant".tr)),
  AnalyticsScreen(),
  MerchantGoogleReview(),
  Settings(),
  Billing(),
];

  void selectIndex(int index) {
    selectedIndex.value = index;
  }

  void selectIndexNavBar(int index) {
    selectedIndexNavbar.value = index;
  }
 

} 