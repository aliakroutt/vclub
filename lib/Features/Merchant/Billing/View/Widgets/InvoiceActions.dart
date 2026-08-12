import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vclub/Core/Snackbars.dart';
import 'package:vclub/Features/Merchant/Billing/Models/InvoiceModel.dart';
import 'package:vclub/Features/Merchant/Billing/View/Widgets/DownloadProgressSheet.dart';

class InvoiceActions {
  InvoiceActions._();

  static Future<void> openInBrowser(InvoiceModel invoice) async {
  final url = invoice.hostedInvoiceUrl ?? invoice.invoicePdfUrl;
  if (url == null || url.isEmpty) {
    AppSnackBar.error("invoice_link_unavailable".tr);
    return;
  }

  final uri = Uri.tryParse(url);
  if (uri == null) {
    debugPrint("❌ INVOICE OPEN: failed to parse URL -> $url");
    AppSnackBar.error("invoice_link_unavailable".tr);
    return;
  }

  try {
    final canLaunch = await canLaunchUrl(uri);
    debugPrint("ℹ️ INVOICE OPEN: canLaunchUrl($uri) = $canLaunch");

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    debugPrint("ℹ️ INVOICE OPEN: launchUrl returned $launched");

    if (!launched) {
      // Fallback: some Android configs report false from externalApplication
      // even when a platform browser handler exists — retry with the
      // platform-default mode before giving up.
      final fallbackLaunched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      debugPrint("ℹ️ INVOICE OPEN: fallback launchUrl returned $fallbackLaunched");

      if (!fallbackLaunched) {
        AppSnackBar.error("invoice_open_failed".tr);
      }
    }
  } catch (e, st) {
    debugPrint("❌ INVOICE OPEN ERROR: $e");
    debugPrint("$st");
    AppSnackBar.error("invoice_open_failed".tr);
  }
}

  static Future<void> downloadPdf(BuildContext context, InvoiceModel invoice) async {
    final url = invoice.invoicePdfUrl;
    if (url == null || url.isEmpty) {
      AppSnackBar.error("invoice_link_unavailable".tr);
      return;
    }

    final progressController = DownloadProgressController();
    bool sheetOpen = true;

    // Show the progress sheet; don't await it here — we control its lifecycle manually.
    showDownloadProgressSheet(context, progressController).then((_) {
      sheetOpen = false;
    });

    String? savePath;

    try {
      final dir = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getTemporaryDirectory();
      final fileName = "invoice_${invoice.stripeInvoiceId ?? invoice.id}.pdf";
      savePath = "${dir.path}/$fileName";

      await Dio().download(
        url,
        savePath,
        onReceiveProgress: (received, total) => progressController.update(received, total),
      );
    } catch (e) {
      // Download itself failed — close the sheet and report, stop here.
      if (sheetOpen && context.mounted) Navigator.of(context, rootNavigator: true).pop();
      progressController.dispose();
      AppSnackBar.error("invoice_download_failed".tr);
      return;
    }

    // Close the progress sheet now that the file is fully written.
    if (sheetOpen && context.mounted) Navigator.of(context, rootNavigator: true).pop();
    progressController.dispose();

    // Verify the file actually exists before attempting to open it.
    final file = File(savePath);
    if (!await file.exists()) {
      AppSnackBar.error("invoice_download_failed".tr);
      return;
    }

    // Open the downloaded file and check the REAL result — don't assume success.
    try {
      final result = await OpenFilex.open(savePath);

      if (result.type == ResultType.done) {
        AppSnackBar.success("invoice_downloaded".tr);
      } else {
        // File downloaded fine, but the OS couldn't open/preview it
        // (e.g. no PDF viewer). Still a successful download.
        AppSnackBar.success("invoice_downloaded_no_viewer".tr);
      }
    } catch (e) {
      // Downloaded successfully even if opening threw.
      AppSnackBar.success("invoice_downloaded_no_viewer".tr);
    }
  }
}