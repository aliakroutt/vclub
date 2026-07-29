import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Client/MyQrCodes/View/Widgets/Cards.dart';

class MyQrCodes extends StatefulWidget {
  const MyQrCodes({super.key});

  @override
  State<MyQrCodes> createState() => _MyQrCodesState();
}

class _MyQrCodesState extends State<MyQrCodes> {
  @override
  Widget build(BuildContext context) {
   final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';

    return Scaffold(
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
                  child:  FadeSlide(
              delayMs: 200,
              child : AppText(
                    'my_qr_code',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  )),
                ),

                SizedBox(height: size.height * 0.01),

                Align(
                  alignment: isRTL
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child:  FadeSlide(
              delayMs: 250,
              child : AppText(
                    "qr_subtitle",
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color?.withOpacity(0.7),
                  )),
                ),
                SizedBox(height: size.height * 0.02),
             FadeSlide(
              delayMs: 300,
              child :  QrCodesScreen()),

                SizedBox(height: size.height * 0.05),
              ],
            ),
          ),
        ),
      ),
    );
  }
}