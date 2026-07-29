// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Auth/Widgets/BackgroundCercle.dart';

class PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String duration;
  final List<String> features;
  final bool isSelected;
  final bool isPopular;
  final VoidCallback onTap;

  const PlanCard({
    super.key,
    required this.title,
    required this.price,
    required this.duration,
    required this.features,
    required this.onTap,
    this.isSelected = false,
    this.isPopular = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(size.width * 0.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Get.locale?.languageCode == 'ar'
            ? Positioned(
              top: 10 ,
              left: 10 ,
              child:  Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      BackgroundCircle(
                        size: size.width * 0.3,
                        innerSize: size.width * 0.2,
                      ),
                      BackgroundCircle(
                        size: size.width * 0.1,
                        innerSize: size.width * 0.05,
                      ),
                    ],
                  ),
                
              ),
            )
           : Positioned(
              top: 10 ,
              right: 10 ,
              child:  Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      BackgroundCircle(
                        size: size.width * 0.3,
                        innerSize: size.width * 0.2,
                      ),
                      BackgroundCircle(
                        size: size.width * 0.1,
                        innerSize: size.width * 0.05,
                      ),
                    ],
                  ),
                
              ),
            ),

            Padding(
              padding: EdgeInsets.all(size.width * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// TOP ROW — Title + Popular badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppText(
                        title,
                        fontSize: size.width * 0.045,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                      if (isPopular) ...[
                        SizedBox(width: size.width * 0.03),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: size.width * 0.03,
                            vertical: size.height * 0.004,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: AppText(
                            "popular".tr.toUpperCase(),
                            translate: false,
                            fontSize: size.width * 0.028,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: size.height * 0.012),

                  /// PRICE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AppText(
                        price,
                        fontSize: size.width * 0.1,
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      SizedBox(width: 6),
                      Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.008),
                        child: AppText(
                          "/ $duration",
                          fontSize: size.width * 0.032,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.018),

                  /// SPARKLE DIVIDER
                  _SparkDivider(color: AppColors.primary),

                  SizedBox(height: size.height * 0.018),

                  /// FEATURES
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: features.map((f) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: size.height * 0.02),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _TealCheckBadge(size: size.width * 0.055),
                            SizedBox(width: size.width * 0.03),
                            Expanded(
                              child: AppText(
                                f,
                                fontSize: size.width * 0.036,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: size.height * 0.02),

                  /// SELECT BUTTON
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.016,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Center(
                      child: AppText(
                        isSelected ? "selected".tr : "select_plan".tr,
                        fontSize: size.width * 0.038,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            /// SELECTED CHECKMARK — top right corner
            if (isSelected)
             Get.locale?.languageCode == 'ar'  
             ? Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: size.width * 0.07,
                  height: size.width * 0.07,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: size.width * 0.045,
                  ),
                ),
              )
            : Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: size.width * 0.07,
                  height: size.width * 0.07,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: size.width * 0.045,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Teal hexagonal / badge check icon matching the screenshots
class _TealCheckBadge extends StatelessWidget {
  final double size;
  const _TealCheckBadge({required this.size});

  @override
  Widget build(BuildContext context) {
    return Icon(Iconsax.verify, color: AppColors.primary, size: size * 1);
  }
}

/// Horizontal divider with a sparkle ✦ in the centre
class _SparkDivider extends StatelessWidget {
  final Color color;
  const _SparkDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color.withOpacity(0.25), thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(Icons.auto_awesome, size: 16, color: color),
        ),
        Expanded(child: Divider(color: color.withOpacity(0.25), thickness: 1)),
      ],
    );
  }
}
