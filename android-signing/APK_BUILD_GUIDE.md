# Geeta Nexus — Android APK Build Guide

Builds run automatically on GitHub Actions. No laptop needed — just your phone.

---

## How to build an APK (from your phone)

1. Open your GitHub repo in a browser
2. Tap **Actions** tab
3. Tap **Geeta AI - Manual Build**
4. Tap **Run workflow** → **Run workflow**
5. Wait about 5–10 minutes for the green tick
6. Tap the finished build → scroll to **Artifacts** → tap **manual-release-apk** to download

---

## GitHub Secrets required

These must be set under **Settings → Secrets and variables → Actions**:

| Secret name        | What it is                                      |
|--------------------|-------------------------------------------------|
| `KEYSTORE_BASE64`  | The signing keystore encoded as base64          |
| `KEYSTORE_PASSWORD`| Password for the keystore file                  |
| `KEY_ALIAS`        | Key alias inside the keystore                   |
| `KEY_PASSWORD`     | Password for the key                            |
| `GOOGLE_SERVICES_JSON` | google-services.json encoded as base64     |
| `GEMINI_AI_API_KEY`| Your Gemini API key                             |

---

## Keystore details (kept in GitHub Secrets, not in this repo)

| Field          | Value             |
|----------------|-------------------|
| Alias          | `my-key-alias`    |
| Format         | JKS               |
| Package        | `com.satviktechnologies.geetanexus` |

The `.jks` keystore file is **not stored in this repo**.
It is decoded at build time from the `KEYSTORE_BASE64` GitHub secret.

---

## Install the APK on your phone

1. Open the download link on your Android phone
2. Go to **Settings → Security → Install unknown apps** and allow your browser
3. Tap the downloaded APK to install

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails with "keystore not found" | Check that all 4 keystore secrets are added in GitHub |
| Signing error | Make sure `KEYSTORE_PASSWORD`, `KEY_ALIAS`, `KEY_PASSWORD` match what was used when creating the keystore |
| Google services error | Re-encode your `google-services.json` with base64 and update the secret |
