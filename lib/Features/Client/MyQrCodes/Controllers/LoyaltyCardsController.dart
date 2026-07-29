import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Features/Client/MyQrCodes/Models/LoyaltyCardModel.dart';

class LoyaltyController extends GetxController {
  var selectedIndex = 0.obs;

  final cards = <LoyaltyCardModel>[
    LoyaltyCardModel(
      id: "1",
      name: "Starbucks",
      type: "Bronze",
      points: 240,
      targetPoints: 500,
      icon: Iconsax.coffee,
    ),

    LoyaltyCardModel(
      id: "5",
      name: "McDonald's",
      type: "Bronze",
      points: 60,
      targetPoints: 250,
      icon: Iconsax.cup,
    ),
    LoyaltyCardModel(
      id: "6",
      name: "Sephora",
      type: "Platinum",
      points: 1450,
      targetPoints: 1500,
      icon: Iconsax.brush_1,
    ),
  ];

  void selectCard(int index) {
    selectedIndex.value = index;
  }
}
