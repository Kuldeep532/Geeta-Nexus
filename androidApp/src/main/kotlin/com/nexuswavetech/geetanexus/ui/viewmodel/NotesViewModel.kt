package com.nexuswavetech.geetanexus.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.domain.models.Mood
import com.nexuswavetech.geetanexus.domain.models.VerseNote
import com.nexuswavetech.geetanexus.domain.repository.NotesRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import java.util.UUID

class NotesViewModel(
    private val notesRepository: NotesRepository
) : ViewModel() {

    val notes: StateFlow<List<VerseNote>> = notesRepository
        .getNotesFlow()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _savedEvent = MutableSharedFlow<Boolean>()
    val savedEvent: SharedFlow<Boolean> = _savedEvent.asSharedFlow()

    fun saveNote(
        verseId: String,
        verseTitle: String,
        content: String,
        mood: Mood = Mood.CONTEMPLATIVE,
        existingId: String? = null
    ) {
        if (content.isBlank()) return
        viewModelScope.launch {
            _isLoading.value = true
            val note = VerseNote(
                id         = existingId ?: UUID.randomUUID().toString(),
                verseId    = verseId,
                verseTitle = verseTitle,
                content    = content.trim(),
                mood       = mood,
                createdAt  = if (existingId == null) System.currentTimeMillis() else 0L,
                updatedAt  = System.currentTimeMillis()
            )
            val result = notesRepository.saveNote(note)
            _savedEvent.emit(result.isSuccess)
            _isLoading.value = false
        }
    }

    fun deleteNote(noteId: String) {
        viewModelScope.launch {
            notesRepository.deleteNote(noteId)
        }
    }
}
