import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vclub/API/ApiClient.dart';
import 'package:vclub/API/ApiRoutes.dart';
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
  final invoiceId = invoice.id;
  if (invoiceId.isEmpty) {
    AppSnackBar.error("invoice_link_unavailable".tr);
    return;
  }

  final progressController = DownloadProgressController();
  bool sheetOpen = true;

  showDownloadProgressSheet(context, progressController).then((_) {
    sheetOpen = false;
  });

  String? savePath;

  try {
    final dir = Platform.isIOS ? await getApplicationDocumentsDirectory() : await getTemporaryDirectory();
    final fileName = "invoice_${invoice.stripeInvoiceId ?? invoice.id}.pdf";
    savePath = "${dir.path}/$fileName";

    // Authenticated request through ApiClient (Authorization header is
    // attached automatically by ApiInterceptor, same as every other call).
    final response = await ApiClient.instance.get<List<int>>(
      ApiRoutes.invoicePdf(invoiceId),
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
      ),
      onReceiveProgress: (received, total) => progressController.update(received, total),
    );

    final bytes = response.data;
    if (bytes == null || bytes.isEmpty) {
      throw Exception("Empty PDF response");
    }

    final file = File(savePath);
    await file.writeAsBytes(bytes);
  } catch (e) {
    if (sheetOpen && context.mounted) Navigator.of(context, rootNavigator: true).pop();
    progressController.dispose();
    AppSnackBar.error("invoice_download_failed".tr);
    return;
  }

  if (sheetOpen && context.mounted) Navigator.of(context, rootNavigator: true).pop();
  progressController.dispose();

  final file = File(savePath);
  if (!await file.exists()) {
    AppSnackBar.error("invoice_download_failed".tr);
    return;
  }

  try {
    final result = await OpenFilex.open(savePath);

    if (result.type == ResultType.done) {
      AppSnackBar.success("invoice_downloaded".tr);
    } else {
      AppSnackBar.success("invoice_downloaded_no_viewer".tr);
    }
  } catch (e) {
    AppSnackBar.success("invoice_downloaded_no_viewer".tr);
  }
}
}