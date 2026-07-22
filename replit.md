# Gita Nexus — KMP Edition

**Gita Nexus** is a cross-platform spiritual + AI assistant built around the Bhagavad Gita, by Nexus Wave Technologies.

## Platform

| | Stack |
|---|---|
| **Shared logic** | Kotlin Multiplatform (KMP) — `shared/` module |
| **Android** | Jetpack Compose + Material 3 — `androidApp/` |
| **iOS** | SwiftUI wrapping shared KMP framework — `iosApp/` |
| **Backend** | FastAPI (Python) — `backend/` |

> The original Flutter source code is preserved in `lib/`, `pubspec.yaml`, and `android/` for reference.  
> The KMP project is the active development target.

---

## Project Structure

```
shared/                         KMP shared module (business logic, network)
  src/commonMain/               Platform-independent Kotlin
    AppConfig.kt                All URLs, keys, constants — single source of truth
    network/
      CloudflareGatewayClient   Ed25519-signed API key broker via Cloudflare Workers
      SignatureProvider.kt      expect/actual — platform crypto interface
    domain/models/              Core data models (Verse, Chapter, UserProfile…)
    domain/repository/          Repository interfaces
    data/                       Repository implementations
    di/SharedModule.kt          Koin DI setup (shared)
  src/androidMain/              Android-specific actuals (BouncyCastle, Android Base64)
  src/iosMain/                  iOS-specific actuals (Security framework, CryptoKit)

androidApp/                     Android application module
  build.gradle.kts              Reads ed25519.private.key from local.properties
  src/main/kotlin/…/
    GeetaNexusApp.kt            Application class — Koin startup, key injection
    MainActivity.kt             Edge-to-edge scaffold + bottom navigation
    ui/theme/                   Material 3 theme (saffron/gold, auto dark/light)
    ui/navigation/NavGraph.kt   Compose Navigation routes
    ui/screens/                 HomeScreen, ChaptersScreen, VerseReaderScreen,
                                AiChatScreen, BookmarksScreen, SearchScreen,
                                ProfileScreen, MoreScreen, OnboardingScreen
    ui/viewmodel/               HomeViewModel, GitaViewModel, AiChatViewModel
    di/AndroidModule.kt         Koin: LocalBookmarkRepository, LocalUserRepository, ViewModels
    data/                       DataStore-backed BookmarkRepository & UserRepository

iosApp/                         iOS application (SwiftUI + KMP framework)
  iosApp/iOSApp.swift           App entry point — calls initKoin()
  iosApp/ContentView.swift      Tab navigation (placeholder screens)

backend/                        FastAPI backend (AI chat, TTS, STT)
local.properties.template       Copy → local.properties and fill secrets
```

---

## Building

### Android (Android Studio)

1. Copy `local.properties.template` → `local.properties`
2. Fill in `sdk.dir` and `ed25519.private.key` (see below)
3. Open the **root** project in Android Studio (not `android/`)
4. Run the `androidApp` configuration on an emulator or device (API 26+)

### iOS (Xcode on macOS)

1. Build the KMP XCFramework:
   ```bash
   ./gradlew shared:assembleReleaseXCFramework
   ```
2. Open `iosApp/iosApp.xcodeproj` in Xcode, link the generated XCFramework
3. Add `ED25519PrivateKey` to the Xcode scheme's environment variables
4. Run on simulator or device (iOS 16+)

---

## Required Secrets

### Ed25519 Private Key (gateway signing)

The Cloudflare Worker at `https://api-gateway.kuldeepky538.workers.dev/` verifies every request with Ed25519. The app signs requests; the Worker verifies with its embedded public key:

```
MCowBQYDK2VwAyEAa4ZxuobCuaSe+HMbCc7YW7AG/W5SELvpc7NNBVX9ab4=
```

**To set up the signing key:**
```bash
# Generate a new key pair
openssl genpkey -algorithm ed25519 -out private.pem

# Export the 32-byte private seed as base64 → put in local.properties
openssl pkey -in private.pem -outform DER | tail -c 32 | base64

# Verify the public key matches what's in the Worker
openssl pkey -in private.pem -pubout | openssl pkey -pubin -outform DER | base64
```

Add to `local.properties`:
```
ed25519.private.key=<your-base64-seed>
```

> ⚠️ The Worker's current public key was pre-deployed. If you generate a **new** key pair you must also update the `PUBLIC_KEY_BASE64` constant in the Cloudflare Worker (`index.js`).

### Backend API Keys (Cloudflare Worker environment)

Store these in the Cloudflare Worker's **Secrets/KV** so the gateway can serve them:

| Key name (X-API-Name) | Purpose |
|---|---|
| `GEMINI_AI_API_KEY` | Google Gemini 1.5 Flash — AI chat |
| `HF_TTS_API_KEY` | Hugging Face TTS (`microsoft/speecht5_tts`) |
| `HF_STT_API_KEY` | Hugging Face STT (`openai/whisper-base`) |
| `HF_CHAT_API_KEY` | Hugging Face chat fallback |

### Google Sign-In

Web Client ID is already set in `AppConfig.GOOGLE_WEB_CLIENT_ID`. No additional secret needed for the app — just ensure the SHA-1 fingerprint of your release keystore is registered in Google Cloud Console.

---

## Architecture Overview

```
Android/iOS App
      │
      │  Ed25519-signed request (X-API-Name, X-Timestamp, X-Nonce, X-Signature)
      ▼
Cloudflare Workers Gateway  ←──── API keys stored as Worker Secrets/KV
      │
      │  Returns { api_key: "..." }
      │
      ▼
App uses key to call:
  • FastAPI backend (/ask, /tts, /stt)  ← backend/ directory
  • Gemini API directly (if needed)
  • Hugging Face Inference API
```

---

## Key Constants (AppConfig.kt)

| Constant | Value |
|---|---|
| `GATEWAY_BASE_URL` | `https://api-gateway.kuldeepky538.workers.dev/` |
| `GOOGLE_WEB_CLIENT_ID` | `479687771729-c2k3...` |
| `WEBSITE_URL` | `https://nexusweb.co.in` |
| `DISCORD_URL` | `https://discord.gg/cnxzhBQFU` |
| `TOTAL_CHAPTERS` | 18 |
| `TOTAL_VERSES` | 700 |

---

## User Preferences

<!-- Add user preferences here as they are expressed -->
