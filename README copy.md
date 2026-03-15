# AI Issue Resolver — Flutter + Firebase Chatbot

## 📁 File Structure

```
ai_chatbot/
├── main.dart                          # App entry & Provider setup
├── pubspec.yaml                       # Dependencies
├── firestore.rules                    # Firestore security rules
│
├── models/
│   ├── chat_message.dart              # Message model (user/assistant)
│   └── chat_session.dart              # Session model (issue tickets)
│
├── services/
│   ├── ai_service.dart                # Gemini API integration
│   └── chat_service.dart             # Firestore CRUD operations
│
├── providers/
│   └── chat_provider.dart            # State management (ChangeNotifier)
│
├── screens/
│   ├── chat_sessions_screen.dart     # Issue list / history screen
│   └── chat_screen.dart             # Main chat UI screen
│
└── widgets/
    ├── message_bubble.dart           # Chat bubble widget
    └── typing_indicator.dart        # Animated "AI is typing" widget
```

---

## ⚙️ Setup Steps

### 1. Firebase Setup
```bash
# Install Firebase CLI and FlutterFire
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Login and configure
firebase login
flutterfire configure
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Get a Gemini API Key
- Go to: https://makersuite.google.com/app/apikey
- Create an API key
- Replace `YOUR_GEMINI_API_KEY` in `services/ai_service.dart`

> ⚠️ For production, store the key in Firebase Remote Config or a Cloud Function — never hardcode it in the app.

### 4. Enable Firestore
- Go to Firebase Console → Firestore Database → Create database
- Apply the rules from `firestore.rules`

### 5. Enable Firebase Authentication
- Firebase Console → Authentication → Sign-in method
- Enable Email/Password or Google Sign-In

### 6. Integrate into your existing app
In your hostel app's navigation, add a route to `ChatSessionsScreen`:

```dart
// In your bottom nav or drawer:
Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const ChatSessionsScreen()),
);
```

Wrap your root widget with `ChangeNotifierProvider<ChatProvider>`:

```dart
ChangeNotifierProvider(create: (_) => ChatProvider()),
```

---

## 🚀 Features

- **AI-powered responses** via Google Gemini
- **Persistent chat history** in Firestore
- **Issue categorization** (WiFi, Plumbing, Electrical, etc.)
- **Quick issue shortcuts** for common problems
- **Session management** — open, resolve, delete issues
- **Animated typing indicator**
- **Offline fallback** responses
- **Swipe to delete** sessions
- **Mark as Resolved** functionality

---

## 🔒 Security Notes

- Firestore rules ensure users only access their own sessions
- Never expose the Gemini API key in production builds
- Consider using Firebase App Check for additional security
