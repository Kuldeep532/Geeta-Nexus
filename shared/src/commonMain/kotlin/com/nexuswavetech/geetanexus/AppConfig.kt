package com.nexuswavetech.geetanexus

object AppConfig {
    // ── Identity ──────────────────────────────────────────────────────────────
    const val APP_NAME         = "Gita Nexus"
    const val COMPANY_NAME     = "Nexus Waves Technologies"
    const val COMPANY_EMAIL    = "support@nexusweb.co.in"
    const val APP_VERSION      = "2.0.0"

    // ── Cloudflare API Gateway ────────────────────────────────────────────────
    // All API keys are fetched through this gateway (Ed25519 signed requests).
    // No API keys are exposed on the client side.
    const val GATEWAY_BASE_URL = "https://api-gateway.kuldeepky538.workers.dev/"

    // Ed25519 private key seed (PKCS8 Base64).
    // Injected at build-time from CI/CD env var (ED25519_PRIVATE_KEY) or
    // local.properties (ed25519.private.key) via BuildConfig. NEVER hardcoded.
    var ED25519_PRIVATE_KEY_BASE64: String = ""

    // Google OAuth Web Client ID — injected from CI/CD or local.properties
    var GOOGLE_WEB_CLIENT_ID: String = ""

    // ── API Key Names (must match Cloudflare Worker secret names) ─────────────
    // Add these as secrets in your Cloudflare Worker dashboard:
    //   GEMINI_AI_API_KEY    → aistudio.google.com (Gemini 2.0 Flash)
    //   HF_CHAT_API_KEY      → huggingface.co (Mistral chat fallback)
    //   HF_TTS_API_KEY       → huggingface.co (SpeechT5 TTS)
    //   HF_STT_API_KEY       → huggingface.co (Whisper STT)
    //   FIREBASE_CONFIG      → JSON blob with Firebase project config
    object ApiKeyName {
        const val GEMINI        = "GEMINI_AI_API_KEY"
        const val HF_CHAT       = "HF_CHAT_API_KEY"
        const val HF_TTS        = "HF_TTS_API_KEY"
        const val HF_STT        = "HF_STT_API_KEY"
    }

    // ── Google Auth ───────────────────────────────────────────────────────────
    // Injected at runtime from BuildConfig
    const val GOOGLE_WEB_CLIENT_ID_PLACEHOLDER =
        "YOUR_GOOGLE_WEB_CLIENT_ID"

    // ── Social / Community ────────────────────────────────────────────────────
    object Social {
        const val WEBSITE   = "https://nexusweb.co.in"
        const val DISCORD   = "https://discord.gg/cnxzhBQFU"
        const val INSTAGRAM = "https://www.instagram.com/nexuswavetech/"
        const val LINKEDIN  = "https://www.linkedin.com/company/nexuswavetech/"
        const val FACEBOOK  = "https://www.facebook.com/nexuswavetech/"
        const val YOUTUBE   = "https://www.youtube.com/@NexusWavesTech"
        const val EMAIL     = "mailto:support@nexusweb.co.in"
    }

    // ── Hugging Face Models ───────────────────────────────────────────────────
    object HuggingFace {
        const val TTS_MODEL  = "microsoft/speecht5_tts"
        const val STT_MODEL  = "openai/whisper-base"
        const val CHAT_MODEL = "mistralai/Mistral-7B-Instruct-v0.2"
        const val BASE_URL   = "https://api-inference.huggingface.co/models/"
    }

    // ── Gemini ────────────────────────────────────────────────────────────────
    object Gemini {
        const val BASE_URL = "https://generativelanguage.googleapis.com/v1beta/"
        const val MODEL    = "gemini-2.0-flash"
    }

    // ── DharmicData (Bhagavad Gita JSON — public, no auth needed) ────────────
    object DharmicData {
        const val BASE_URL    = "https://raw.githubusercontent.com/gita/gita/master/data/json/"
        const val CHAPTERS    = "${BASE_URL}chapters.json"
        fun chapter(n: Int) = "${BASE_URL}chapter_${n}.json"
    }

    // ── Scripture constants ───────────────────────────────────────────────────
    const val TOTAL_CHAPTERS = 18
    const val TOTAL_VERSES   = 700

    // ── Notification ─────────────────────────────────────────────────────────
    object Notification {
        const val CHANNEL_ID           = "daily_verse"
        const val CHANNEL_NAME         = "Daily Verse"
        const val CHANNEL_DESC         = "Daily Bhagavad Gita verse notification"
        const val WORK_TAG             = "daily_verse_work"
        const val DEFAULT_HOUR         = 7   // 7 AM daily
        const val DEFAULT_MINUTE       = 0
    }

    // ── Offline cache ─────────────────────────────────────────────────────────
    const val OFFLINE_CACHE_PREFS = "gita_offline_cache"
}
