package com.nexuswavetech.geetanexus.data.remote

import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.network.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive

/**
 * Remote data source that routes ALL API calls through the Cloudflare Gateway.
 * No API keys are ever exposed on the client — they are fetched securely at runtime.
 */
class GitaRemoteDataSource(
    private val gatewayClient: CloudflareGatewayClient
) {
    private val json = Json { ignoreUnknownKeys = true; isLenient = true }
    private val httpClient = HttpClient {
        install(ContentNegotiation) { json(json) }
    }

    // ── Gita content (public DharmicData GitHub — no auth needed) ─────────────

    suspend fun fetchChapters(): List<ChapterDto> =
        httpClient.get(AppConfig.DharmicData.CHAPTERS).body()

    suspend fun fetchVerses(chapterNumber: Int): List<VerseDto> =
        httpClient.get(AppConfig.DharmicData.chapter(chapterNumber)).body()

    // ── AI Chat via Gemini (key fetched securely from Cloudflare) ─────────────

    suspend fun askGemini(
        query: String,
        systemContext: String = SPIRITUAL_SYSTEM_CONTEXT
    ): String {
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.GEMINI)
        val url = "${AppConfig.Gemini.BASE_URL}models/${AppConfig.Gemini.MODEL}:generateContent?key=$apiKey"

        val request = GeminiRequest(
            contents = listOf(
                GeminiContent(
                    role = "user",
                    parts = listOf(GeminiPart("$systemContext\n\nQuestion: $query"))
                )
            ),
            generationConfig = GeminiConfig(temperature = 0.7f, maxOutputTokens = 1024)
        )

        val response: GeminiResponse = httpClient.post(url) {
            contentType(ContentType.Application.Json)
            setBody(request)
        }.body()

        return response.candidates?.firstOrNull()
            ?.content?.parts?.firstOrNull()?.text
            ?: "🙏 I reflect upon your question with silence."
    }

    // ── TTS via Hugging Face (key fetched securely from Cloudflare) ───────────

    suspend fun textToSpeech(text: String): ByteArray {
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.HF_TTS)
        val url = "${AppConfig.HuggingFace.BASE_URL}${AppConfig.HuggingFace.TTS_MODEL}"

        val responseBytes: ByteArray = httpClient.post(url) {
            header("Authorization", "Bearer $apiKey")
            contentType(ContentType.Application.Json)
            setBody(HFTtsRequest(inputs = text))
        }.body()

        return responseBytes
    }

    // ── STT via Hugging Face (key fetched securely from Cloudflare) ───────────

    suspend fun speechToText(audioBase64: String): String {
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.HF_STT)
        val url = "${AppConfig.HuggingFace.BASE_URL}${AppConfig.HuggingFace.STT_MODEL}"

        val response: HFSttResponse = httpClient.post(url) {
            header("Authorization", "Bearer $apiKey")
            contentType(ContentType.Application.Json)
            setBody(HFSttRequest(audioBase64))
        }.body()

        return response.text ?: ""
    }

    companion object {
        const val SPIRITUAL_SYSTEM_CONTEXT = """You are Aira, a compassionate AI guide specializing in the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas.
Answer with wisdom, cite specific verses where relevant, and keep responses concise yet meaningful.
Always respond with empathy and spiritual insight. End with a relevant Sanskrit verse or doha if appropriate.
Do not make up verse references — only cite verses you know with certainty."""
    }
}
