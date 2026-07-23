package com.nexuswavetech.geetanexus.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.nexuswavetech.geetanexus.domain.models.BookmarkEntry
import com.nexuswavetech.geetanexus.domain.models.ScriptureType
import com.nexuswavetech.geetanexus.domain.repository.BookmarkRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map

private val Context.bookmarkStore by preferencesDataStore(name = "bookmarks_local")

/**
 * Local DataStore-backed BookmarkRepository (offline fallback).
 * Used when user is not signed in or Firebase is unavailable.
 */
class LocalBookmarkRepository(private val context: Context) : BookmarkRepository {

    private val BOOKMARK_IDS_KEY = stringSetPreferencesKey("bookmark_ids")

    override fun getBookmarksFlow(): Flow<List<BookmarkEntry>> =
        context.bookmarkStore.data.map { prefs ->
            (prefs[BOOKMARK_IDS_KEY] ?: emptySet()).mapNotNull { id -> idToEntry(id) }
        }

    override suspend fun getBookmarks(): Result<List<BookmarkEntry>> = runCatching {
        val ids = context.bookmarkStore.data.first()[BOOKMARK_IDS_KEY] ?: emptySet()
        ids.mapNotNull { id -> idToEntry(id) }
    }

    override suspend fun addBookmark(entry: BookmarkEntry): Result<Unit> = runCatching {
        context.bookmarkStore.edit { prefs ->
            val current = prefs[BOOKMARK_IDS_KEY] ?: emptySet()
            prefs[BOOKMARK_IDS_KEY] = current + entry.verseId
        }
    }

    override suspend fun removeBookmark(verseId: String): Result<Unit> = runCatching {
        context.bookmarkStore.edit { prefs ->
            val current = prefs[BOOKMARK_IDS_KEY] ?: emptySet()
            prefs[BOOKMARK_IDS_KEY] = current - verseId
        }
    }

    override suspend fun isBookmarked(verseId: String): Boolean {
        val ids = context.bookmarkStore.data.first()[BOOKMARK_IDS_KEY] ?: emptySet()
        return verseId in ids
    }

    private fun idToEntry(verseId: String): BookmarkEntry? {
        val parts = verseId.split(".")
        val ch = parts.getOrNull(0)?.toIntOrNull() ?: return null
        val vr = parts.getOrNull(1)?.toIntOrNull() ?: return null
        return BookmarkEntry(
            verseId       = verseId,
            scripture     = ScriptureType.BHAGAVAD_GITA,
            title         = "BG $ch.$vr",
            preview       = "",
            chapterNumber = ch,
            verseNumber   = vr
        )
    }
}
