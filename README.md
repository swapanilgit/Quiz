# Brain Byte 🧠⚡
A quiz app built with Flutter. Started this as a personal project to learn Firebase auth properly and ended up adding a bunch of stuff on top — category-based quizzes, a host mode where you can build your own question sets, and an AI quiz generator powered by Groq.

## What it does
- Login / signup with Firebase Auth (email + Google sign-in)
- Browse quizzes by category (Science, History, Programming, GK, etc.)
- Search categories
- Take quizzes and see your answered questions afterwards
- Quiz history so you can check past attempts
- Host mode — create your own quiz rooms with custom questions, difficulty, and settings
- AI Quiz Generator — type in any topic and it generates MCQs for you (uses a small Node backend that calls Groq)
- Profile screen with your info + option to reset password

## Tech stack
**App**
- Flutter (Dart)
- Firebase Auth, Cloud Firestore, Firebase Storage
- GetX for state/navigation
- shared_preferences for local caching
- google_sign_in

**Backend (for the AI quiz feature)**
- Node.js + Express
- Groq API (uses `openai/gpt-oss-20b` by default) for generating questions
- Just one route really: `POST /api/ai-quiz`

## Project structure
```
lib/
  main.dart
  Screens/
    HomeScreen.dart
    QuizScreen.dart
    HostScreen.dart
    AiQuizGeneratorScreen.dart
    QuizHistoryPage.dart
    AnsweredQuestion.dart
    ProfileScreen.dart
    Login_Screen.dart
    SignUpScreen.dart
    Forgot.dart
    UserCache.dart
    host/               # widgets used by the host/create-quiz flow
  Services/
    groq_quiz_service.dart
backend/
  server.js
  package.json
  .env.example
```

## Running the app
1. Clone the repo and get packages
   ```
   flutter pub get
   ```
2. Add your own Firebase config (`google-services.json` for Android, `GoogleService-Info.plist` for iOS). This repo doesn't ship with Firebase keys for obvious reasons, so the app will still boot without them but auth won't work until you add your own project.
3. Run it
   ```
   flutter run
   ```

## Running the AI backend
The AI quiz generator needs the little Node server running locally.
```
cd backend
npm install
cp .env.example .env
```
Then open `.env` and drop in your own Groq API key:
```
PORT=3000
GROQ_API_KEY=your_groq_api_key_here
GROQ_MODEL=openai/gpt-oss-20b
```
Start it:
```
npm start
```
By default the app is pointed at `http://10.0.2.2:3000/api/ai-quiz`, which is the special address the Android emulator uses to reach your machine's localhost. If you're testing on a real phone, you'll need to swap that for your computer's actual local IP (something like `http://192.168.1.x:3000/api/ai-quiz`) in `lib/Services/groq_quiz_service.dart`.

## Notes / known issues
- Firebase init is wrapped in a try/catch in `main.dart` so the app doesn't crash if you haven't set up Firebase yet — but obviously login won't work in that case.
- Host mode is still pretty basic, no persistence for rooms yet.
- Backend has no auth/rate limiting on the `/api/ai-quiz` route — fine for local dev, not something you'd want to expose publicly as-is.

## Todo (maybe)
- [ ] Multiplayer for host rooms (right now it's more of a quiz builder than a live room)
- [ ] Better error states in the AI generator screen
- [ ] Dark/light theme toggle (currently forced dark)
- [ ] Move Groq key handling fully server-side for a hosted deployment

---
Built by Swapanil Gupta.
