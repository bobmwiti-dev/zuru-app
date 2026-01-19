# Zuru

Zuru is a personal experience journaling app that allows users to document, relive, and reflect on their life experiences — such as visiting parks, attending events, exploring cafes, or discovering hangouts — through photos, videos, notes, moods, and location tagging.

## Development

### Prerequisites

- Flutter SDK
- A Firebase project (for Auth / Firestore / Storage)

### Run

```bash
flutter pub get
flutter run
```

### Run on Web (Chrome) with Firebase

This app expects Firebase Web configuration at runtime using `--dart-define` (see `lib/main.dart`).

1) Create a local (untracked) defines file:

- Copy the example file:

```bash
cp firebase_web_defines.example.json firebase_web_defines.json
```

PowerShell:

```powershell
Copy-Item firebase_web_defines.example.json firebase_web_defines.json
```

- Fill in your Firebase Web values in `firebase_web_defines.json`.

2) Run:

```bash
flutter run -d chrome --dart-define-from-file=firebase_web_defines.json
```

Notes:

- `firebase_web_defines.json` is intentionally gitignored.
- Do not commit real Firebase keys or `.env` secrets.
