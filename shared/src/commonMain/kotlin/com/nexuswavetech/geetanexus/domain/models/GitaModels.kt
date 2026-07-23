package com.nexuswavetech.geetanexus.domain.models

import kotlinx.serialization.Serializable

// ── Bhagavad Gita ─────────────────────────────────────────────────────────────

data class Chapter(
    val number: Int,
    val name: String,
    val nameMeaning: String,
    val summary: String,
    val verseCount: Int,
    val verses: List<Verse> = emptyList()
)

data class Verse(
    val chapterNumber: Int,
    val verseNumber: Int,
    val text: String,
    val transliteration: String,
    val wordMeanings: String,
    val translation: String,
    val commentary: String,
    val id: String = "$chapterNumber.$verseNumber"
)

// ── Generic Scripture (Shiva Mahapurana, Ramcharitmanas, etc.) ────────────────

enum class ScriptureType(val displayName: String, val emoji: String, val language: String) {
    BHAGAVAD_GITA("Bhagavad Gita", "🪷", "Sanskrit"),
    SHIVA_MAHAPURANA("Shiva Mahapurana", "🔱", "Sanskrit"),
    RAMCHARITMANAS("Ramcharitmanas", "🙏", "Avadhi")
}

data class ScriptureSection(
    val id: String,
    val scripture: ScriptureType,
    val number: Int,
    val title: String,           // Samhita / Kanda / Chapter name
    val subtitle: String,        // Short description
    val description: String,     // Full summary
    val verseCount: Int,
    val audioUrl: String? = null // Pre-recorded audio URL if available
)

data class ScriptureVerse(
    val id: String,
    val sectionId: String,
    val number: Int,
    val originalText: String,    // Sanskrit / Avadhi
    val transliteration: String,
    val translation: String,
    val commentary: String = ""
)

// ── AI ────────────────────────────────────────────────────────────────────────

enum class AiSource { LOCAL_KB, GEMINI, HUGGING_FACE, ERROR }

data class ChatMessage(
    val id: String,
    val text: String,
    val isUser: Boolean,
    val source: AiSource = AiSource.LOCAL_KB,
    val timestamp: Long = 0L
)

// ── Bookmarks ─────────────────────────────────────────────────────────────────

data class BookmarkEntry(
    val verseId: String,
    val scripture: ScriptureType = ScriptureType.BHAGAVAD_GITA,
    val title: String,
    val preview: String,
    val chapterNumber: Int,
    val verseNumber: Int,
    val savedAt: Long = 0L
)

// ── Journal ───────────────────────────────────────────────────────────────────

data class JournalEntry(
    val id: String,
    val title: String,
    val content: String,
    val mood: Mood,
    val relatedVerseId: String? = null,
    val createdAt: Long = 0L
)

enum class Mood(val emoji: String, val label: String) {
    PEACEFUL("😌", "Peaceful"),
    CONTEMPLATIVE("🤔", "Contemplative"),
    GRATEFUL("🙏", "Grateful"),
    ENERGIZED("⚡", "Energized"),
    TROUBLED("😔", "Troubled")
}

// ── Sadhana ───────────────────────────────────────────────────────────────────

data class SadhanaTask(
    val id: String,
    val name: String,
    val targetMinutes: Int,
    val completedToday: Boolean = false,
    val streak: Int = 0
)

// ── Quiz ─────────────────────────────────────────────────────────────────────

data class QuizQuestion(
    val id: String,
    val question: String,
    val options: List<String>,
    val correctIndex: Int,
    val explanation: String,
    val verseRef: String? = null
)

// ── User ──────────────────────────────────────────────────────────────────────

@Serializable
data class UserProfile(
    val uid: String,
    val displayName: String,
    val email: String,
    val photoUrl: String? = null,
    val xp: Int = 0,
    val level: Int = 1,
    val chaptersRead: Set<Int> = emptySet(),
    val bookmarkedVerseIds: Set<String> = emptySet(),
    val streakDays: Int = 0
) {
    val levelTitle: String get() = when (level) {
        1    -> "Seeker"
        2    -> "Student"
        3    -> "Devotee"
        4    -> "Scholar"
        5    -> "Guru"
        else -> "Enlightened"
    }
    val xpForNextLevel: Int get() = level * 500
}

// ── Satsang / Community ───────────────────────────────────────────────────────

data class SatsangPost(
    val id: String,
    val authorName: String,
    val authorPhotoUrl: String?,
    val content: String,
    val verseRef: String?,
    val likes: Int = 0,
    val createdAt: Long = 0L
)
