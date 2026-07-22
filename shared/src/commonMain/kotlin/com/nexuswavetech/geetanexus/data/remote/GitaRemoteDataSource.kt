package com.nexuswavetech.geetanexus.data.remote

import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.network.*
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.request.forms.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json

class GitaRemoteDataSource(
    private val gatewayClient: CloudflareGatewayClient
) {
    private val json = Json { ignoreUnknownKeys = true; isLenient = true }
    private val httpClient = HttpClient {
        install(ContentNegotiation) { json(json) }
    }

    // ── Gita content (GitHub DharmicData) ────────────────────────────────────

    suspend fun fetchChapters(): List<ChapterDto> =
        httpClient.get(AppConfig.DharmicData.CHAPTER_LIST).body()

    suspend fun fetchVerses(chapterNumber: Int): List<VerseDto> =
        httpClient.get(AppConfig.DharmicData.chapterVerses(chapterNumber)).body()

    // ── AI — routes through FastAPI backend ──────────────────────────────────

    suspend fun askAi(request: AskRequest): AskResponse {
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.GEMINI)
        return httpClient.post("${AppConfig.BACKEND_BASE_URL}${AppConfig.BackendEndpoint.ASK}") {
            contentType(ContentType.Application.Json)
            bearerAuth(apiKey)
            setBody(request)
        }.body()
    }

    suspend fun textToSpeech(request: TtsRequest): TtsResponse {
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.HF_TTS)
        return httpClient.post("${AppConfig.BACKEND_BASE_URL}${AppConfig.BackendEndpoint.TTS}") {
            contentType(ContentType.Application.Json)
            bearerAuth(apiKey)
            setBody(request)
        }.body()
    }

    suspend fun speechToText(request: SttRequest): SttResponse {
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.HF_STT)
        return httpClient.post("${AppConfig.BACKEND_BASE_URL}${AppConfig.BackendEndpoint.STT}") {
            contentType(ContentType.Application.Json)
            bearerAuth(apiKey)
            setBody(request)
        }.body()
    }

    suspend fun submitFeedback(request: FeedbackRequest): FeedbackResponse =
        httpClient.post("${AppConfig.BACKEND_BASE_URL}${AppConfig.BackendEndpoint.FEEDBACK}") {
            contentType(ContentType.Application.Json)
            setBody(request)
        }.body()
}
