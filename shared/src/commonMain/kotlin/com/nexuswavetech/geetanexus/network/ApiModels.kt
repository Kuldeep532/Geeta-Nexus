package com.nexuswavetech.geetanexus.network

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

// ── Cloudflare Gateway ───────────────────────────────────────────────────────

@Serializable
data class GatewayResponse(
    val status: String,
    @SerialName("requested_api") val requestedApi: String? = null,
    @SerialName("api_key")       val apiKey: String? = null,
    val error: String? = null,
    @SerialName("message_en")    val messageEn: String? = null,
    @SerialName("message_hn")    val messageHn: String? = null
)

// ── AI Chat (direct Gemini via Cloudflare-fetched key) ───────────────────────

@Serializable
data class GeminiRequest(
    val contents: List<GeminiContent>,
    @SerialName("generationConfig") val generationConfig: GeminiConfig? = null
)

@Serializable
data class GeminiContent(
    val role: String = "user",
    val parts: List<GeminiPart>
)

@Serializable
data class GeminiPart(val text: String)

@Serializable
data class GeminiConfig(
    val temperature: Float = 0.7f,
    @SerialName("maxOutputTokens") val maxOutputTokens: Int = 1024
)

@Serializable
data class GeminiResponse(
    val candidates: List<GeminiCandidate>? = null,
    val error: GeminiError? = null
)

@Serializable
data class GeminiCandidate(
    val content: GeminiContent? = null
)

@Serializable
data class GeminiError(
    val message: String,
    val code: Int = 0
)

// ── TTS / STT (Hugging Face via Cloudflare-fetched key) ──────────────────────

@Serializable
data class HFTtsRequest(val inputs: String)

@Serializable
data class HFSttRequest(@SerialName("inputs") val audioBase64: String)

@Serializable
data class HFSttResponse(val text: String? = null)

// ── Gita Domain ───────────────────────────────────────────────────────────────

@Serializable
data class ChapterDto(
    val chapter_number: Int,
    val name: String,
    val name_transliterated: String,
    val name_translated: String,
    val verses_count: Int,
    val chapter_summary: String? = null
)

@Serializable
data class VerseDto(
    val chapter_number: Int,
    val verse_number: Int,
    val text: String,
    val transliteration: String? = null,
    val word_meanings: String? = null,
    val translation: String? = null,
    val commentary: String? = null
)

// ── Legacy (kept for compatibility) ──────────────────────────────────────────

@Serializable
data class AskRequest(
    val query: String,
    @SerialName("session_id") val sessionId: String? = null
)

@Serializable
data class TtsRequest(val text: String, val voice: String? = null)

@Serializable
data class SttRequest(@SerialName("audio_base64") val audioBase64: String)
