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

// ── AI Chat ──────────────────────────────────────────────────────────────────

@Serializable
data class AskRequest(
    val query: String,
    @SerialName("session_id") val sessionId: String? = null
)

@Serializable
data class AskResponse(
    val response: String,
    val source: String? = null,          // "local_kb" | "gemini" | "huggingface"
    val confidence: Float? = null
)

// ── TTS / STT ────────────────────────────────────────────────────────────────

@Serializable
data class TtsRequest(val text: String, val voice: String? = null)

@Serializable
data class TtsResponse(
    @SerialName("audio_base64") val audioBase64: String,
    val format: String = "wav"
)

@Serializable
data class SttRequest(@SerialName("audio_base64") val audioBase64: String)

@Serializable
data class SttResponse(val transcript: String)

// ── Feedback ─────────────────────────────────────────────────────────────────

@Serializable
data class FeedbackRequest(
    val name: String,
    val email: String,
    val message: String,
    val rating: Int? = null
)

@Serializable
data class FeedbackResponse(val status: String, val message: String)

// ── Gita Domain ──────────────────────────────────────────────────────────────

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
    val text: String,                    // Sanskrit
    val transliteration: String? = null,
    val word_meanings: String? = null,
    val translation: String? = null,
    val commentary: String? = null
)
