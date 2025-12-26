import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants.dart';

/// Authentication service using Firebase Auth
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream subscription to listen to auth state changes
  StreamSubscription<User?>? _authStateSubscription;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user stream for real-time auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  // Constructor - start listening to auth state changes
  AuthService() {
    _listenToAuthStateChanges();
  }

  // Listen to Firebase auth state changes and notify listeners
  void _listenToAuthStateChanges() {
    _authStateSubscription = _auth.authStateChanges().listen((User? user) {
      // Notify all listeners when auth state changes
      notifyListeners();
    });
  }

  // Dispose method to clean up subscription
  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  /// Sign up with email and password
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(name.trim());

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!, name.trim());

      return null; // Success - no error
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return AppConstants.genericError;
    }
  }

  /// Sign in with email and password
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return null; // Success - no error
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return AppConstants.genericError;
    }
  }

  /// Sign out current user
  Future<String?> signOut() async {
    try {
      await _auth.signOut();
      return null; // Success - no error
    } catch (e) {
      return AppConstants.genericError;
    }
  }

  /// Send password reset email
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null; // Success - no error
    } on FirebaseAuthException catch (e) {
      return _getAuthErrorMessage(e);
    } catch (e) {
      return AppConstants.genericError;
    }
  }

  /// Update user profile
  Future<String?> updateProfile({
    String? name,
    String? email,
  }) async {
    try {
      User? user = currentUser;
      if (user == null) return 'User not authenticated';

      // Update display name
      if (name != null && name.isNotEmpty) {
        await user.updateDisplayName(name.trim());
      }

      // Update email (requires re-authentication in production)
      if (email != null && email.isNotEmpty && email != user.email) {
        await user.updateEmail(email.trim());
      }

      // Update Firestore document
      await _updateUserDocument(user.uid, name: name, email: email);

      notifyListeners();
      return null; // Success - no error
    } catch (e) {
      return 'Failed to update profile: ${e.toString()}';
    }
  }

  /// Delete user account
  Future<String?> deleteAccount() async {
    try {
      User? user = currentUser;
      if (user == null) return 'User not authenticated';

      // Delete user document from Firestore
      await _firestore.collection(AppConstants.usersCollection).doc(user.uid).delete();

      // Delete user account
      await user.delete();

      return null; // Success - no error
    } catch (e) {
      return 'Failed to delete account: ${e.toString()}';
    }
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user, String name) async {
    await _firestore.collection(AppConstants.usersCollection).doc(user.uid).set({
      AppConstants.userIdField: user.uid,
      AppConstants.emailField: user.email,
      AppConstants.nameField: name,
      AppConstants.createdAtField: FieldValue.serverTimestamp(),
      AppConstants.updatedAtField: FieldValue.serverTimestamp(),
    });
  }

  /// Update user document in Firestore
  Future<void> _updateUserDocument(String userId, {String? name, String? email}) async {
    Map<String, dynamic> updates = {
      AppConstants.updatedAtField: FieldValue.serverTimestamp(),
    };

    if (name != null) updates[AppConstants.nameField] = name;
    if (email != null) updates[AppConstants.emailField] = email;

    await _firestore.collection(AppConstants.usersCollection).doc(userId).update(updates);
  }

  /// Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    try {
      User? user = currentUser;
      if (user == null) return null;

      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      return null;
    }
  }

  /// Get user display name
  String? getUserDisplayName() {
    return currentUser?.displayName;
  }

  /// Get user email
  String? getUserEmail() {
    return currentUser?.email;
  }

  /// Convert Firebase Auth errors to user-friendly messages
  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'This authentication method is not enabled.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  /// Validate email format
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  bool isValidPassword(String password) {
    return password.length >= AppConstants.minPasswordLength;
  }

  /// Validate name
  bool isValidName(String name) {
    return name.trim().length >= 2 && name.trim().length <= AppConstants.maxNameLength;
  }
}
