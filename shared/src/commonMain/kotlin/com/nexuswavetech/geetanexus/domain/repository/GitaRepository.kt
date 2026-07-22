package com.nexuswavetech.geetanexus.domain.repository

import com.nexuswavetech.geetanexus.domain.models.*

/** Pure domain contract — no framework dependencies. */
interface GitaRepository {
    suspend fun getChapters(): Result<List<Chapter>>
    suspend fun getVerses(chapterNumber: Int): Result<List<Verse>>
    suspend fun getVerse(chapterNumber: Int, verseNumber: Int): Result<Verse>
    suspend fun searchVerses(query: String): Result<List<Verse>>
}

interface BookmarkRepository {
    suspend fun getBookmarks(): Result<List<Verse>>
    suspend fun addBookmark(verseId: String): Result<Unit>
    suspend fun removeBookmark(verseId: String): Result<Unit>
    suspend fun isBookmarked(verseId: String): Boolean
}

interface AiRepository {
    suspend fun ask(query: String, sessionId: String? = null): Result<String>
    suspend fun textToSpeech(text: String): Result<ByteArray>
    suspend fun speechToText(audioBytes: ByteArray): Result<String>
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
    suspend fun signOut()
    suspend fun updateProfile(profile: UserProfile): Result<Unit>
}
