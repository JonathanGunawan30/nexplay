import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../constants/constants.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    AppConstants.cloudinaryCloudName,
    AppConstants.cloudinaryUploadPreset,
    cache: false,
  );
  
  final Dio _dio = Dio();

  Future<String?> uploadImage(XFile imageFile, {String folder = 'general'}) async {
    try {
      final bytes = await imageFile.readAsBytes();
      
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromByteData(
          ByteData.view(bytes.buffer),
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
          identifier: imageFile.name,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary Upload Error: $e');
      return null;
    }
  }

  Future<bool> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty || !imageUrl.contains('cloudinary.com')) return false;

    try {
      final regex = RegExp(r'\/upload\/(?:v\d+\/)?([^\.]+)');
      final match = regex.firstMatch(imageUrl);
      if (match == null) {
        debugPrint('Cloudinary Delete Error: Could not extract public_id from $imageUrl');
        return false;
      }
      
      String publicId = match.group(1)!;
      publicId = Uri.decodeComponent(publicId);

      final String timestamp = (DateTime.now().millisecondsSinceEpoch / 1000).round().toString();
      final String apiSecret = AppConstants.cloudinaryApiSecret;
      final String apiKey = AppConstants.cloudinaryApiKey;
      final String cloudName = AppConstants.cloudinaryCloudName;

      if (apiSecret.isEmpty || apiKey.isEmpty) {
        debugPrint('Cloudinary Delete Error: API Key or Secret is missing in .env');
        return false;
      }

      final String stringToSign = 'public_id=$publicId&timestamp=$timestamp$apiSecret';
      final bytes = utf8.encode(stringToSign);
      final Digest digest = sha1.convert(bytes);
      final String signature = digest.toString();

      final response = await _dio.post(
        'https://api.cloudinary.com/v1_1/$cloudName/image/destroy',
        data: FormData.fromMap({
          'public_id': publicId,
          'timestamp': timestamp,
          'api_key': apiKey,
          'signature': signature,
        }),
      );

      if (response.statusCode == 200 && response.data['result'] == 'ok') {
        debugPrint('Cloudinary Delete Success: $publicId');
        return true;
      } else {
        debugPrint('Cloudinary Delete Failed: ${response.data}');
        return false;
      }
    } catch (e) {
      debugPrint('Cloudinary Delete Exception: $e');
      return false;
    }
  }
}
