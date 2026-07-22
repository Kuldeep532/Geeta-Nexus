package com.nexuswavetech.geetanexus.domain.models

import kotlinx.serialization.Serializable

// ── Core Gita Models ─────────────────────────────────────────────────────────

data class Chapter(
    val number: Int,
    val name: String,               // Sanskrit name, e.g. "Arjuna Visada Yoga"
    val nameTransliterated: String, // e.g. "Arjun Viṣhāda Yog"
    val nameTranslated: String,     // English meaning
    val versesCount: Int,
    val summary: String = ""
)

data class Verse(
    val chapterNumber: Int,
    val verseNumber: Int,
    val sanskrit: String,
    val transliteration: String = "",
    val wordMeanings: String = "",
    val translation: String = "",
    val commentary: String = "",
    val isBookmarked: Boolean = false
) {
    val id: String get() = "$chapterNumber.$verseNumber"
    val displayNumber: String get() = "BG $chapterNumber.$verseNumber"
}

// ── Journal ──────────────────────────────────────────────────────────────────

data class JournalEntry(
    val id: String,
    val content: String,
    val mood: Mood = Mood.NEUTRAL,
    val timestampMs: Long,
    val verseRef: String? = null    // Optional linked verse, e.g. "2.47"
)

enum class Mood { PEACEFUL, JOYFUL, NEUTRAL, ANXIOUS, SAD, REFLECTIVE }

// ── Sadhana / Daily Practice ─────────────────────────────────────────────────

data class SadhanaTask(
    val id: String,
    val title: String,
    val durationMinutes: Int = 0,
    val isCompleted: Boolean = false,
    val category: SadhanaCategory = SadhanaCategory.GENERAL
)

enum class SadhanaCategory { JAPA, MEDITATION, GITA_READING, PRANAYAMA, GENERAL }

data class DailySadhanaRecord(
    val dateIso: String,            // "YYYY-MM-DD"
    val tasks: List<SadhanaTask>,
    val streakDays: Int = 0
)

// ── AI Chat ──────────────────────────────────────────────────────────────────

data class ChatMessage(
    val id: String,
    val content: String,
    val isUser: Boolean,
    val timestampMs: Long,
    val source: AiSource? = null
)

enum class AiSource { LOCAL_KB, GEMINI, HUGGING_FACE }

// ── Quiz ─────────────────────────────────────────────────────────────────────

data class QuizQuestion(
    val id: String,
    val question: String,
    val options: List<String>,
    val correctIndex: Int,
    val explanation: String = "",
    val verseRef: String? = null
)

// ── Community / Satsang ──────────────────────────────────────────────────────

data class SatsangPost(
    val id: String,
    val authorName: String,
    val authorAvatarUrl: String? = null,
    val content: String,
    val verseRef: String? = null,
    val likesCount: Int = 0,
    val isLikedByMe: Boolean = false,
    val timestampMs: Long,
    val category: String = "General"
)

// ── User / Auth ──────────────────────────────────────────────────────────────

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
        in 1..3   -> "Seeker"
        in 4..7   -> "Sadhaka"
        in 8..12  -> "Yogi"
        in 13..18 -> "Gyani"
        else      -> "Siddha"
    }
}
