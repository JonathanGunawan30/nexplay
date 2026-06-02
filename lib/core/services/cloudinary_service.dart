import 'package:cloudinary_public/cloudinary_public.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../constants/constants.dart';

class CloudinaryService {
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    AppConstants.cloudinaryCloudName,
    AppConstants.cloudinaryUploadPreset,
    cache: false,
  );

  Future<String?> uploadImage(File imageFile, {String folder = 'general'}) async {
    try {
      CloudinaryResponse response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } catch (e) {
      debugPrint('Cloudinary Upload Error: $e');
      return null;
    }
  }
}
