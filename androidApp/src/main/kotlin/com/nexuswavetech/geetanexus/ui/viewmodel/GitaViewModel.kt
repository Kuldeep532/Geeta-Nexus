package com.nexuswavetech.geetanexus.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.nexuswavetech.geetanexus.domain.models.Chapter
import com.nexuswavetech.geetanexus.domain.models.Verse
import com.nexuswavetech.geetanexus.domain.repository.BookmarkRepository
import com.nexuswavetech.geetanexus.domain.repository.GitaRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

// ── State ─────────────────────────────────────────────────────────────────────

sealed interface GitaUiState {
    data object Loading : GitaUiState
    data class Success(val chapters: List<Chapter>) : GitaUiState
    data class Error(val message: String) : GitaUiState
}

sealed interface VerseUiState {
    data object Loading : VerseUiState
    data class Success(val verses: List<Verse>, val currentIndex: Int = 0) : VerseUiState
    data class Error(val message: String) : VerseUiState
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

class GitaViewModel(
    private val gitaRepository: GitaRepository,
    private val bookmarkRepository: BookmarkRepository
) : ViewModel() {

    private val _chaptersState = MutableStateFlow<GitaUiState>(GitaUiState.Loading)
    val chaptersState: StateFlow<GitaUiState> = _chaptersState.asStateFlow()

    private val _versesState = MutableStateFlow<VerseUiState>(VerseUiState.Loading)
    val versesState: StateFlow<VerseUiState> = _versesState.asStateFlow()

    // Single-verse state (used by VerseReaderScreen)
    private val _currentVerseState = MutableStateFlow<VerseUiState>(VerseUiState.Loading)
    val currentVerseState: StateFlow<VerseUiState> = _currentVerseState.asStateFlow()

    private val _bookmarkedIds = MutableStateFlow<Set<String>>(emptySet())
    val bookmarkedIds: StateFlow<Set<String>> = _bookmarkedIds.asStateFlow()

    // Is the currently displayed single verse bookmarked?
    val isCurrentVerseBookmarked: StateFlow<Boolean> = combine(
        _currentVerseState, _bookmarkedIds
    ) { state, ids ->
        val verse = (state as? VerseUiState.Success)?.verses?.firstOrNull()
        verse?.let { ids.contains(it.id) } ?: false
    }.stateIn(viewModelScope, SharingStarted.Eagerly, false)

    private val _searchResults = MutableStateFlow<List<Verse>>(emptyList())
    val searchResults: StateFlow<List<Verse>> = _searchResults.asStateFlow()

    init {
        loadChapters()
        loadBookmarks()
    }

    fun loadChapters() = viewModelScope.launch {
        _chaptersState.value = GitaUiState.Loading
        gitaRepository.getChapters()
            .onSuccess { _chaptersState.value = GitaUiState.Success(it) }
            .onFailure { _chaptersState.value = GitaUiState.Error(it.message ?: "Failed to load chapters") }
    }

    fun loadVerses(chapterNumber: Int) = viewModelScope.launch {
        _versesState.value = VerseUiState.Loading
        gitaRepository.getVerses(chapterNumber)
            .onSuccess { _versesState.value = VerseUiState.Success(it) }
            .onFailure { _versesState.value = VerseUiState.Error(it.message ?: "Failed to load verses") }
    }

    /** Load a single verse for the VerseReaderScreen. */
    fun loadVerse(chapterNumber: Int, verseNumber: Int) = viewModelScope.launch {
        _currentVerseState.value = VerseUiState.Loading
        gitaRepository.getVerse(chapterNumber, verseNumber)
            .onSuccess { _currentVerseState.value = VerseUiState.Success(listOf(it)) }
            .onFailure { _currentVerseState.value = VerseUiState.Error(it.message ?: "Failed to load verse") }
    }

    fun goToVerse(index: Int) {
        val current = _versesState.value
        if (current is VerseUiState.Success) {
            _versesState.value = current.copy(currentIndex = index.coerceIn(0, current.verses.lastIndex))
        }
    }

    fun toggleBookmark(verse: Verse) = viewModelScope.launch {
        if (bookmarkRepository.isBookmarked(verse.id)) {
            bookmarkRepository.removeBookmark(verse.id)
        } else {
            bookmarkRepository.addBookmark(verse.id)
        }
        loadBookmarks()
    }

    fun search(query: String) = viewModelScope.launch {
        if (query.isBlank()) { _searchResults.value = emptyList(); return@launch }
        gitaRepository.searchVerses(query)
            .onSuccess { _searchResults.value = it }
            .onFailure { _searchResults.value = emptyList() }
    }

    private fun loadBookmarks() = viewModelScope.launch {
        bookmarkRepository.getBookmarks()
            .onSuccess { _bookmarkedIds.value = it.map { v -> v.id }.toSet() }
    }
}
