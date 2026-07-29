import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Navigation/app_navigator.dart';
import 'package:vclub/Core/Widgets/animated_entry.dart';
import 'package:vclub/Features/Auth/Views/Login.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';

class SuccessChanegePassword extends StatefulWidget {
  const SuccessChanegePassword({super.key});

  @override
  State<SuccessChanegePassword> createState() => _SuccessChanegePasswordState();
}

class _SuccessChanegePasswordState extends State<SuccessChanegePassword> {
  @override
  Widget build(BuildContext context) {
     final size = MediaQuery.of(context).size;
    return WillPopScope(
        onWillPop: () async => false, // Disable system back button
        child: KeyboardDismissOnTap(child:  Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body:SingleChildScrollView( // ✅ scroll when keyboard appears
        physics: const ClampingScrollPhysics(),
        child: SizedBox(
          height: size.height, // ✅ full screen height
          child:  Stack(
        children: [
          Positioned(
            top: -size.height * 0.05,
            right: -size.width * 0.25,
            child: BackgroundCircle(
              size: size.width * 0.7,
              innerSize: size.width * 0.45,
            ),
          ),
          

          Positioned(
            bottom: -size.height * 0.05,
            left: -size.width * 0.20,
            child: BackgroundCircle(
              size: size.width * 0.55,
              innerSize: size.width * 0.35,
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal:size.width * 0.05 ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// ───────── ICON
                FadeSlide(
                  delayMs: 100,
                  child: Container(
                    width: size.width * .28,
                    height: size.width * .28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary.withOpacity(.08),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(.15),
                          blurRadius: 40,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Iconsax.tick_circle,
                      size: size.width * .14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
            
                SizedBox(height: size.height * .04),
            
                /// ───────── TITLE
                FadeSlide(
                  delayMs: 250,
                  child: AppText(
                    "success_title",
                    fontSize: size.width * .07,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.center,
                  ),
                ),
            
                SizedBox(height: size.height * .02),
            
                /// ───────── SUBTITLE
                FadeSlide(
                  delayMs: 400,
                  child: AppText(
                    "success_message",
                    textAlign: TextAlign.center,
                    fontSize: size.width * .04,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(.65),
                  ),
                ),
            
                SizedBox(height: size.height * .06),
            
                /// ───────── BUTTON
                FadeSlide(
                  delayMs: 600,
                  child: SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed: () {
                        AppNavigator.to(Login());
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: AppColors.primary ,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: AppText(
                        "sign_in_bt",
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
         
        ],
      ))),
    )));
  }
}