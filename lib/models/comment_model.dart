import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String gameId;
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String comment;
  final double rating;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });

  factory CommentModel.fromMap(Map<String, dynamic> data, String documentId) {
    return CommentModel(
      id: documentId,
      gameId: data['gameId'] ?? '',
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      userPhotoUrl: data['userPhotoUrl'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameId': gameId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'comment': comment,
      'rating': rating,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
