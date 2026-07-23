# Gita Nexus — KMP Spiritual App

## Project Overview

**Gita Nexus** is a Kotlin Multiplatform (KMP) Android + iOS spiritual app covering the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas. It provides verse reading, AI chat (Aira), TTS audio, bookmarks, quiz, notes, reading plans, and daily verse notifications.

---

## Architecture

### Security Model
- **No API keys on device** — all keys fetched at runtime from Cloudflare Worker (`https://api-gateway.kuldeepky538.workers.dev/`)
- **No `google-services.json`** — Firebase initialized programmatically via `BuildConfig` fields (CI/CD secrets only)
- **Ed25519 signing** — Private key injected from `ED25519_PRIVATE_KEY` env var in CI/CD; never committed
- **Aggressive R8** — 7 optimization passes, string obfuscation, log stripping in release

### Modules
| Module | Purpose |
|--------|---------|
| `shared/` | KMP shared Kotlin — domain models, repos, network, DI |
| `androidApp/` | Android Compose UI, ViewModels, WorkManager, Firebase |
| `iosApp/` | iOS SwiftUI entry point (XCFramework consumer) |

### Data Flow
```
User → Android/iOS UI
       → Koin ViewModels
       → Shared Repository Interfaces
       → Firebase Firestore (auth'd user data)
       → Cloudflare Worker (API key proxy)
       → Gemini / HuggingFace APIs
```

---

## Key Features

| Feature | Implementation |
|---------|---------------|
| AI Chat | `AiChatViewModel` → Cloudflare Gateway → Gemini |
| TTS Audio | `AudioViewModel` → Cloudflare Gateway → HuggingFace |
| Bookmarks | `FirestoreBookmarkRepository` (online) / `LocalBookmarkRepository` (offline) |
| Notes | `FirestoreNotesRepository` → Firestore |
| Quiz | `QuizRepositoryImpl` — static dataset, 18 questions |
| Reading Plans | `FirestoreReadingPlanRepository` → Firestore |
| Daily Verse | `DailyVerseWorker` — WorkManager, fires at 6 AM |
| FCM Push | `GeetaNexusFcmService` |

---

## Firebase Setup

No `google-services.json` is committed. Firebase is initialized in `FirebaseManager.kt` using `BuildConfig` fields:

```
FIREBASE_API_KEY         → androidApp/build.gradle.kts secret("FIREBASE_API_KEY")
FIREBASE_APP_ID          → secret("FIREBASE_APP_ID")
FIREBASE_GCM_SENDER_ID   → secret("FIREBASE_GCM_SENDER_ID")
FIREBASE_PROJECT_ID      = "geeta-nexus"
FIREBASE_STORAGE_BUCKET  = "geeta-nexus.firebasestorage.app"
```

Set these in CI/CD environment variables (GitHub Actions secrets, etc.).

---

## Auth

Uses Android **Credential Manager** — no deprecated Google Sign-In SDK:
- Google One Tap / Sign-In via `CredentialManager`
- Email/Password (Firebase Auth)
- Anonymous/Guest

---

## Running Locally

```bash
# Android (needs JAVA_HOME and Android SDK)
./gradlew :androidApp:assembleDebug

# For local Firebase testing, create local.properties:
# FIREBASE_API_KEY=...
# FIREBASE_APP_ID=...
# FIREBASE_GCM_SENDER_ID=...
# ED25519_PRIVATE_KEY=...
# GOOGLE_WEB_CLIENT_ID=...
```

---

## User Preferences

- Kotlin idiomatic code, no Java mixed in
- Compose Material3 only, no View-based UI
- All UI elements must have `contentDescription` for TalkBack accessibility
- No secrets in source code; always use BuildConfig / CI env vars
- minSdk = 24 (Android 7+)
- No FastAPI / Python backend — all AI via Cloudflare Worker → third-party APIs
