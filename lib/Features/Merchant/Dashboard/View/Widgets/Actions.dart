import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Features/Client/QRScanner/View/QrScanner.dart';
import 'package:vclub/Features/Merchant/Main/Controllers/MerchantMainController.dart';

class DashboardActions extends StatelessWidget {
  const DashboardActions({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
   final controller = Get.put(MerchantMainController());
    final actions = [
      (
        title: "scan_client_dash".tr,
        subtitle: "scan_client_subtitle_dash".tr,
        icon: Iconsax.scan_barcode,
        color: const Color(0xFF6C5CE7),
      ),
      (
        title: "clients_dash".tr,
        subtitle: "clients_subtitle_dash".tr,
        icon: Iconsax.profile_2user,
        color: const Color(0xFF00B894),
      ),
      (
        title: "rewards_dash".tr,
        subtitle: "rewards_subtitle_dash".tr,
        icon: Iconsax.gift,
        color: const Color(0xFFFF8A00),
      ),
      (
        title: "loyalty_program_dash".tr,
        subtitle: "loyalty_program_subtitle_dash".tr,
        icon: Iconsax.crown,
        color: const Color(0xFF0984E3),
      ),
    ];

    return Column(
      children: List.generate(
        actions.length,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: size.height * .015),
          child: DashboardActionCard(
            title: actions[i].title,
            subtitle: actions[i].subtitle,
            icon: actions[i].icon,
            color: actions[i].color,
            onTap: () {
            if ( i == 0) {
             Get.to(QrScannerScreen());
            } else if (i==1) {
              controller.selectIndex(5);
            }else if (i==2){
               controller.selectIndex(2);
            } else if (i==3) {
             controller.selectIndex(1);
            } else {

            }
            },
          ),
        ),
      ),
    );
  }
}

class DashboardActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashboardActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Ink(
          padding: EdgeInsets.all(size.width * .045),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            color: Theme.of(context).colorScheme.surface,
            border: Border.all(
              color: isDark
                  ? Colors.white.withOpacity(.06)
                  : Colors.black.withOpacity(.05),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? .22 : .04),
                blurRadius: 18,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              /// ICON
              Container(
                width: size.width * .145,
                height: size.width * .145,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(.20),
                      color.withOpacity(.06),
                    ],
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: size.width * .06,
                ),
              ),

              SizedBox(width: size.width * .04),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      title,
                      fontSize: size.width * .039,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: size.height * .006),
                    AppText(
                      subtitle,
                      fontSize: size.width * .031,
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withOpacity(.55),
                    ),
                  ],
                ),
              ),

              /// ARROW
              Container(
                width: size.width * .10,
                height: size.width * .10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(.10),
                ),
                child: Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Iconsax.arrow_circle_left
                      : Iconsax.arrow_circle_right,
                  color: color,
                  size: size.width * .045,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}