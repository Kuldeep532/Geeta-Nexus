package com.nexuswavetech.geetanexus.ui.viewmodel

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.domain.models.AiSource
import com.nexuswavetech.geetanexus.domain.models.ChatMessage
import com.nexuswavetech.geetanexus.domain.repository.AiRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.UUID

/**
 * ViewModel for the Aira AI chat screen.
 *
 * Architecture:
 *   UI → AiChatViewModel → AiRepository → AiRepositoryImpl → GitaRemoteDataSource
 *       → Cloudflare Gateway (key fetch) → Gemini API
 *
 * No API keys in the ViewModel or anywhere in the app.
 * Keys are fetched at runtime from the Cloudflare Worker.
 */
class AiChatViewModel(
    private val aiRepository: AiRepository
) : ViewModel() {

    private val tag = "AiChatViewModel"

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
                val response = aiRepository.ask(userText.trim())
                val aiText   = response.getOrNull() ?: fallbackResponse(userText)
                val source   = if (response.isSuccess) AiSource.GEMINI else AiSource.LOCAL_KB

                _messages.value = _messages.value + ChatMessage(
                    id        = UUID.randomUUID().toString(),
                    text      = aiText,
                    isUser    = false,
                    source    = source,
                    timestamp = System.currentTimeMillis()
                )
            } catch (e: Exception) {
                Log.e(tag, "Chat error", e)
                _messages.value = _messages.value + ChatMessage(
                    id        = UUID.randomUUID().toString(),
                    text      = fallbackResponse(userText),
                    isUser    = false,
                    source    = AiSource.LOCAL_KB,
                    timestamp = System.currentTimeMillis()
                )
            } finally {
                _isTyping.value = false
            }
        }
    }

    fun clearConversation() { _messages.value = listOf(welcomeMessage()) }
    fun dismissError()      { _error.value = null }

    // ── Offline Fallback ──────────────────────────────────────────────────────

    private fun fallbackResponse(question: String): String {
        val lower = question.lowercase()
        return when {
            lower.contains("karma")  ->
                "🙏 **Karma** — BG 2.47: \"You have a right to perform your duties, but not to the fruits of your actions.\" Act without attachment."
            lower.contains("dharma") ->
                "☯️ **Dharma** — BG 3.35: \"Better is one's own dharma, though imperfectly performed, than the dharma of another well performed.\""
            lower.contains("moksha") || lower.contains("liberation") ->
                "🕊️ **Moksha** — BG 18.66: \"Abandon all varieties of dharma and surrender unto Me alone. I shall deliver you from all sinful reactions.\""
            lower.contains("bhakti") || lower.contains("devotion") ->
                "💛 **Bhakti** — BG 12.2: \"Those who worship Me with faith and devotion, fixing their minds on My personal form — I consider them most perfect.\""
            lower.contains("shiva")  ->
                "🔱 **Lord Shiva** — The Shiva Mahapurana teaches: *ॐ नमः शिवाय* — He who surrenders to Shiva with pure devotion transcends all sorrow."
            lower.contains("ram") || lower.contains("rama") ->
                "🙏 **Shri Ram** — Tulsidas writes: *राम नाम मणि दीप धरु जीभा देहरी द्वार* — Keep Ram's name as a jewel lamp at the threshold of your tongue."
            lower.contains("meditation") || lower.contains("dhyana") ->
                "🧘 **Dhyana** — BG 6.10: \"A yogi should always try to concentrate the mind in solitude, having controlled both mind and body, free from hopes and greed.\""
            lower.contains("fear") ->
                "💪 **Fearlessness** — BG 4.10: \"Freed from attachment, fear, and anger, absorbed in Me — many have attained My divine nature.\""
            lower.contains("anger") || lower.contains("krodha") ->
                "🌊 **Anger** — BG 2.63: \"From anger comes delusion; from delusion, loss of memory; from loss of memory, destruction of discrimination; from that — he perishes.\""
            lower.contains("mind") || lower.contains("mann") ->
                "🌀 **The Mind** — BG 6.5: \"Elevate yourself through the power of your mind, not degrade yourself. The mind can be both friend and enemy.\""
            lower.contains("soul") || lower.contains("atma") ->
                "✨ **Atma** — BG 2.20: \"The soul is never born nor dies at any time. It has not come into being and will not come into being. It is unborn, eternal, ever-existing, and primeval.\""
            else ->
                "🪷 Connect to the internet so Aira can access Gemini AI for a complete answer.\n\nFor now: The Gita, Shiva Purana, and Ramcharitmanas all point to one truth — surrender to the Divine with love and faith. *सर्वधर्मान्परित्यज्य मामेकं शरणं व्रज।* 🙏"
        }
    }

    companion object {
        private fun welcomeMessage() = ChatMessage(
            id        = "welcome",
            text      = "नमस्ते 🙏 मैं **Aira** हूँ — आपकी आध्यात्मिक मार्गदर्शिका।\n\nमैं Bhagavad Gita, Shiva Mahapurana और Ramcharitmanas के बारे में आपके प्रश्नों का उत्तर दे सकती हूँ।\n\nDharma, Karma, Bhakti, या कोई भी आध्यात्मिक विषय — बेझिझक पूछें।",
            isUser    = false,
            source    = AiSource.LOCAL_KB,
            timestamp = System.currentTimeMillis()
        )
    }
}
