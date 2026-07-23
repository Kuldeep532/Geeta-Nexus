package com.nexuswavetech.geetanexus.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.domain.models.*
import com.nexuswavetech.geetanexus.domain.repository.QuizRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class QuizViewModel(
    private val quizRepository: QuizRepository
) : ViewModel() {

    private val _session    = MutableStateFlow<QuizSession?>(null)
    private val _isLoading  = MutableStateFlow(false)
    private val _error      = MutableStateFlow<String?>(null)

    val session: StateFlow<QuizSession?>  = _session.asStateFlow()
    val isLoading: StateFlow<Boolean>     = _isLoading.asStateFlow()
    val error: StateFlow<String?>         = _error.asStateFlow()
    val categories: List<QuizCategory>   = QuizCategory.entries

    fun startQuiz(category: QuizCategory? = null, questionCount: Int = 10) {
        viewModelScope.launch {
            _isLoading.value = true
            _error.value = null
            quizRepository.getQuestions(category, questionCount)
                .onSuccess { questions ->
                    _session.value = QuizSession(questions = questions)
                }
                .onFailure { e ->
                    _error.value = "Failed to load quiz: ${e.message}"
                }
            _isLoading.value = false
        }
    }

    fun answerQuestion(questionId: String, chosenIndex: Int) {
        val current = _session.value ?: return
        val newAnswers = current.answers + (questionId to chosenIndex)
        val nextIndex  = current.currentIndex + 1
        val isComplete = nextIndex >= current.totalQuestions
        _session.value = current.copy(
            answers      = newAnswers,
            currentIndex = if (isComplete) current.currentIndex else nextIndex,
            isComplete   = isComplete
        )
    }

    fun resetQuiz() {
        _session.value = null
    }

    val currentQuestion: QuizQuestion? get() =
        _session.value?.let { it.questions.getOrNull(it.currentIndex) }
}
