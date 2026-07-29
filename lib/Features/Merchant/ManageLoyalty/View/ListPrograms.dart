import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/Controllers/MerchantProgramsController.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/LoyaltyProgramsList.dart';
import 'package:vclub/Features/Merchant/ManageLoyalty/View/Widgets/ProgramsSearchBar.dart';

class ListPrograms extends StatefulWidget {
  const ListPrograms({super.key});

  @override
  State<ListPrograms> createState() => _ListProgramsState();
}

class _ListProgramsState extends State<ListPrograms> {
  final controller = MerchantProgramsController.to;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

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

                  Align(
                    alignment: isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 200,
                      child: AppText(
                        "manage_programs",
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.01),

                  Align(
                    alignment: isRTL
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: FadeSlide(
                      delayMs: 250,
                      child: AppText(
                        'manage_programs_description',
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                   FadeSlide(
  delayMs: 300,
  child: const NewProgramSearchBar(),
),
                  SizedBox(height: size.height * 0.02),
                  FadeSlide(
                    delayMs: 350,
                    child: SizedBox(
                      height: size.height*0.62,
                      child: ProgramsListCard(
                      ),
                    ),
                  ),

                  // SizedBox(height: size.height * 0.15),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
