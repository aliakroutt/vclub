import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';


class ImageBase64 {
  ImageBase64._();

  /// Compresses the image down to a target max dimension and quality,
  /// then base64-encodes it. Keeps retrying at lower quality if the
  /// result is still too large, to stay well under typical upload limits.
  static Future<String> fromFile(
    File file, {
    int maxDimension = 800,
    int initialQuality = 75,
    int maxBytes = 350 * 1024, // ~350KB raw -> ~470KB base64, safely under most nginx limits
  }) async {
    Uint8List? compressed;
    int quality = initialQuality;

    while (quality >= 25) {
      compressed = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: maxDimension,
        minHeight: maxDimension,
        quality: quality,
        format: CompressFormat.jpeg, // jpeg compresses far better than png for photos/logos
      );

      if (compressed == null) break;
      if (compressed.length <= maxBytes) break;

      quality -= 15;
    }

    // Fallback: if compression failed entirely, use the original bytes
    // (better to attempt the upload than crash — server will reject if still too big).
    final bytes = compressed ?? await file.readAsBytes();

    return "data:image/jpeg;base64,${base64Encode(bytes)}";
  }
}