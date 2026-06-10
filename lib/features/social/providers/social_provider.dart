import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';
import '../../../models/message_model.dart';
import '../../../core/constants/constants.dart';

class SocialProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Search users by display name or email
  Future<List<UserModel>> searchUsers(String query, String currentUserId) async {
    if (query.isEmpty) return [];
    
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: '$query\uf8ff')
          .limit(20)
          .get();

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) => user.uid != currentUserId)
          .toList();
    } catch (e) {
      debugPrint('Error searching users: $e');
      return [];
    }
  }

  // Send friend request
  Future<bool> sendFriendRequest(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();
      
      final currentUserRef = _firestore.collection(AppConstants.usersCollection).doc(currentUserId);
      final targetUserRef = _firestore.collection(AppConstants.usersCollection).doc(targetUserId);

      batch.update(currentUserRef, {
        'sentRequests': FieldValue.arrayUnion([targetUserId])
      });

      batch.update(targetUserRef, {
        'receivedRequests': FieldValue.arrayUnion([currentUserId])
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error sending friend request: $e');
      return false;
    }
  }

  // Accept friend request
  Future<bool> acceptFriendRequest(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();
      
      final currentUserRef = _firestore.collection(AppConstants.usersCollection).doc(currentUserId);
      final targetUserRef = _firestore.collection(AppConstants.usersCollection).doc(targetUserId);

      // Add to friends, remove from requests
      batch.update(currentUserRef, {
        'friends': FieldValue.arrayUnion([targetUserId]),
        'receivedRequests': FieldValue.arrayRemove([targetUserId])
      });

      batch.update(targetUserRef, {
        'friends': FieldValue.arrayUnion([currentUserId]),
        'sentRequests': FieldValue.arrayRemove([currentUserId])
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error accepting friend request: $e');
      return false;
    }
  }

  // Reject friend request
  Future<bool> rejectFriendRequest(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();
      
      final currentUserRef = _firestore.collection(AppConstants.usersCollection).doc(currentUserId);
      final targetUserRef = _firestore.collection(AppConstants.usersCollection).doc(targetUserId);

      batch.update(currentUserRef, {
        'receivedRequests': FieldValue.arrayRemove([targetUserId])
      });

      batch.update(targetUserRef, {
        'sentRequests': FieldValue.arrayRemove([currentUserId])
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error rejecting friend request: $e');
      return false;
    }
  }

  // Unfriend
  Future<bool> unfriend(String currentUserId, String targetUserId) async {
    try {
      final batch = _firestore.batch();
      
      final currentUserRef = _firestore.collection(AppConstants.usersCollection).doc(currentUserId);
      final targetUserRef = _firestore.collection(AppConstants.usersCollection).doc(targetUserId);

      batch.update(currentUserRef, {
        'friends': FieldValue.arrayRemove([targetUserId])
      });

      batch.update(targetUserRef, {
        'friends': FieldValue.arrayRemove([currentUserId])
      });

      await batch.commit();
      return true;
    } catch (e) {
      debugPrint('Error unfriending: $e');
      return false;
    }
  }

  // Stream friend list details
  Stream<List<UserModel>> getFriendsStream(List<String> friendIds) {
    if (friendIds.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('uid', whereIn: friendIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // Stream received requests details
  Stream<List<UserModel>> getReceivedRequestsStream(List<String> requestIds) {
    if (requestIds.isEmpty) return Stream.value([]);
    
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('uid', whereIn: requestIds)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList());
  }

  // CHAT LOGIC
  
  String getChatId(String u1, String u2) {
    return u1.hashCode <= u2.hashCode ? '${u1}_$u2' : '${u2}_$u1';
  }

  Future<void> sendMessage(String senderId, String receiverId, String text) async {
    if (text.trim().isEmpty) return;
    
    final chatId = getChatId(senderId, receiverId);
    final timestamp = DateTime.now();

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': senderId,
        'receiverId': receiverId,
        'text': text.trim(),
        'timestamp': Timestamp.fromDate(timestamp),
      });

      // Update last message in chat document for sorting
      await _firestore.collection('chats').doc(chatId).set({
        'lastMessage': text.trim(),
        'lastTimestamp': Timestamp.fromDate(timestamp),
        'participants': [senderId, receiverId],
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error sending message: $e');
    }
  }

  Stream<List<MessageModel>> getMessagesStream(String senderId, String receiverId) {
    final chatId = getChatId(senderId, receiverId);
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
