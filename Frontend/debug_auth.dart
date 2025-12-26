// Debug script to test Firebase Auth connection
// Run this to check if Firebase Auth is working

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'lib/firebase_options.dart';

Future<void> main() async {
  try {
    print('🔍 Testing Firebase Auth Connection...');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
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

    print('🎉 Firebase Auth is working!');
  } catch (e) {
    print('❌ Firebase Auth error: $e');
    print('🔧 Please check:');
    print('   1. Firebase project is set up correctly');
    print('   2. Authentication is enabled in Firebase Console');
    print('   3. firebase_options.dart has correct configuration');
  }
}
