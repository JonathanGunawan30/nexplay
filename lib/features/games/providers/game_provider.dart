import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/cloudinary_service.dart';
import '../../../core/constants/constants.dart';
import '../../../models/game_model.dart';

class GameProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Stream<List<GameModel>> getUserGames(String userId) {
    return _db
        .collection(AppConstants.favoriteGamesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final games = snapshot.docs
          .map((doc) => GameModel.fromMap(doc.data(), doc.id))
          .toList();
      games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return games;
    });
  }

  Future<bool> addGame({
    required String userId,
    required String title,
    required String genre,
    required double rating,
    required String developer,
    required String releaseYear,
    required String platform,
    required String description,
    required XFile? imageFile,
  }) async {
    _setLoading(true);
    try {
      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await _cloudinaryService.uploadImage(
          imageFile,
          folder: 'game_covers',
        ) ?? '';
      }

      await _db.collection(AppConstants.favoriteGamesCollection).add({
        'userId': userId,
        'title': title,
        'genre': genre,
        'rating': rating,
        'developer': developer,
        'releaseYear': releaseYear,
        'platform': platform,
        'description': description,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      debugPrint('Add Game Error: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteGame(String gameId) async {
    try {
      DocumentSnapshot doc = await _db.collection(AppConstants.favoriteGamesCollection).doc(gameId).get();
      if (doc.exists) {
        String? imageUrl = (doc.data() as Map<String, dynamic>)['imageUrl'];
        if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.contains('cloudinary.com')) {
          await _cloudinaryService.deleteImage(imageUrl);
        }
      }

      await _db.collection(AppConstants.favoriteGamesCollection).doc(gameId).delete();
    } catch (e) {
      debugPrint('Delete Game Error: $e');
    }
  }

  Future<XFile?> pickCoverImage() async {
    return await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
