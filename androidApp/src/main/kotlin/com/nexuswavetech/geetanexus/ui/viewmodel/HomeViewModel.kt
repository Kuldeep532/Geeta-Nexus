package com.nexuswavetech.geetanexus.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.domain.models.Verse
import com.nexuswavetech.geetanexus.domain.models.UserProfile
import com.nexuswavetech.geetanexus.domain.repository.GitaRepository
import com.nexuswavetech.geetanexus.domain.repository.UserRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import kotlin.random.Random

class HomeViewModel(
    private val gitaRepository: GitaRepository,
    private val userRepository: UserRepository
) : ViewModel() {

    private val _dailyVerse  = MutableStateFlow<Verse?>(null)
    val dailyVerse: StateFlow<Verse?> = _dailyVerse.asStateFlow()

    private val _currentUser = MutableStateFlow<UserProfile?>(null)
    val currentUser: StateFlow<UserProfile?> = _currentUser.asStateFlow()

    private val _isLoading   = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init {
        loadDailyVerse()
        loadUser()
    }

    private fun loadDailyVerse() = viewModelScope.launch {
        _isLoading.value = true
        val dayOfYear  = java.time.LocalDate.now().dayOfYear
        val chapterNum = (dayOfYear % 18) + 1
        gitaRepository.getVerses(chapterNum)
            .onSuccess { verses ->
                if (verses.isNotEmpty()) _dailyVerse.value = verses[dayOfYear % verses.size]
            }
        _isLoading.value = false
    }

    fun loadUser() = viewModelScope.launch {
        _currentUser.value = userRepository.getCurrentUser()
    }

    fun signOut() = viewModelScope.launch {
        userRepository.signOut()
        _currentUser.value = null
    }

    fun refreshDailyVerse() = viewModelScope.launch {
        val chapter = Random.nextInt(1, 19)
        gitaRepository.getVerses(chapter)
            .onSuccess { if (it.isNotEmpty()) _dailyVerse.value = it.random() }
    }
}
