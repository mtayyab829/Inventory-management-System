// Test script to verify Firebase connection
// Run with: dart test_firebase.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  try {
    print('Testing Firebase connection...');

    // Initialize Firebase
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'YOUR_API_KEY_HERE',
        appId: 'YOUR_APP_ID_HERE',
        messagingSenderId: 'YOUR_SENDER_ID_HERE',
        projectId: 'YOUR_PROJECT_ID_HERE',
      ),
    );

    print('✅ Firebase initialized successfully');

    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    final testDoc = await firestore.collection('test').doc('connection').get();

    print('✅ Firestore connection successful');
    print('🎉 Firebase setup is working!');

  } catch (e) {
    print('❌ Firebase connection failed: $e');
    print('Please check your Firebase configuration');
  }
}
