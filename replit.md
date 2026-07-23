# Gita Nexus — KMP Edition

**Gita Nexus** is a cross-platform spiritual + AI assistant for the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas, by **Nexus Waves Technologies**.

## Platform

| | Stack |
|---|---|
| **Shared logic** | Kotlin Multiplatform (KMP) — `shared/` module |
| **Android** | Jetpack Compose + Material 3 — `androidApp/` |
| **iOS** | SwiftUI wrapping shared KMP framework — `iosApp/` |
| **Backend** | FastAPI (Python) — `backend/` |

> Flutter source code has been removed. KMP is the sole development target.

---

## Project Structure

```
shared/                         KMP shared module (business logic, network)
  src/commonMain/
    AppConfig.kt                All URLs, keys, constants — single source of truth
    data/ScriptureData.kt       Bundled metadata for Shiva Mahapurana & Ramcharitmanas
    network/
      CloudflareGatewayClient   Ed25519-signed API key broker
      SignatureProvider.kt      expect/actual — platform crypto
    domain/models/              Core models (Verse, Chapter, ScriptureType, UserProfile…)
    domain/repository/          Repository interfaces
    data/                       GitaRepositoryImpl, AiRepositoryImpl
    di/SharedModule.kt          Koin DI

androidApp/                     Android application
  src/main/kotlin/.../
    GeetaNexusApp.kt            Application — Koin startup, key injection
    MainActivity.kt             Edge-to-edge scaffold + bottom nav
    ui/theme/                   Material 3 (saffron/gold, auto dark/light)
    ui/navigation/NavGraph.kt   All Compose Navigation routes
    ui/screens/
      HomeScreen.kt             Daily verse, quick actions, scripture teaser
      ScripturesScreen.kt       Hub for all 3 scriptures + detail screens
      ChaptersScreen.kt         Bhagavad Gita chapter grid + detail
      VerseReaderScreen.kt      Swipe navigation + unified audio controls
      AiChatScreen.kt           Aira AI (Gemini-powered) chat
      BookmarksScreen.kt        Saved verses
      SearchScreen.kt           Debounced verse search
      ProfileScreen.kt          Google Sign-In via Credential Manager
      MoreScreen.kt             Social links, community, legal
      AboutScreen.kt            About Nexus Waves Technologies
      PrivacyPolicyScreen.kt    Full privacy policy
      TermsScreen.kt            Full terms of service
      OnboardingScreen.kt       First-launch onboarding
    ui/viewmodel/
      HomeViewModel.kt          Daily verse, user load/signOut
      GitaViewModel.kt          Chapter/verse loading, search, bookmarks
      AiChatViewModel.kt        Gemini API chat (via Cloudflare gateway)
      AudioViewModel.kt         ExoPlayer — unified TTS/audio player
    di/AndroidModule.kt         Koin: repositories + all ViewModels
    data/
      LocalBookmarkRepository   DataStore-backed bookmarks
      LocalUserRepository       DataStore + Credential Manager sign-in
```

---

## Building

### Android (Android Studio)

1. Copy `local.properties.template` → `local.properties`
2. Fill in `sdk.dir`, `ed25519.private.key`, and (optionally) `google.web.client.id`
3. Open **root** project in Android Studio (not `android/`)
4. Sync Gradle → Run `androidApp` on emulator or device (API 26+, Android 8.0)

### iOS (Xcode — macOS only)

```bash
./gradlew shared:assembleReleaseXCFramework
```
Open `iosApp/iosApp.xcodeproj`, link the XCFramework, run on simulator/device.

---

## API Keys to Add to Cloudflare Worker

Add these as **Secrets** (or KV entries) in your Cloudflare Worker dashboard.  
The variable name must match **exactly** — the app requests keys by these names:

| Variable Name | Where to Get It | Purpose |
|---|---|---|
| `GEMINI_AI_API_KEY` | [Google AI Studio](https://aistudio.google.com/) → API keys | Gemini 1.5 Flash — Aira AI chat |
| `HF_TTS_API_KEY` | [Hugging Face](https://huggingface.co/settings/tokens) → New token (Read) | SpeechT5 text-to-speech |
| `HF_STT_API_KEY` | [Hugging Face](https://huggingface.co/settings/tokens) → New token (Read) | Whisper speech-to-text |
| `HF_CHAT_API_KEY` | [Hugging Face](https://huggingface.co/settings/tokens) → New token (Read) | Mistral chat fallback |

> In Cloudflare dashboard → Workers & Pages → your Worker → Settings → Variables → Add secret.

---

## Ed25519 Key Setup

```bash
# 1. Generate private key
openssl genpkey -algorithm ed25519 -out private.pem

# 2. Get 32-byte seed as base64 → paste into local.properties
openssl pkey -in private.pem -outform DER | tail -c 32 | base64

# 3. Verify public key matches Worker (or update Worker with new public key)
openssl pkey -in private.pem -pubout | openssl pkey -pubin -outform DER | base64
```

`local.properties`:
```
sdk.dir=/path/to/sdk
ed25519.private.key=<your-32-byte-seed-base64>
```

Worker public key already deployed: `MCowBQYDK2VwAyEAa4ZxuobCuaSe+HMbCc7YW7AG/W5SELvpc7NNBVX9ab4=`

---

## Architecture

```
Android/iOS App
      │  Ed25519-signed request (X-API-Name + X-Timestamp + X-Nonce + X-Signature)
      ▼
Cloudflare Workers Gateway  ←── Secrets: GEMINI_AI_API_KEY, HF_TTS_API_KEY, etc.
      │  Returns { api_key: "..." }
      ▼
App uses key to call:
  ├─ Google Gemini 1.5 Flash  → Aira AI chat
  ├─ FastAPI backend /tts     → Text-to-speech (streamed to ExoPlayer)
  ├─ FastAPI backend /stt     → Voice input
  └─ FastAPI backend /ask     → AI Q&A fallback
```

## Features

- 📖 **Bhagavad Gita** — 18 chapters, 700 verses, Sanskrit + transliteration + commentary
- 🔱 **Shiva Mahapurana** — 7 Samhitas with descriptions and AI audio
- 🙏 **Ramcharitmanas** — 7 Kandas by Goswami Tulsidas with AI audio
- 🤖 **Aira AI** — Gemini 1.5 Flash spiritual guide; falls back to FastAPI → local KB
- 🎧 **Unified Audio Player** — single ExoPlayer for TTS + reading; no multiple instances
- 🔖 **Bookmarks** — DataStore-persisted locally
- 🔐 **Google Sign-In** — Credential Manager (One Tap)
- 📜 **Legal pages** — Privacy Policy, Terms of Service, About Us

## User Preferences

<!-- Add here as expressed -->
