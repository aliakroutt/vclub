import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ClientTabController extends GetxController {
  var selectedIndex = 0.obs;

  late PageController pageController;

  @override
  void onInit() {
    pageController = PageController();
    super.onInit();
  }

  void changeTab(int index) {
  if (selectedIndex.value == index) return;

  selectedIndex.value = index;

  pageController.animateToPage(
    index,
    duration: const Duration(milliseconds: 300),
    curve: Curves.easeInOut,
  );
}

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}