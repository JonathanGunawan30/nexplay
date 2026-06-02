import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as g_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final g_auth.GoogleSignIn _googleSignIn = g_auth.GoogleSignIn(
    clientId: kIsWeb ? '92598071273-web_client_id_anda.apps.googleusercontent.com' : null,
  );

  Stream<User?> get userStream => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        await _updateUserData(userCredential.user!);
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
        await _updateUserData(userCredential.user!);
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
        await _updateUserData(userCredential.user!);
        return userCredential;
      } else {
        UserCredential userCredential = await _auth.signInWithProvider(githubProvider);
        await _updateUserData(userCredential.user!);
        return userCredential;
      }
    } catch (e) {
      debugPrint('GitHub Sign-In Error: $e');
      return null;
    }
  }

  Future<void> _updateUserData(User user) async {
    DocumentReference ref = _db.collection('users').doc(user.uid);
    DocumentSnapshot doc = await ref.get();

    if (!doc.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoURL: user.photoURL ?? '',
        purchasedGames: [],
        createdAt: DateTime.now(),
      );
      await ref.set(newUser.toMap());
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
