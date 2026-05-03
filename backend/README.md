# Groq Quiz Backend

This backend accepts a topic from the Flutter app and asks Groq to generate 10 MCQ questions in strict JSON format.

## Setup

1. Open this folder:
   `E:\quiz\backend`
2. Copy `.env.example` to `.env`
3. Put your Groq key in `GROQ_API_KEY`
4. Install packages:
   `npm install`
5. Start the server:
   `npm start`

## Default endpoint

`POST /api/ai-quiz`

Example request body:

```json
{
  "topic": "Physics",
  "difficulty": "easy_to_medium",
  "languageStyle": "simple",
  "questionCount": 10,
  "questionType": "mcq"
}
```

## Flutter app note

The app currently points to:

`http://10.0.2.2:3000/api/ai-quiz`

That works for the Android emulator. If you run the app on a real device, replace that URL in:

`E:\quiz\lib\Services\groq_quiz_service.dart`

with your computer's local IP address, for example:

`http://192.168.1.5:3000/api/ai-quiz`
