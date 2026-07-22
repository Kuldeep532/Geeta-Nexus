package com.nexuswavetech.geetanexus

/**
 * Central configuration for Geta Nexus — Nexus Wave Technologies.
 *
 * All environment constants, API endpoints, Cloudflare gateway config,
 * and corporate channels are defined here. Update only this file when
 * settings change; never scatter magic strings across the codebase.
 */
object AppConfig {

    // ── Identity ────────────────────────────────────────────────────────────
    const val PACKAGE_NAME  = "com.nexuswavetech.geetanexus"
    const val APP_NAME      = "Gita Nexus"
    const val COMPANY_NAME  = "Nexus Wave Technologies"

    // ── Cloudflare API Gateway ───────────────────────────────────────────────
    /**
     * All outgoing AI / data API calls are routed through this Workers gateway.
     * The gateway performs Ed25519 signature verification before forwarding the
     * request and returning the resolved API key to the client.
     */
    const val GATEWAY_BASE_URL = "https://api-gateway.kuldeepky538.workers.dev/"

    /**
     * Names used as [X-API-Name] when fetching keys from the gateway.
     * These must match the secret names stored in the Cloudflare Worker's
     * environment / KV namespace.
     */
    object ApiKeyName {
        const val GEMINI    = "GEMINI_AI_API_KEY"
        const val HF_CHAT   = "HF_CHAT_API_KEY"
        const val HF_TTS    = "HF_TTS_API_KEY"
        const val HF_STT    = "HF_STT_API_KEY"
    }

    // ── Authentication ───────────────────────────────────────────────────────
    /**
     * Google Web Client ID used with Android Credential Manager / One Tap.
     * Do NOT use an Android OAuth client ID here — the web client ID is
     * required to receive a server-side ID token.
     */
    const val GOOGLE_WEB_CLIENT_ID =
        "479687771729-c2k3cfiv50m6h7agj0nkckj6i1tm9pkh.apps.googleusercontent.com"

    // ── Ed25519 Signature ────────────────────────────────────────────────────
    /**
     * The Ed25519 private key used to sign gateway requests.
     *
     * HOW TO SET THIS UP:
     *   1. Generate a key pair (the matching public key is already deployed to
     *      the Cloudflare Worker):
     *        openssl genpkey -algorithm ed25519 -out private.pem
     *        openssl pkey -in private.pem -pubout -out public.pem
     *   2. Export the raw 32-byte private key seed as base64:
     *        openssl pkey -in private.pem -outform DER | tail -c 32 | base64
     *   3. Place the base64 string in local.properties:
     *        ed25519.private.key=<base64-seed>
     *   4. The build injects it as BuildConfig.ED25519_PRIVATE_KEY (androidApp).
     *
     * The Cloudflare Worker's verification public key:
     *   MCowBQYDK2VwAyEAa4ZxuobCuaSe+HMbCc7YW7AG/W5SELvpc7NNBVX9ab4=
     *
     * IMPORTANT: Never commit the real private key to source control.
     * This placeholder will cause signature failures at runtime until replaced.
     */
    var ED25519_PRIVATE_KEY_BASE64: String = "REPLACE_WITH_YOUR_ED25519_PRIVATE_KEY_BASE64"

    // ── Backend (FastAPI — self-hosted / Replit) ─────────────────────────────
    /** Direct FastAPI backend URL — used as fallback if gateway is unavailable. */
    const val BACKEND_BASE_URL = "https://your-backend.replit.app"

    object BackendEndpoint {
        const val HEALTH  = "/health"
        const val ASK     = "/ask"
        const val TTS     = "/tts"
        const val STT     = "/stt"
        const val FEEDBACK = "/feedback"
        const val RELOAD_KB = "/reload-kb"
    }

    // ── Hugging Face Models ──────────────────────────────────────────────────
    object HuggingFace {
        const val TTS_MODEL  = "microsoft/speecht5_tts"
        const val STT_MODEL  = "openai/whisper-base"
        const val CHAT_MODEL = "mistralai/Mistral-7B-Instruct-v0.2"
        const val INFERENCE_BASE = "https://api-inference.huggingface.co/models/"
    }

    // ── DharmicData GitHub sources ───────────────────────────────────────────
    object DharmicData {
        const val BASE_URL = "https://raw.githubusercontent.com/gita/BhagavadGita/master/"
        const val CHAPTER_LIST = "${BASE_URL}data/chapters.json"
        fun chapterVerses(n: Int) = "${BASE_URL}data/verses/chapter_${n}.json"
    }

    // ── Community & Corporate Links ──────────────────────────────────────────
    const val WEBSITE_URL   = "https://nexusweb.co.in"
    const val INSTAGRAM_URL = "https://www.instagram.com/nexuswave_technologies?igsh=MTBia3ZxODcwOTFrNg=="
    const val FACEBOOK_URL  = "https://www.facebook.com/profile.php?id=61590971301245"
    const val LINKEDIN_URL  = "https://www.linkedin.com/company/nexus-wave-technologies/"
    const val DISCORD_URL   = "https://discord.gg/cnxzhBQFU"

    // ── Spiritual Content Constants ──────────────────────────────────────────
    const val TOTAL_CHAPTERS = 18
    const val TOTAL_VERSES   = 700
}
