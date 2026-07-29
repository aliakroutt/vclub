
import 'package:get/get.dart';
import 'package:vclub/Features/Client/Cards/View/MyCards.dart';
import 'package:vclub/Features/Client/Dashboard/View/ClientDashboard.dart';
import 'package:vclub/Features/Client/FortuneWheel/View/FortuneWheel.dart';
import 'package:vclub/Features/Client/History/View/HistoryClient.dart';
import 'package:vclub/Features/Client/MyProfile/View/ProfileClient.dart';
import 'package:vclub/Features/Client/Notifications/View/NotificationsClient.dart';
import 'package:vclub/Features/Client/Rewards/View/Rewards.dart';

class MainController extends GetxController {
var selectedIndex = 0.obs;
  final pages = [
   ClientDashboard(),  
   Mycards(),  
   MyRewards(),  
   ProfileClient(), 
   HistoryClient(),  
   FortuenWheel(),  
   NotificationsClient(),  
   
  ];

  void selectIndex(int index) {
    selectedIndex.value = index;
  }

  
 

} 