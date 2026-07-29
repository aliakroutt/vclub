import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';

class QrScanCard extends StatelessWidget {
  final Color color;

  const QrScanCard({super.key, required this.color});

  void _showQrDialog(Color color) {
  Get.dialog(
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.6),

    // 🔥 IMPORTANT: full screen tap detector
    Material(
      color: Colors.transparent,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,

        // tap outside closes
        onTap: () => Get.back(),

        child: Center(
          // 🔥 prevents closing when tapping QR itself
          child: GestureDetector(
            onTap: () {},

            child: Container(
              width: 280,
              height: 280,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  Iconsax.scan_barcode,
                  size: 200,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🧾 QR CODE (CLICKABLE)
          GestureDetector(
            onTap: () => _showQrDialog(AppColors.primary),
            child: Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Icon(
                Iconsax.scan_barcode,
                size: 100,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // 🔘 BUTTONS COLUMN
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _WalletButton(
                  label: "Google Wallet",
                  icon: Iconsax.wallet_3,
                  color: color,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _WalletButton(
                  label: "Apple Wallet",
                  icon: Iconsax.apple,
                  color: color,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WalletButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: AppColors.primary,
          border: Border.all(color: AppColors.primary),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}