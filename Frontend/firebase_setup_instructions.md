# Firebase Setup Instructions

## 🚨 CRITICAL: Your Firebase Project Needs These Configurations

### 1. Enable Authentication
Go to Firebase Console → Authentication → Sign-in method
- ✅ Enable "Email/Password" authentication
- ❌ Make sure no other providers are enabled (for now)

### 2. Firestore Security Rules
Go to Firebase Console → Firestore Database → Rules

**REPLACE the default rules with these:**

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow authenticated users to read/write their own data
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

### 3. Check Your Project Configuration
Your `firebase_options.dart` shows:
- **Project ID:** `inventory-management-app-11a90`
- **Web App ID:** `1:65165469986:web:c89a272605fdcc2b22dd7b`

### 4. Test Steps:
1. Open the app in browser (should be running on http://localhost:3005)
2. Sign up with a new account
3. Add a product
4. **Important:** Check the Firebase Console → Firestore Database → Data tab
5. Refresh the browser - data should persist

### 5. If Data Still Lost:
- Check browser developer console for errors
- Verify the Firebase project ID matches
- Make sure Firestore database is created (not just "rules" tab)

### 6. Common Issues:
- **"Missing permissions"** → Firestore rules too restrictive
- **"Project not found"** → Wrong project ID in firebase_options.dart
- **Auth errors** → Email/password auth not enabled

---

## 🔍 Debug Information
The app now includes a **Firebase Connection Test** widget on the dashboard.
Check what it shows:
- ✅ Green messages = Connection working
- ❌ Red messages = Connection issues

**Please check Firebase Console and apply these settings, then try adding a product again!**