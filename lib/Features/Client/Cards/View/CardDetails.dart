import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/theme_service.dart';

import 'package:vclub/Features/Client/Cards/View/Widgets/AnimatedCard.dart';
import 'package:vclub/Features/Client/Cards/View/Widgets/CardsDetailsExtra.dart';
import 'package:vclub/Features/Client/Dashboard/Models/ClientCardsModel.dart';

class CardDetails extends StatefulWidget {
  final ClientCardModel card;
  const CardDetails({super.key, required this.card});

  @override
  State<CardDetails> createState() => _CardDetailsState();
}

class _CardDetailsState extends State<CardDetails> {
  final GlobalKey previewCard = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isRTL = Get.locale?.languageCode == 'ar';
    final isDark = Get.find<ThemeService>().isDarkMode.value;

    return Scaffold(
     
      body: SafeArea(
        child:  Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacer(),
               Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: _circleButton(
                      context,
                      icon: isRTL
                          ? Iconsax.arrow_right_3_copy
                          : Iconsax.arrow_left_2_copy,
                      onTap: () => Get.back(),
                    )),
                Spacer(),
                Padding(
                   padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: LoyaltyCardViewAnimated(card: widget.card),
                ),
                Spacer(),
                 LoyaltyCardDetailsPanel(card: widget.card,onAppleWallet: (){}, onGoogleWallet: (){},),
                // 3 quick action cards: Show QR / Google Wallet / Apple Wallet
            //  LoyaltyQuickActionsRow(
            //       card: widget.card,
            //       onGoogleWallet: () {
                    
            //       },
            //       onAppleWallet: () {
                   
            //       },
            //     ),
            //     SizedBox(height: size.height * 0.03),

               
            //     LoyaltyCardStatsSection(card: widget.card),

                // SizedBox(height: size.height * 0.05),
              ],
            ),
        
        
      ),
    );
  }
}

Widget _circleButton(
    BuildContext context, {
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Get.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(.3)
                  : Colors.black.withOpacity(.2),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }