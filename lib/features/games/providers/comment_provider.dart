import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/constants/constants.dart';
import '../../../models/comment_model.dart';

class CommentProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Stream<List<CommentModel>> getGameComments(String gameId) {
    return _db
        .collection(AppConstants.commentsCollection)
        .where('gameId', isEqualTo: gameId)
        .snapshots()
        .map((snapshot) {
      final comments = snapshot.docs
          .map((doc) => CommentModel.fromMap(doc.data(), doc.id))
          .toList();
      comments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return comments;
    });
  }

  Future<bool> addComment({
    required String gameId,
    required String userId,
    required String userName,
    required String userPhotoUrl,
    required String comment,
    required double rating,
  }) async {
    try {
      _setLoading(true);
      
      final existing = await _db
          .collection(AppConstants.commentsCollection)
          .where('gameId', isEqualTo: gameId)
          .where('userId', isEqualTo: userId)
          .get();

      if (existing.docs.isNotEmpty) {
        _setLoading(false);
        return false;
      }

      await _db.collection(AppConstants.commentsCollection).add({
        'gameId': gameId,
        'userId': userId,
        'userName': userName,
        'userPhotoUrl': userPhotoUrl,
        'comment': comment,
        'rating': rating,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _setLoading(false);
      return true;
    } catch (e) {
      _setLoading(false);
      return false;
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _db.collection(AppConstants.commentsCollection).doc(commentId).delete();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
