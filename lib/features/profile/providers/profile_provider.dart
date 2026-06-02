import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/constants/constants.dart';

class ProfileProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> updateProfile({String? newName, XFile? imageFile}) async {
    _setLoading(true);
    try {
      User? user = _auth.currentUser;
      if (user == null) return;

      String? photoUrl;
      if (imageFile != null) {
        photoUrl = await _cloudinaryService.uploadImage(
          File(imageFile.path),
          folder: 'profile_pictures',
        );
      }

      Map<String, dynamic> updates = {};
      if (newName != null && newName.isNotEmpty) {
        updates['displayName'] = newName;
        await user.updateDisplayName(newName);
      }
      if (photoUrl != null) {
        updates['photoURL'] = photoUrl;
        await user.updatePhotoURL(photoUrl);
      }

      if (updates.isNotEmpty) {
        await _db.collection(AppConstants.usersCollection).doc(user.uid).update(updates);
      }
      
      notifyListeners();
    } catch (e) {
      debugPrint('Update Profile Error: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<XFile?> pickImage() async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
