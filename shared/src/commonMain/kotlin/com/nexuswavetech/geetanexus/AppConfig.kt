package com.nexuswavetech.geetanexus

object AppConfig {
    // ── Identity ──────────────────────────────────────────────────────────────
    const val APP_NAME         = "Gita Nexus"
    const val COMPANY_NAME     = "Nexus Waves Technologies"
    const val COMPANY_EMAIL    = "support@nexusweb.co.in"
    const val APP_VERSION      = "2.0.0"

    // ── Cloudflare API Gateway ────────────────────────────────────────────────
    const val GATEWAY_BASE_URL = "https://api-gateway.kuldeepky538.workers.dev/"

    // Ed25519 private key seed (Base64). Injected at build-time from local.properties
    // via BuildConfig (Android) or Info.plist (iOS). Never hardcode here.
    var ED25519_PRIVATE_KEY_BASE64: String = "REPLACE_WITH_YOUR_ED25519_PRIVATE_KEY_BASE64"

    // Ed25519 public key embedded in Cloudflare Worker (for reference/docs)
    const val ED25519_PUBLIC_KEY_BASE64 =
        "MCowBQYDK2VwAyEAa4ZxuobCuaSe+HMbCc7YW7AG/W5SELvpc7NNBVX9ab4="

    // ── API Key Names (must match Cloudflare Worker secret/KV variable names) ──
    // Add these exact names as secrets in your Cloudflare Worker dashboard:
    //   GEMINI_AI_API_KEY    → https://aistudio.google.com/  (Gemini 1.5 Flash)
    //   HF_CHAT_API_KEY      → https://huggingface.co/settings/tokens  (Mistral chat fallback)
    //   HF_TTS_API_KEY       → https://huggingface.co/settings/tokens  (SpeechT5 TTS)
    //   HF_STT_API_KEY       → https://huggingface.co/settings/tokens  (Whisper STT)
    object ApiKeyName {
        const val GEMINI   = "GEMINI_AI_API_KEY"
        const val HF_CHAT  = "HF_CHAT_API_KEY"
        const val HF_TTS   = "HF_TTS_API_KEY"
        const val HF_STT   = "HF_STT_API_KEY"
    }

    // ── Backend (FastAPI on Replit) ───────────────────────────────────────────
    const val BACKEND_BASE_URL = "https://your-backend.replit.app"
    object BackendEndpoint {
        const val ASK      = "/ask"
        const val TTS      = "/tts"
        const val STT      = "/stt"
        const val FEEDBACK = "/feedback"
        const val HEALTH   = "/health"
        const val RELOAD   = "/reload-kb"
    }

    // ── Google Auth ───────────────────────────────────────────────────────────
    const val GOOGLE_WEB_CLIENT_ID =
        "479687771729-c2k3skqr1j5c7l4k9p2m8r6n0e5f3b1x.apps.googleusercontent.com"

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
        const val MODEL    = "gemini-1.5-flash"
    }

    // ── DharmicData (Bhagavad Gita JSON) ─────────────────────────────────────
    object DharmicData {
        const val BASE_URL    = "https://raw.githubusercontent.com/gita/gita/master/data/json/"
        const val CHAPTERS    = "${BASE_URL}chapters.json"
        fun chapter(n: Int) = "${BASE_URL}chapter_${n}.json"
    }

    // ── Scripture constants ───────────────────────────────────────────────────
    const val TOTAL_CHAPTERS = 18
    const val TOTAL_VERSES   = 700
}
