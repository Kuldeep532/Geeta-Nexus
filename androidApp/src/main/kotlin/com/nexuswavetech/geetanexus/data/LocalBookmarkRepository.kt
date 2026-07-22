package com.nexuswavetech.geetanexus.data

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.nexuswavetech.geetanexus.domain.models.Verse
import com.nexuswavetech.geetanexus.domain.repository.BookmarkRepository
import kotlinx.coroutines.flow.first

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "bookmarks")

class LocalBookmarkRepository(private val context: Context) : BookmarkRepository {

    private val BOOKMARK_IDS_KEY = stringSetPreferencesKey("bookmark_ids")

    override suspend fun getBookmarks(): Result<List<Verse>> = runCatching {
        val ids = context.dataStore.data.first()[BOOKMARK_IDS_KEY] ?: emptySet()
        // Return stub Verse objects with only id fields; full data loaded from GitaRepository
        ids.mapNotNull { id ->
            val parts = id.split(".")
            val ch = parts.getOrNull(0)?.toIntOrNull() ?: return@mapNotNull null
            val vr = parts.getOrNull(1)?.toIntOrNull() ?: return@mapNotNull null
            Verse(chapterNumber = ch, verseNumber = vr, sanskrit = "")
        }
    }

    override suspend fun addBookmark(verseId: String): Result<Unit> = runCatching {
        context.dataStore.edit { prefs ->
            val current = prefs[BOOKMARK_IDS_KEY] ?: emptySet()
            prefs[BOOKMARK_IDS_KEY] = current + verseId
        }
    }

    override suspend fun removeBookmark(verseId: String): Result<Unit> = runCatching {
        context.dataStore.edit { prefs ->
            val current = prefs[BOOKMARK_IDS_KEY] ?: emptySet()
            prefs[BOOKMARK_IDS_KEY] = current - verseId
        }
    }

    override suspend fun isBookmarked(verseId: String): Boolean {
        val ids = context.dataStore.data.first()[BOOKMARK_IDS_KEY] ?: emptySet()
        return verseId in ids
    }
}
