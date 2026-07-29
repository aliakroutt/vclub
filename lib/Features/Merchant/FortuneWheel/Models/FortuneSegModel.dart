import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FortuneSegmentModel {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController winPercentController = TextEditingController();
  final TextEditingController maxWinnersController = TextEditingController();

  final TextEditingController discountController = TextEditingController();
  final TextEditingController bonusPointsController = TextEditingController();
  final TextEditingController cashbackController = TextEditingController();

  final RxString type;
  final Rx<Color> color;

  FortuneSegmentModel({
    String segmentType = "gift",
    Color segmentColor = const Color(0xFF4F46E5),
  })  : type = segmentType.obs,
        color = segmentColor.obs;
}