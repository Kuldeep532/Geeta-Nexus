# Bhagavad Gita AI — APK & iOS Build Guide

## Keystore (Android Signing) — Already Generated

| Field             | Value                                              |
|-------------------|----------------------------------------------------|
| File              | `android-signing/gita-ai-release.keystore`         |
| Alias             | `gita-ai-key`                                      |
| Store Password    | `GitaAI@2024`                                      |
| Key Password      | `GitaAI@2024`                                      |
| Format            | PKCS12                                             |
| Package           | `com.kuldeep.gitaai`                               |

---

## Step 1 — One-time Setup (do this once on your computer)

### 1a. Install EAS CLI
```bash
npm install -g eas-cli
```

### 1b. Create a free Expo account
Sign up at https://expo.dev/signup

### 1c. Log in
```bash
eas login
```

### 1d. Link the project to your Expo account
Run this from inside the `gita-ai` folder:
```bash
eas init
```
- This will create or link a project on your Expo account
- It automatically updates `app.json` with your real `projectId`
- **Do this only once**

---

## Step 2 — Download the project

Download the entire `gita-ai` folder from Replit to your local machine.

---

## Step 3 — Install dependencies

From inside the `gita-ai` folder:
```bash
npm install
```

---

## Step 4 — Build

### Android APK (recommended — for testing on your phone)
```bash
eas build --platform android --profile preview
```
- Uses the signing keystore in `android-signing/`
- Builds in Expo's free cloud (~10–15 minutes)
- You get a direct download link when it's done

### Android APK with dev tools
```bash
eas build --platform android --profile development
```

### Android AAB (for Google Play Store)
```bash
eas build --platform android --profile production
```

---

## Step 5 — Install the APK on your Android phone

1. Open the download link on your Android device
2. Go to **Settings > Security > Install unknown apps** and enable for your browser
3. Tap the downloaded APK to install it

---

## iOS Build

### Simulator build (free, no Apple account needed)
```bash
eas build --platform ios --profile development
```

### Real device / TestFlight (requires Apple Developer account — $99/year)
```bash
eas build --platform ios --profile preview
```
EAS handles Apple provisioning profiles automatically.

---

## Using the Expo Dashboard (No CLI needed)

1. Go to https://expo.dev and log in
2. Find your project under **Projects**
3. Click **Build**
4. Choose **Android** → **preview** profile → click **Build**
5. Download the APK when the build finishes

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `projectId` error in app.json | Run `eas init` to link your project |
| Keystore not found | Ensure `android-signing/gita-ai-release.keystore` exists |
| `eas` command not found | Run `npm install -g eas-cli` |
| Build fails | Check the full log at https://expo.dev in your build history |
| "package already exists" on Play Store | Increment `versionCode` in `app.json` android section |
