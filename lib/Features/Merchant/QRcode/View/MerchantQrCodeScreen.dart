import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

import 'package:vclub/Configs/Theme/app_colors.dart';
import 'package:vclub/Configs/Theme/app_text.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Core/Storage/Controllers/MerchantController.dart';


class MerchantQrCodeScreen extends StatefulWidget {
  const MerchantQrCodeScreen({super.key});

  @override
  State<MerchantQrCodeScreen> createState() => _MerchantQrCodeScreenState();
}

class _MerchantQrCodeScreenState extends State<MerchantQrCodeScreen> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _downloading = false;

  Future<void> _copyLink(String url) async {
    await Clipboard.setData(ClipboardData(text: url));
    AppSnackBar.success("qr_link_copied".tr);
  }

  Future<void> _downloadQr() async {
    if (_downloading) return;
    setState(() => _downloading = true);

    try {
      final bytes = await _screenshotController.capture(pixelRatio: 3.0);
      if (bytes == null) throw Exception("capture failed");

      final dir = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : await getTemporaryDirectory();

      final path = "${dir.path}/vclub_qr_code.png";
      final file = File(path);
      await file.writeAsBytes(bytes);

      AppSnackBar.success("qr_downloaded".tr);
    } catch (e) {
      AppSnackBar.error("qr_download_failed".tr);
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final company = MerchantController.to.merchant.value?.company;
    final companyName = (company?.name.isNotEmpty ?? false) ? company!.name : "—";
    final qrUrl = company?.qrUrl ?? "";

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0E0E10) : const Color(0xFFF8F8FB),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: size.width * .05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height * .015),

              // ── close button ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(isDark ? .3 : .06),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Iconsax.close_circle, size: 20),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * .01),

              AppText("your_qr_code_title".tr, fontSize: 22, fontWeight: FontWeight.w800),
              const SizedBox(height: 6),
              AppText(
                "your_qr_code_subtitle".tr,
                fontSize: 13.5,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.65),
              ),

              SizedBox(height: size.height * .03),

              // ── QR CARD ──
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: size.height * .04, horizontal: size.width * .06),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF18181B) : Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(.12),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(.15), width: 1.4),
                        ),
                        child: qrUrl.isEmpty
                            ? SizedBox(
                                height: size.width * .55,
                                width: size.width * .55,
                                child: Center(
                                  child: AppText(
                                    "qr_link_unavailable".tr,
                                    fontSize: 12,
                                    textAlign: TextAlign.center,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : QrImageView(
                                data: qrUrl,
                                version: QrVersions.auto,
                                size: size.width * .55,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                              ),
                      ),
                      SizedBox(height: size.height * .022),
                      AppText(companyName, fontSize: 17, fontWeight: FontWeight.w800, textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      AppText(
                        "vclub_loyalty_label".tr,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: size.height * .018),

              AppText(
                "qr_scan_hint".tr,
                fontSize: 12,
                textAlign: TextAlign.center,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(.55),
              ),

              SizedBox(height: size.height * .025),

              // ── ACTION BUTTONS ──
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: Material(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: _downloading ? null : _downloadQr,
                          child: Center(
                            child: _downloading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Iconsax.document_download, size: 17, color: Colors.white),
                                      const SizedBox(width: 8),
                                      AppText("download", color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.5),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: Material(
                        color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.045),
                        borderRadius: BorderRadius.circular(15),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: qrUrl.isEmpty ? null : () => _copyLink(qrUrl),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Iconsax.copy, size: 17, color: Theme.of(context).textTheme.bodyMedium?.color),
                              const SizedBox(width: 8),
                              AppText("copy", fontWeight: FontWeight.w700, fontSize: 13.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: size.height * .025),

              // ── URL CARD ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF18181B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white.withOpacity(.06) : Colors.black.withOpacity(.05)),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.global, size: 16, color: AppColors.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AppText(
                        qrUrl.isEmpty ? "qr_link_unavailable".tr : qrUrl,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        color: qrUrl.isEmpty ? Colors.grey : null,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: size.height * .03),

              // ── HOW IT WORKS ──
              AppText("how_it_works_title".tr, fontSize: 16, fontWeight: FontWeight.w800),
              SizedBox(height: size.height * .016),

              _HowItWorksStep(number: 1, text: "qr_step_1".tr),
              _HowItWorksStep(number: 2, text: "qr_step_2".tr),
              _HowItWorksStep(number: 3, text: "qr_step_3".tr),
              _HowItWorksStep(number: 4, text: "qr_step_4".tr, isLast: true),

              SizedBox(height: size.height * .06),
            ],
          ),
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final int number;
  final String text;
  final bool isLast;

  const _HowItWorksStep({required this.number, required this.text, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, AppColors.primary.withOpacity(.75)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: AppText("$number", color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isDark ? Colors.white.withOpacity(.1) : Colors.black.withOpacity(.08),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 22, top: 4),
              child: AppText(text, fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}