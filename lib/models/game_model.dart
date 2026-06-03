import 'package:cloud_firestore/cloud_firestore.dart';

class GameModel {
  final String id;
  final String userId;
  final String title;
  final String genre;
  final double rating;
  final String developer;
  final String releaseYear;
  final String platform;
  final String description;
  final String imageUrl;
  final DateTime createdAt;

  GameModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.genre,
    required this.rating,
    required this.developer,
    required this.releaseYear,
    required this.platform,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
  });

  factory GameModel.fromMap(Map<String, dynamic> data, String documentId) {
    return GameModel(
      id: documentId,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      genre: data['genre'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      developer: data['developer'] ?? '',
      releaseYear: data['releaseYear'] ?? '',
      platform: data['platform'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
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
    };
  }
}
