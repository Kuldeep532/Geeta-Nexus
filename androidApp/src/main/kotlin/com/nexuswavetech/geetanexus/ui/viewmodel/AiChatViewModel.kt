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
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.*
import java.util.UUID

class AiChatViewModel(
    private val gatewayClient: CloudflareGatewayClient
) : ViewModel() {

    private val tag = "AiChatViewModel"
    private val json = Json { ignoreUnknownKeys = true; isLenient = true }

    private val httpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) { json(json) }
    }

    // ── State ─────────────────────────────────────────────────────────────────
    private val _messages   = MutableStateFlow<List<ChatMessage>>(listOf(welcomeMessage()))
    private val _isTyping   = MutableStateFlow(false)
    private val _error      = MutableStateFlow<String?>(null)

    val messages: StateFlow<List<ChatMessage>> = _messages.asStateFlow()
    val isTyping: StateFlow<Boolean>           = _isTyping.asStateFlow()
    val error:    StateFlow<String?>           = _error.asStateFlow()

    // ── Public API ────────────────────────────────────────────────────────────

    fun sendMessage(userText: String) {
        if (userText.isBlank()) return
        val userMsg = ChatMessage(
            id = UUID.randomUUID().toString(),
            text = userText.trim(),
            isUser = true,
            timestamp = System.currentTimeMillis()
        )
        _messages.value = _messages.value + userMsg
        _isTyping.value = true
        _error.value = null

        viewModelScope.launch {
            try {
                val reply = askGemini(userText) ?: askBackend(userText) ?: fallbackResponse(userText)
                _messages.value = _messages.value + reply
            } catch (e: Exception) {
                Log.e(tag, "Chat error", e)
                _messages.value = _messages.value + ChatMessage(
                    id = UUID.randomUUID().toString(),
                    text = "I encountered an error. Please try again. 🙏",
                    isUser = false,
                    source = AiSource.ERROR,
                    timestamp = System.currentTimeMillis()
                )
            } finally {
                _isTyping.value = false
            }
        }
    }

    fun clearConversation() {
        _messages.value = listOf(welcomeMessage())
    }

    fun dismissError() { _error.value = null }

    // ── Gemini ────────────────────────────────────────────────────────────────

    private suspend fun askGemini(question: String): ChatMessage? = try {
        val apiKey = gatewayClient.getApiKey(AppConfig.ApiKeyName.GEMINI)
        val url    = "${AppConfig.Gemini.BASE_URL}models/${AppConfig.Gemini.MODEL}:generateContent?key=$apiKey"

        val systemContext = """You are Aira, a compassionate AI guide specializing in the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas. 
Answer with wisdom, cite specific verses where relevant, and keep responses concise yet meaningful. 
Always respond with empathy and spiritual insight. End with a relevant Sanskrit verse or doha if appropriate."""

        val body = buildJsonObject {
            putJsonArray("contents") {
                addJsonObject {
                    put("role", "user")
                    putJsonArray("parts") {
                        addJsonObject { put("text", "$systemContext\n\nQuestion: $question") }
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
                id = UUID.randomUUID().toString(),
                text = text,
                isUser = false,
                source = AiSource.GEMINI,
                timestamp = System.currentTimeMillis()
            )
        } else null
    } catch (e: Exception) {
        Log.w(tag, "Gemini failed: ${e.message}")
        null
    }

    // ── FastAPI Backend ───────────────────────────────────────────────────────

    private suspend fun askBackend(question: String): ChatMessage? = try {
        val url = "${AppConfig.BACKEND_BASE_URL}${AppConfig.BackendEndpoint.ASK}"
        val response: HttpResponse = httpClient.post(url) {
            contentType(ContentType.Application.Json)
            setBody("""{"question":"${question.replace("\"", "\\\"")}","language":"hi"}""")
        }
        if (response.status == HttpStatusCode.OK) {
            val body = json.parseToJsonElement(response.bodyAsText()).jsonObject
            val answer = body["answer"]?.jsonPrimitive?.content ?: return null
            val sourceStr = body["source"]?.jsonPrimitive?.content ?: "local"
            ChatMessage(
                id = UUID.randomUUID().toString(),
                text = answer,
                isUser = false,
                source = if (sourceStr == "gemini") AiSource.GEMINI else AiSource.LOCAL_KB,
                timestamp = System.currentTimeMillis()
            )
        } else null
    } catch (e: Exception) {
        Log.w(tag, "Backend failed: ${e.message}")
        null
    }

    // ── Fallback ──────────────────────────────────────────────────────────────

    private fun fallbackResponse(question: String): ChatMessage {
        val lower = question.lowercase()
        val response = when {
            lower.contains("karma")    -> "Karma means action with its fruits. As Krishna says in BG 2.47: \"You have a right to perform your duties, but not to the fruits of your actions.\" Act without attachment. 🙏"
            lower.contains("dharma")   -> "Dharma is your sacred duty — unique to your nature and station. BG 3.35: \"Better is one's own dharma, though imperfectly performed, than the dharma of another well performed.\""
            lower.contains("moksha") || lower.contains("liberation") -> "Moksha is liberation from the cycle of birth and death. BG 18.66: \"Abandon all varieties of dharma and simply surrender unto Me. I shall liberate you from all sinful reactions.\""
            lower.contains("love") || lower.contains("bhakti") -> "Bhakti — devotion — is the highest path. BG 12.2: \"Those who fix their minds on My personal form, always engaged in worshipping Me, endowed with great faith — I consider them to be the most perfect.\""
            lower.contains("shiva")    -> "Lord Shiva is Mahadev — the great destroyer and transformer. The Shiva Mahapurana reveals His grace: He who surrenders to Shiva with pure devotion crosses beyond all sorrow. 🔱"
            lower.contains("ram") || lower.contains("rama") -> "Shri Ram is the embodiment of dharma. As Tulsidas writes in Ramcharitmanas: \"Raam naam mani dipa dharau jeeha dehri dwaar\" — Keep Ram's name as a jewel lamp at the door of your tongue. 🙏"
            else -> "Dear seeker, your question touches the depths of spiritual wisdom. The Gita, Shiva Purana, and Ramcharitmanas all point to one truth: surrender to the Divine with love and faith. Connect to the internet so I can share deeper wisdom with you. 🪷"
        }
        return ChatMessage(
            id = UUID.randomUUID().toString(),
            text = response,
            isUser = false,
            source = AiSource.LOCAL_KB,
            timestamp = System.currentTimeMillis()
        )
    }

    override fun onCleared() { httpClient.close(); super.onCleared() }

    companion object {
        private fun welcomeMessage() = ChatMessage(
            id = "welcome",
            text = "Namaste 🙏 I am **Aira**, your spiritual guide. I can answer questions about the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas. Ask me anything about dharma, karma, devotion, or spiritual wisdom.",
            isUser = false,
            source = AiSource.LOCAL_KB,
            timestamp = System.currentTimeMillis()
        )
    }
}
