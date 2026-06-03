import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';
import '../constants/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final g_auth.GoogleSignIn _googleSignIn = g_auth.GoogleSignIn(
    clientId: kIsWeb ? '92598071273-web_client_id_anda.apps.googleusercontent.com' : null,
  );

  Stream<User?> get userStream => _auth.authStateChanges();

  Stream<UserModel?> getUserDataStream(String uid) {
    return _db
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromMap(doc.data()!) : null);
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        if (userCredential.user != null) {
          await _updateUserData(userCredential.user!);
        }
        return userCredential;
      } else {
        final googleUser = await _googleSignIn.signIn();
        if (googleUser == null) return null;

        final googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        UserCredential userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          await _updateUserData(userCredential.user!);
        }
        return userCredential;
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<UserCredential?> signInWithGitHub() async {
    try {
      GithubAuthProvider githubProvider = GithubAuthProvider();
      if (kIsWeb) {
        UserCredential userCredential = await _auth.signInWithPopup(githubProvider);
        if (userCredential.user != null) {
          await _updateUserData(userCredential.user!);
        }
        return userCredential;
      } else {
        UserCredential userCredential = await _auth.signInWithProvider(githubProvider);
        if (userCredential.user != null) {
          await _updateUserData(userCredential.user!);
        }
        return userCredential;
      }
    } catch (e) {
      debugPrint('GitHub Sign-In Error: $e');
      return null;
    }
  }

  Future<void> _updateUserData(User user) async {
    DocumentReference ref = _db.collection(AppConstants.usersCollection).doc(user.uid);
    DocumentSnapshot doc = await ref.get();

    if (!doc.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'Player',
        photoURL: user.photoURL ?? '',
        bio: 'Hello there!',
        purchasedGames: [],
        createdAt: DateTime.now(),
      );
      await ref.set(newUser.toMap());
    } else {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      Map<String, dynamic> updates = {};
      
      if ((data['photoURL'] == null || data['photoURL'] == '') && user.photoURL != null) {
        updates['photoURL'] = user.photoURL;
      }
      if ((data['displayName'] == null || data['displayName'] == '') && user.displayName != null) {
        updates['displayName'] = user.displayName;
      }
      
      if (updates.isNotEmpty) {
        await ref.update(updates);
      }
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
