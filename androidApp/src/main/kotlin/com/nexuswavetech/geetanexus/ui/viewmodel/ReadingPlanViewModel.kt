package com.nexuswavetech.geetanexus.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.domain.models.ReadingPlan
import com.nexuswavetech.geetanexus.domain.models.ReadingPlanTemplates
import com.nexuswavetech.geetanexus.domain.repository.ReadingPlanRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

class ReadingPlanViewModel(
    private val repo: ReadingPlanRepository
) : ViewModel() {

    val activePlan: StateFlow<ReadingPlan?> = repo
        .getActivePlanFlow()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    val templates: List<ReadingPlan> = ReadingPlanTemplates.plans

    private val _isLoading   = MutableStateFlow(false)
    private val _message     = MutableStateFlow<String?>(null)

    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    val message: StateFlow<String?>   = _message.asStateFlow()

    fun startPlan(plan: ReadingPlan) {
        viewModelScope.launch {
            _isLoading.value = true
            repo.startPlan(plan)
                .onSuccess { _message.value = "Reading plan started! 🙏" }
                .onFailure { _message.value = "Could not start plan: ${it.message}" }
            _isLoading.value = false
        }
    }

    fun markDayComplete() {
        val plan = activePlan.value ?: return
        viewModelScope.launch {
            val newCompleted = plan.completedDays + 1
            if (newCompleted >= plan.totalDays) {
                repo.completePlan(plan.id)
                _message.value = "Congratulations! You completed the reading plan! 🎉"
            } else {
                repo.updateProgress(plan.id, newCompleted, plan.currentChapter, plan.currentVerse)
                _message.value = "Day ${newCompleted} completed! Keep going! 🔥"
            }
        }
    }

    fun dismissMessage() { _message.value = null }
}
