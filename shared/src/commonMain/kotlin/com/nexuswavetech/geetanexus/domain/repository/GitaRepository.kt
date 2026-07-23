package com.nexuswavetech.geetanexus.domain.repository

import com.nexuswavetech.geetanexus.domain.models.*
import kotlinx.coroutines.flow.Flow

/** Pure domain contracts — no framework dependencies. */

interface GitaRepository {
    suspend fun getChapters(): Result<List<Chapter>>
    suspend fun getVerses(chapterNumber: Int): Result<List<Verse>>
    suspend fun getVerse(chapterNumber: Int, verseNumber: Int): Result<Verse>
    suspend fun searchVerses(query: String): Result<List<Verse>>
}

interface BookmarkRepository {
    fun getBookmarksFlow(): Flow<List<BookmarkEntry>>
    suspend fun getBookmarks(): Result<List<BookmarkEntry>>
    suspend fun addBookmark(entry: BookmarkEntry): Result<Unit>
    suspend fun removeBookmark(verseId: String): Result<Unit>
    suspend fun isBookmarked(verseId: String): Boolean
}

interface AiRepository {
    suspend fun ask(query: String, sessionId: String? = null): Result<String>
    suspend fun textToSpeech(text: String): Result<ByteArray>
    suspend fun speechToText(audioBytes: ByteArray): Result<String>
}

interface NotesRepository {
    fun getNotesFlow(): Flow<List<VerseNote>>
    suspend fun getNotes(): Result<List<VerseNote>>
    suspend fun saveNote(note: VerseNote): Result<Unit>
    suspend fun deleteNote(noteId: String): Result<Unit>
    suspend fun getNotesForVerse(verseId: String): Result<List<VerseNote>>
}

interface ReadingPlanRepository {
    fun getActivePlanFlow(): Flow<ReadingPlan?>
    suspend fun getActivePlan(): Result<ReadingPlan?>
    suspend fun startPlan(plan: ReadingPlan): Result<Unit>
    suspend fun updateProgress(planId: String, completedDays: Int, chapter: Int, verse: Int): Result<Unit>
    suspend fun completePlan(planId: String): Result<Unit>
}

interface QuizRepository {
    suspend fun getQuestions(category: QuizCategory? = null, limit: Int = 10): Result<List<QuizQuestion>>
    suspend fun getAllCategories(): List<QuizCategory>
}

interface JournalRepository {
    suspend fun getEntries(): Result<List<JournalEntry>>
    suspend fun saveEntry(entry: JournalEntry): Result<Unit>
    suspend fun deleteEntry(id: String): Result<Unit>
}

interface SadhanaRepository {
    suspend fun getTodayRecord(): Result<DailySadhanaRecord>
    suspend fun saveRecord(record: DailySadhanaRecord): Result<Unit>
    suspend fun getStreak(): Int
}

interface UserRepository {
    suspend fun getCurrentUser(): UserProfile?
    suspend fun signInWithGoogle(idToken: String): Result<UserProfile>
    suspend fun signInWithEmailPassword(email: String, password: String): Result<UserProfile>
    suspend fun signUpWithEmailPassword(email: String, password: String, name: String): Result<UserProfile>
    suspend fun signInAsGuest(): Result<UserProfile>
    suspend fun signOut()
    suspend fun updateProfile(profile: UserProfile): Result<Unit>
    suspend fun deleteAccount(): Result<Unit>
}
