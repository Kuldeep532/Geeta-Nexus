package com.nexuswavetech.geetanexus.data

import com.nexuswavetech.geetanexus.data.remote.GitaRemoteDataSource
import com.nexuswavetech.geetanexus.domain.models.*
import com.nexuswavetech.geetanexus.domain.repository.*

class GitaRepositoryImpl(
    private val remote: GitaRemoteDataSource
) : GitaRepository {

    private val chapterCache = mutableListOf<Chapter>()
    private val verseCache   = mutableMapOf<Int, List<Verse>>()

    override suspend fun getChapters(): Result<List<Chapter>> = runCatching {
        if (chapterCache.isNotEmpty()) return@runCatching chapterCache.toList()
        val dtos = remote.fetchChapters()
        val chapters = dtos.map { dto ->
            Chapter(
                number     = dto.chapter_number,
                name       = dto.name_translated,
                nameMeaning= dto.name_transliterated,
                summary    = dto.chapter_summary ?: "",
                verseCount = dto.verses_count
            )
        }
        chapterCache.addAll(chapters)
        chapters
    }

    override suspend fun getVerses(chapterNumber: Int): Result<List<Verse>> = runCatching {
        verseCache[chapterNumber]?.let { return@runCatching it }
        val dtos = remote.fetchVerses(chapterNumber)
        val verses = dtos.map { dto ->
            Verse(
                chapterNumber   = dto.chapter_number,
                verseNumber     = dto.verse_number,
                text            = dto.text,
                transliteration = dto.transliteration ?: "",
                wordMeanings    = dto.word_meanings ?: "",
                translation     = dto.translation ?: "",
                commentary      = dto.commentary ?: ""
            )
        }
        verseCache[chapterNumber] = verses
        verses
    }

    override suspend fun getVerse(chapterNumber: Int, verseNumber: Int): Result<Verse> =
        runCatching {
            val verses = getVerses(chapterNumber).getOrThrow()
            verses.first { it.verseNumber == verseNumber }
        }

    override suspend fun searchVerses(query: String): Result<List<Verse>> = runCatching {
        if (verseCache.isEmpty()) (1..18).forEach { ch -> getVerses(ch) }
        val lower = query.lowercase()
        verseCache.values.flatten().filter { verse ->
            verse.text.lowercase().contains(lower) ||
            verse.translation.lowercase().contains(lower) ||
            verse.transliteration.lowercase().contains(lower)
        }
    }
}

class AiRepositoryImpl(
    private val remote: GitaRemoteDataSource
) : AiRepository {

    override suspend fun ask(query: String, sessionId: String?): Result<String> =
        runCatching { remote.askGemini(query) }

    override suspend fun textToSpeech(text: String): Result<ByteArray> =
        runCatching { remote.textToSpeech(text) }

    override suspend fun speechToText(audioBytes: ByteArray): Result<String> =
        runCatching {
            val b64 = encodeBase64(audioBytes)
            remote.speechToText(b64)
        }
}

expect fun encodeBase64(bytes: ByteArray): String
expect fun decodeBase64(base64: String): ByteArray
