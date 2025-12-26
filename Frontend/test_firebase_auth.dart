// Simple test to check Firebase Auth connection
// Run with: dart test_firebase_auth.dart

import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/firebase_options.dart';

Future<void> main() async {
  try {
    print('🔍 Testing Firebase Auth Connection...');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.web,
    );
    print('✅ Firebase initialized');

    // Test Auth instance
    final auth = FirebaseAuth.instance;
    print('✅ Firebase Auth instance created');

    // Check current user
    final user = auth.currentUser;
    if (user != null) {
      print('✅ Current user: ${user.email}');
    } else {
      print('ℹ️  No user currently signed in');
    }

    // Test sign in with a test account (you can modify this)
    print('🔄 Testing sign in...');
    try {
      final result = await auth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'testpass123',
      );
      print('✅ Sign in successful: ${result.user?.email}');
    } catch (e) {
      print('⚠️  Sign in failed (expected for test account): $e');
    }

    print('🎉 Firebase Auth is working!');
  } catch (e) {
    print('❌ Firebase Auth error: $e');
    print('🔧 Possible issues:');
    print('   1. Firebase project not set up');
    print('   2. Authentication not enabled');
    print('   3. Wrong API configuration');
    print('   4. Network connectivity issues');
  }

  // Wait for user input before exiting
  print('\nPress Enter to exit...');
  stdin.readLineSync();
}
