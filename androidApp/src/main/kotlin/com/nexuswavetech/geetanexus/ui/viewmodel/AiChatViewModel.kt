package com.nexuswavetech.geetanexus.ui.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.domain.models.AiSource
import com.nexuswavetech.geetanexus.domain.models.ChatMessage
import com.nexuswavetech.geetanexus.network.CloudflareGatewayClient
import io.ktor.client.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlinx.serialization.json.*
import java.util.UUID

/**
 * AI Chat ViewModel.
 *
 * All API calls go through the Cloudflare Gateway — no keys on the client.
 * Flow: User message → Gemini (via Cloudflare key) → fallback response.
 * FastAPI backend has been removed; all AI is direct Gemini.
 */
class AiChatViewModel(
    private val gatewayClient: CloudflareGatewayClient
) : ViewModel() {

    private val tag = "AiChatViewModel"
    private val json = Json { ignoreUnknownKeys = true; isLenient = true }

    private val httpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) { json(json) }
    }

    private val _messages = MutableStateFlow<List<ChatMessage>>(listOf(welcomeMessage()))
    private val _isTyping = MutableStateFlow(false)
    private val _error    = MutableStateFlow<String?>(null)

    val messages: StateFlow<List<ChatMessage>> = _messages.asStateFlow()
    val isTyping: StateFlow<Boolean>           = _isTyping.asStateFlow()
    val error:    StateFlow<String?>           = _error.asStateFlow()

    fun sendMessage(userText: String) {
        if (userText.isBlank()) return
        val userMsg = ChatMessage(
            id        = UUID.randomUUID().toString(),
            text      = userText.trim(),
            isUser    = true,
            timestamp = System.currentTimeMillis()
        )
        _messages.value = _messages.value + userMsg
        _isTyping.value = true
        _error.value    = null

        viewModelScope.launch {
            try {
                val reply = askGemini(userText) ?: fallbackResponse(userText)
                _messages.value = _messages.value + reply
            } catch (e: Exception) {
                Log.e(tag, "Chat error", e)
                _messages.value = _messages.value + ChatMessage(
                    id        = UUID.randomUUID().toString(),
                    text      = "I encountered an error. Please check your connection and try again. 🙏",
                    isUser    = false,
                    source    = AiSource.ERROR,
                    timestamp = System.currentTimeMillis()
                )
            } finally {
                _isTyping.value = false
            }
        }
    }

    fun clearConversation() { _messages.value = listOf(welcomeMessage()) }
    fun dismissError()      { _error.value = null }

    // ── Gemini via Cloudflare Gateway ─────────────────────────────────────────

    private suspend fun askGemini(question: String): ChatMessage? = try {
        // API key is fetched securely from Cloudflare — never stored on device
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.GEMINI)
        val url    = "${AppConfig.Gemini.BASE_URL}models/${AppConfig.Gemini.MODEL}:generateContent?key=$apiKey"

        val systemCtx = """You are Aira, a compassionate AI guide specializing in the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas.
Answer with wisdom, cite specific verses where relevant, and keep responses concise yet meaningful.
Always respond with empathy and spiritual insight. End with a relevant Sanskrit verse or doha if appropriate.
Do not make up verse references — only cite verses you know with certainty."""

        val body = buildJsonObject {
            putJsonArray("contents") {
                addJsonObject {
                    put("role", "user")
                    putJsonArray("parts") {
                        addJsonObject { put("text", "$systemCtx\n\nQuestion: $question") }
                    }
                }
            }
            putJsonObject("generationConfig") {
                put("temperature", 0.7)
                put("maxOutputTokens", 1024)
            }
        }

        val response: HttpResponse = httpClient.post(url) {
            contentType(ContentType.Application.Json)
            setBody(body.toString())
        }

        if (response.status == HttpStatusCode.OK) {
            val respJson = json.parseToJsonElement(response.bodyAsText()).jsonObject
            val text = respJson["candidates"]
                ?.jsonArray?.firstOrNull()?.jsonObject
                ?.get("content")?.jsonObject
                ?.get("parts")?.jsonArray?.firstOrNull()?.jsonObject
                ?.get("text")?.jsonPrimitive?.content
                ?: "I reflect upon your question with silence. 🙏"

            ChatMessage(
                id        = UUID.randomUUID().toString(),
                text      = text,
                isUser    = false,
                source    = AiSource.GEMINI,
                timestamp = System.currentTimeMillis()
            )
        } else {
            Log.w(tag, "Gemini returned ${response.status}")
            null
        }
    } catch (e: Exception) {
        Log.w(tag, "Gemini call failed: ${e.message}")
        null
    }

    // ── Offline fallback ──────────────────────────────────────────────────────

    private fun fallbackResponse(question: String): ChatMessage {
        val lower = question.lowercase()
        val response = when {
            lower.contains("karma")  ->
                "Karma means action with its fruits. BG 2.47: \"You have a right to perform your duties, but not to the fruits of your actions.\" Act without attachment. 🙏"
            lower.contains("dharma") ->
                "Dharma is your sacred duty. BG 3.35: \"Better is one's own dharma, though imperfectly performed, than the dharma of another well performed.\""
            lower.contains("moksha") || lower.contains("liberation") ->
                "Moksha is liberation from birth and death. BG 18.66: \"Abandon all varieties of dharma and surrender unto Me alone.\""
            lower.contains("bhakti") || lower.contains("love") ->
                "Bhakti — devotion — is the highest path. BG 12.2: \"Those who worship Me with faith, fixing their minds on My personal form — I consider them most perfect.\""
            lower.contains("shiva")  ->
                "Lord Shiva is Mahadev — the great transformer. The Shiva Mahapurana teaches: He who surrenders to Shiva with pure devotion crosses all sorrow. 🔱"
            lower.contains("ram") || lower.contains("rama") ->
                "Shri Ram embodies dharma. As Tulsidas writes: \"Raam naam mani dipa dharau jeeha dehri dwaar\" — Keep Ram's name as a jewel lamp at the door of your tongue. 🙏"
            lower.contains("meditation") || lower.contains("dhyana") ->
                "BG 6.10: \"A yogi should always try to concentrate his mind in solitude, having controlled his mind and body, free from hopes and greed.\" 🧘"
            lower.contains("fear") ->
                "BG 4.10: \"Freed from attachment, fear, and anger, absorbed in Me, taking refuge in Me, purified by the fire of knowledge — many have attained My nature.\" 🙏"
            else ->
                "Dear seeker, your question touches the depths of spiritual wisdom. Connect to the internet so Aira can access Gemini AI for a richer answer. 🪷\n\nFor now: The Gita, Shiva Purana, and Ramcharitmanas all point to one truth — surrender to the Divine with love and faith."
        }
        return ChatMessage(
            id        = UUID.randomUUID().toString(),
            text      = response,
            isUser    = false,
            source    = AiSource.LOCAL_KB,
            timestamp = System.currentTimeMillis()
        )
    }

    override fun onCleared() { httpClient.close(); super.onCleared() }

    companion object {
        private fun welcomeMessage() = ChatMessage(
            id        = "welcome",
            text      = "Namaste 🙏 I am **Aira**, your spiritual guide. I can answer questions about the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas.\n\nAsk me anything about dharma, karma, devotion, or spiritual wisdom.",
            isUser    = false,
            source    = AiSource.LOCAL_KB,
            timestamp = System.currentTimeMillis()
        )
    }
}
