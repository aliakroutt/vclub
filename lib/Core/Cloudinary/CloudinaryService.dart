// lib/Core/Cloudinary/CloudinaryService.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Shared Cloudinary upload service — used by both client and merchant
/// avatar/logo uploads.
///
/// Uses an UNSIGNED upload preset, the standard approach for direct
/// client-side uploads (no API secret ever ships in the app). Configure
/// the preset in the Cloudinary console under
/// Settings → Upload → Upload presets → Signing Mode: "Unsigned".
class CloudinaryService {
  CloudinaryService._();

  
  static const String _cloudName = 'wpb0e4nu';
  static const String _uploadPreset = 'Vclub-App';

  static Uri get _uploadUrl =>
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');

  /// Uploads [file] to Cloudinary and returns the resulting secure image
  /// URL, or null if the upload failed.
  static Future<String?> uploadImage(File file) async {
    try {
      final request = http.MultipartRequest('POST', _uploadUrl)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode != 200) {
        // ignore: avoid_print
        print('⚠️ CloudinaryService upload failed: ${response.statusCode} ${response.body}');
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['secure_url'] as String?;
    } catch (e) {
      // ignore: avoid_print
      print('⚠️ CloudinaryService upload error: $e');
      return null;
    }
  }
}