import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/QRScanner/Models/ScanModels.dart';


class ClientScanConfirmDialog {
  /// Returns the confirmed amountSpent, or null if cancelled.
  static Future<double?> show({
    required ScanClientModel client,
    required ScanCardModel card,
  }) {
    return Get.dialog<double>(
      _ClientScanConfirmView(client: client, card: card),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      
    );
  }
}

class _ClientScanConfirmView extends StatefulWidget {
  final ScanClientModel client;
  final ScanCardModel card;

  const _ClientScanConfirmView({required this.client, required this.card});

  @override
  State<_ClientScanConfirmView> createState() =>
      _ClientScanConfirmViewState();
}

class _ClientScanConfirmViewState extends State<_ClientScanConfirmView> {
  final amountController = TextEditingController(text: "0");

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  IconData get _modeIcon {
    switch (widget.card.program.mode) {
      case "stamps":
        return Iconsax.ticket;
      case "cashback":
        return Iconsax.wallet_money;
      default:
        return Iconsax.star;
    }
  }

  String get _balanceLabel {
    final program = widget.card.program;
    switch (program.mode) {
      case "stamps":
        return "${widget.card.stamps}/${program.stampsPerReward}";
      case "cashback":
        return widget.card.cashbackBalance.toStringAsFixed(2);
      default:
        return "${widget.card.points}";
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return "?";
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  void _confirm() {
    final requiresAmount = widget.card.program.requiresAmount;
    final amount = double.tryParse(amountController.text.trim()) ?? 0;

    if (requiresAmount && amount <= 0) {
      AppSnackBar.error("amount_required".tr);
      return;
    }

    Get.back(result: amount);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final program = widget.card.program;

    return Material(
        type: MaterialType.transparency,
        child: Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: EdgeInsets.all(size.width * 0.06),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: isDark
                    ? const Color(0xFF15181D).withValues(alpha: 0.92)
                    : Colors.white.withValues(alpha: 0.92),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// ── AVATAR ─────────────────────────
                  Container(
                    width: size.width * 0.18,
                    height: size.width * 0.18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: AppText(
                        _initials(widget.client.fullName),
                        fontSize: size.width * 0.06,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  SizedBox(height: size.height * 0.016),

                  AppText(
                    widget.client.fullName,
                    fontSize: size.width * 0.046,
                    fontWeight: FontWeight.w800,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    widget.client.email,
                    fontSize: size.width * 0.031,
                    textAlign: TextAlign.center,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.55),
                  ),

                  SizedBox(height: size.height * 0.022),

                  /// ── PROGRAM / BALANCE CARD ────────
                  Container(
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      color: AppColors.primary.withValues(alpha: 0.08),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 0.1,
                          height: size.width * 0.1,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: AppColors.primary.withValues(alpha: 0.15),
                          ),
                          child: Icon(
                            _modeIcon,
                            color: AppColors.primary,
                            size: size.width * 0.05,
                          ),
                        ),
                        SizedBox(width: size.width * 0.03),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                program.name,
                                fontWeight: FontWeight.w700,
                                fontSize: size.width * 0.035,
                              ),
                              const SizedBox(height: 2),
                              AppText(
                                "current_balance".tr,
                                fontSize: size.width * 0.028,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.color
                                    ?.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                        AppText(
                          _balanceLabel,
                          fontWeight: FontWeight.w800,
                          fontSize: size.width * 0.042,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.02),

                  /// ── AMOUNT FIELD (only if required) ──
                  if (program.requiresAmount) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AppText(
                        "amount_spent".tr,
                        fontSize: size.width * 0.033,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: size.height * 0.008),
                    TextField(
                      controller: amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: size.width * 0.04,
                      ),
                      decoration: InputDecoration(
                        hintText: "0.00",
                        prefixIcon:
                            Icon(Iconsax.money_4, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.primary.withValues(alpha: 0.06),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                  ] else ...[
                    Row(
                      children: [
                        Icon(
                          Iconsax.info_circle,
                          size: size.width * 0.04,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.5),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Expanded(
                          child: AppText(
                            "no_amount_required".tr,
                            fontSize: size.width * 0.03,
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],

                  /// ── ACTIONS ─────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: size.height * 0.06,
                          child: OutlinedButton(
                            onPressed: () => Get.back(result: null),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              side:
                                  BorderSide(color: Theme.of(context).dividerColor),
                            ),
                            child: AppText(
                              "cancel".tr,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.03),
                      Expanded(
                        child: SizedBox(
                          height: size.height * 0.06,
                          child: ElevatedButton(
                            onPressed: _confirm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: AppText(
                              "confirm".tr,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ));
  }
}