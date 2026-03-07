import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Returns the current authenticated user, or null.
  static User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes.
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register a new user with email and password.
  /// Creates a Firestore user document after successful registration.
  static Future<UserCredential> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    // Update the display name on the Firebase user
    try {
      await credential.user?.updateDisplayName(name.trim());
    } catch (e) {
      debugPrint('Failed to update display name: $e');
    }

    // Create the user document in Firestore (non-blocking)
    if (credential.user != null) {
      try {
        await _firestore.collection('users').doc(credential.user!.uid).set({
          'name': name.trim(),
          'email': email.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        debugPrint('Failed to create Firestore user doc: $e');
        // Don't block registration if Firestore write fails
      }
    }

    return credential;
  }

  /// Login an existing user with email and password.
  static Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign out the current user.
  static Future<void> logoutUser() async {
    await _auth.signOut();
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
  }

  /// Sign in with Google
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // The user canceled the sign-in
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create user document if it's the first time
      if (userCredential.user != null) {
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (!userDoc.exists) {
          try {
            await _firestore.collection('users').doc(userCredential.user!.uid).set({
              'name': userCredential.user!.displayName ?? 'User',
              'email': userCredential.user!.email ?? '',
              'createdAt': FieldValue.serverTimestamp(),
            });
          } catch (e) {
            debugPrint('Failed to create Firestore doc for Google sign-in: $e');
          }
        }
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }

  /// Send a password reset email.
  static Future<void> resetPassword({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  /// Returns a user-friendly error message from any exception.
  /// Handles [FirebaseAuthException], [FirebaseException], and generic errors.
  static String getErrorMessage(dynamic e) {
    // FirebaseAuthException extends FirebaseException, so check it first
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak (minimum 6 characters).';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-not-found':
          return 'No account found for this email.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'invalid-credential':
          return 'Invalid email or password. Please check and try again.';
        case 'configuration-not-found':
          return 'Firebase is not properly configured. Please contact support.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled. Please contact support.';
        case 'channel-error':
          return 'Please fill in all required fields.';
        case 'INVALID_LOGIN_CREDENTIALS':
          return 'Invalid email or password. Please check and try again.';
        default:
          return e.message ?? 'An authentication error occurred. (${e.code})';
      }
    }
    // Generic FirebaseException (e.g., Firestore errors)
    if (e is FirebaseException) {
      switch (e.code) {
        case 'configuration-not-found':
          return 'Firebase is not properly configured. Please contact support.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          return e.message ?? 'A Firebase error occurred. (${e.code})';
      }
    }
    // Fallback for any other exception
    return e.toString().contains('configuration-not-found')
        ? 'Firebase is not properly configured. Please contact support.'
        : 'An unexpected error occurred. Please try again.';
  }
}
