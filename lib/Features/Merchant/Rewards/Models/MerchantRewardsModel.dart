import 'package:flutter/material.dart';

class RewardModel {
  String type;
  int points;
  double discount;
  bool active;

  /// Controllers (for UI binding)
  TextEditingController nameController;
  TextEditingController pointsController;
  TextEditingController discountController;

  RewardModel({
    this.type = "reward_free_item",
    this.points = 0,
    this.discount = 0,
    this.active = true,
  })  : nameController = TextEditingController(),
        pointsController = TextEditingController(),
        discountController = TextEditingController();

  /// Convert to JSON (for API)
  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "points": points,
      "discount": discount,
      "active": active,
      "name": nameController.text,
    };
  }

  /// Factory from API
  factory RewardModel.fromJson(Map<String, dynamic> json) {
    final model = RewardModel(
      type: json["type"] ?? "reward_free_item",
      points: json["points"] ?? 0,
      discount: (json["discount"] ?? 0).toDouble(),
      active: json["active"] ?? true,
    );

    model.nameController.text = json["name"] ?? "";
    model.pointsController.text = model.points.toString();
    model.discountController.text = model.discount.toString();

    return model;
  }
}