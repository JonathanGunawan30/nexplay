import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoURL;
  final String bio;
  final List<String> purchasedGames;
  final String selectedWallpaper;
  final List<String> friends;
  final List<String> sentRequests;
  final List<String> receivedRequests;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoURL,
    required this.bio,
    required this.purchasedGames,
    required this.selectedWallpaper,
    this.friends = const [],
    this.sentRequests = const [],
    this.receivedRequests = const [],
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoURL: data['photoURL'] ?? '',
      bio: data['bio'] ?? '',
      purchasedGames: List<String>.from(data['purchased_games'] ?? []),
      selectedWallpaper: data['selectedWallpaper'] ?? '',
      friends: List<String>.from(data['friends'] ?? []),
      sentRequests: List<String>.from(data['sentRequests'] ?? []),
      receivedRequests: List<String>.from(data['receivedRequests'] ?? []),
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'bio': bio,
      'purchased_games': purchasedGames,
      'selectedWallpaper': selectedWallpaper,
      'friends': friends,
      'sentRequests': sentRequests,
      'receivedRequests': receivedRequests,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoURL,
    String? bio,
    String? selectedWallpaper,
    List<String>? friends,
    List<String>? sentRequests,
    List<String>? receivedRequests,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      purchasedGames: purchasedGames,
      selectedWallpaper: selectedWallpaper ?? this.selectedWallpaper,
      friends: friends ?? this.friends,
      sentRequests: sentRequests ?? this.sentRequests,
      receivedRequests: receivedRequests ?? this.receivedRequests,
      createdAt: createdAt,
    );
  }
}
