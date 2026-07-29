import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/Cards/Controllers/ClientCradsController.dart';
import 'package:vclub/Features/Client/Cards/View/Widgets/CardsModeFilterTabs.dart';
import 'package:vclub/Features/Client/Cards/View/Widgets/CardsSearchField.dart';
import 'package:vclub/Features/Client/Cards/View/Widgets/LoyaltyCardListWidget.dart';

import 'package:vclub/Features/Client/QRScanner/View/QrScanner.dart';

class Mycards extends StatefulWidget {
  const Mycards({super.key});

  @override
  State<Mycards> createState() => _MycardsState();
}

class _MycardsState extends State<Mycards> {
  final controller = ClientCardsController.to;
  @override
  void initState() {
    controller.fetchCards();
    super.initState();
  }

  @override
  void dispose() {
    controller.clearFilters();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return KeyboardDismissOnTap(
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.01),

                  FadeSlide(
                    delayMs: 200,
                    child: Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              "my_loyalty_cards_client".tr,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                            SizedBox(height: size.height * 0.01),
                            AppText(
                              "clubs_joined_client".trParams({
                                "clubs": controller.cards.length.toString(),
                              }),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Theme.of(
                                context,
                              ).textTheme.bodySmall?.color?.withOpacity(0.7),
                            ),
                          ],
                        ),

                        Spacer(),

                        // 🔥 QR BUTTON
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Get.to(QrScannerScreen());
                          },
                          child: Container(
                            height: 44,
                            width: 44,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.9),
                                  Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.6),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.qr_code_scanner_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 300, child: const CardsSearchField()),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 350, child: CardModeFilterTabs()),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(delayMs: 350, child: LoyaltyCardsList()),
                  SizedBox(height: size.height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
