package com.nexuswavetech.geetanexus.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.domain.models.AiSource
import com.nexuswavetech.geetanexus.domain.models.ChatMessage
import com.nexuswavetech.geetanexus.domain.repository.AiRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.UUID

class AiChatViewModel(
    private val aiRepository: AiRepository
) : ViewModel() {

    private val sessionId = UUID.randomUUID().toString()

    private val _messages = MutableStateFlow<List<ChatMessage>>(
        listOf(
            ChatMessage(
                id          = "welcome",
                content     = "Namaste 🙏 I am Aira, your AI Gita companion. Ask me anything about the Bhagavad Gita, life guidance, or spiritual wisdom.",
                isUser      = false,
                timestampMs = System.currentTimeMillis()
            )
        )
    )
    val messages: StateFlow<List<ChatMessage>> = _messages.asStateFlow()

    private val _isTyping = MutableStateFlow(false)
    val isTyping: StateFlow<Boolean> = _isTyping.asStateFlow()

    private val _inputText = MutableStateFlow("")
    val inputText: StateFlow<String> = _inputText.asStateFlow()

    fun onInputChanged(text: String) { _inputText.value = text }

    fun sendMessage() {
        val text = _inputText.value.trim()
        if (text.isBlank()) return

        val userMsg = ChatMessage(
            id          = UUID.randomUUID().toString(),
            content     = text,
            isUser      = true,
            timestampMs = System.currentTimeMillis()
        )
        _messages.value = _messages.value + userMsg
        _inputText.value = ""
        _isTyping.value  = true

        viewModelScope.launch {
            aiRepository.ask(text, sessionId)
                .onSuccess { response ->
                    val aiMsg = ChatMessage(
                        id          = UUID.randomUUID().toString(),
                        content     = response,
                        isUser      = false,
                        timestampMs = System.currentTimeMillis(),
                        source      = AiSource.GEMINI
                    )
                    _messages.value = _messages.value + aiMsg
                }
                .onFailure { err ->
                    val errMsg = ChatMessage(
                        id          = UUID.randomUUID().toString(),
                        content     = "Sorry, I couldn't connect right now. Please check your connection and try again.",
                        isUser      = false,
                        timestampMs = System.currentTimeMillis()
                    )
                    _messages.value = _messages.value + errMsg
                }
            _isTyping.value = false
        }
    }

    fun clearConversation() {
        _messages.value = listOf(
            ChatMessage(
                id          = UUID.randomUUID().toString(),
                content     = "Conversation cleared. Namaste 🙏 How can I help you today?",
                isUser      = false,
                timestampMs = System.currentTimeMillis()
            )
        )
    }
}
