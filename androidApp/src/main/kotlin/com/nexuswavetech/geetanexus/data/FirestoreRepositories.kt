package com.nexuswavetech.geetanexus.data

import android.content.Context
import android.util.Log
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.firebase.auth.ktx.auth
import com.google.firebase.firestore.ktx.firestore
import com.google.firebase.ktx.Firebase
import com.nexuswavetech.geetanexus.domain.models.*
import com.nexuswavetech.geetanexus.domain.repository.*
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.tasks.await
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

// ── Firestore path helpers ────────────────────────────────────────────────────

private val firestore get() = Firebase.firestore
private val currentUid get() = Firebase.auth.currentUser?.uid

private fun userDoc(uid: String)   = firestore.collection("users").document(uid)
private fun bookmarksCol(uid: String) = userDoc(uid).collection("bookmarks")
private fun notesCol(uid: String)     = userDoc(uid).collection("notes")
private fun plansCol(uid: String)     = userDoc(uid).collection("reading_plans")

// ── Offline DataStore backup ──────────────────────────────────────────────────

private val Context.offlineStore by preferencesDataStore(name = "offline_cache_v2")

// ── FirestoreBookmarkRepository ───────────────────────────────────────────────

class FirestoreBookmarkRepository(private val context: Context) : BookmarkRepository {
    private val tag = "BookmarkRepo"
    private val CACHE_KEY = stringPreferencesKey("bookmarks_json")
    private val json = Json { ignoreUnknownKeys = true }

    override fun getBookmarksFlow(): Flow<List<BookmarkEntry>> {
        val uid = currentUid ?: return flowOf(emptyList())
        return callbackFlow {
            val listener = bookmarksCol(uid)
                .addSnapshotListener { snap, err ->
                    if (err != null) { close(err); return@addSnapshotListener }
                    val entries = snap?.documents?.mapNotNull { doc ->
                        runCatching {
                            BookmarkEntry(
                                verseId       = doc.getString("verseId") ?: return@mapNotNull null,
                                scripture     = ScriptureType.valueOf(
                                    doc.getString("scripture") ?: "BHAGAVAD_GITA"),
                                title         = doc.getString("title") ?: "",
                                preview       = doc.getString("preview") ?: "",
                                chapterNumber = (doc.getLong("chapterNumber") ?: 1).toInt(),
                                verseNumber   = (doc.getLong("verseNumber") ?: 1).toInt(),
                                savedAt       = doc.getLong("savedAt") ?: 0L
                            )
                        }.getOrNull()
                    } ?: emptyList()
                    trySend(entries)
                }
            awaitClose { listener.remove() }
        }
    }

    override suspend fun getBookmarks(): Result<List<BookmarkEntry>> = runCatching {
        val uid = currentUid ?: return@runCatching emptyList()
        bookmarksCol(uid).get().await().documents.mapNotNull { doc ->
            runCatching {
                BookmarkEntry(
                    verseId       = doc.getString("verseId") ?: return@mapNotNull null,
                    scripture     = ScriptureType.valueOf(doc.getString("scripture") ?: "BHAGAVAD_GITA"),
                    title         = doc.getString("title") ?: "",
                    preview       = doc.getString("preview") ?: "",
                    chapterNumber = (doc.getLong("chapterNumber") ?: 1).toInt(),
                    verseNumber   = (doc.getLong("verseNumber") ?: 1).toInt(),
                    savedAt       = doc.getLong("savedAt") ?: 0L
                )
            }.getOrNull()
        }
    }

    override suspend fun addBookmark(entry: BookmarkEntry): Result<Unit> = runCatching {
        val uid = currentUid ?: throw IllegalStateException("Not signed in")
        val data = mapOf(
            "verseId"       to entry.verseId,
            "scripture"     to entry.scripture.name,
            "title"         to entry.title,
            "preview"       to entry.preview,
            "chapterNumber" to entry.chapterNumber,
            "verseNumber"   to entry.verseNumber,
            "savedAt"       to System.currentTimeMillis()
        )
        bookmarksCol(uid).document(entry.verseId.replace(".", "_")).set(data).await()
    }

    override suspend fun removeBookmark(verseId: String): Result<Unit> = runCatching {
        val uid = currentUid ?: throw IllegalStateException("Not signed in")
        bookmarksCol(uid).document(verseId.replace(".", "_")).delete().await()
    }

    override suspend fun isBookmarked(verseId: String): Boolean {
        val uid = currentUid ?: return false
        return runCatching {
            bookmarksCol(uid).document(verseId.replace(".", "_")).get().await().exists()
        }.getOrDefault(false)
    }
}

// ── FirestoreNotesRepository ──────────────────────────────────────────────────

class FirestoreNotesRepository(private val context: Context) : NotesRepository {
    private val json = Json { ignoreUnknownKeys = true }

    override fun getNotesFlow(): Flow<List<VerseNote>> {
        val uid = currentUid ?: return flowOf(emptyList())
        return callbackFlow {
            val listener = notesCol(uid)
                .orderBy("updatedAt", com.google.firebase.firestore.Query.Direction.DESCENDING)
                .addSnapshotListener { snap, err ->
                    if (err != null) { close(err); return@addSnapshotListener }
                    val notes = snap?.documents?.mapNotNull { doc -> docToNote(doc) } ?: emptyList()
                    trySend(notes)
                }
            awaitClose { listener.remove() }
        }
    }

    override suspend fun getNotes(): Result<List<VerseNote>> = runCatching {
        val uid = currentUid ?: return@runCatching emptyList()
        notesCol(uid).get().await().documents.mapNotNull { doc -> docToNote(doc) }
    }

    override suspend fun saveNote(note: VerseNote): Result<Unit> = runCatching {
        val uid = currentUid ?: throw IllegalStateException("Not signed in")
        val data = mapOf(
            "id"         to note.id,
            "verseId"    to note.verseId,
            "verseTitle" to note.verseTitle,
            "content"    to note.content,
            "mood"       to note.mood.name,
            "createdAt"  to note.createdAt,
            "updatedAt"  to System.currentTimeMillis()
        )
        notesCol(uid).document(note.id).set(data).await()
    }

    override suspend fun deleteNote(noteId: String): Result<Unit> = runCatching {
        val uid = currentUid ?: throw IllegalStateException("Not signed in")
        notesCol(uid).document(noteId).delete().await()
    }

    override suspend fun getNotesForVerse(verseId: String): Result<List<VerseNote>> = runCatching {
        val uid = currentUid ?: return@runCatching emptyList()
        notesCol(uid).whereEqualTo("verseId", verseId).get().await()
            .documents.mapNotNull { doc -> docToNote(doc) }
    }

    private fun docToNote(doc: com.google.firebase.firestore.DocumentSnapshot): VerseNote? =
        runCatching {
            VerseNote(
                id         = doc.getString("id") ?: doc.id,
                verseId    = doc.getString("verseId") ?: return@runCatching null,
                verseTitle = doc.getString("verseTitle") ?: "",
                content    = doc.getString("content") ?: "",
                mood       = Mood.valueOf(doc.getString("mood") ?: "CONTEMPLATIVE"),
                createdAt  = doc.getLong("createdAt") ?: 0L,
                updatedAt  = doc.getLong("updatedAt") ?: 0L
            )
        }.getOrNull()
}

// ── FirestoreReadingPlanRepository ────────────────────────────────────────────

class FirestoreReadingPlanRepository(private val context: Context) : ReadingPlanRepository {

    override fun getActivePlanFlow(): Flow<ReadingPlan?> {
        val uid = currentUid ?: return flowOf(null)
        return callbackFlow {
            val listener = plansCol(uid)
                .whereEqualTo("isActive", true)
                .limit(1)
                .addSnapshotListener { snap, err ->
                    if (err != null) { close(err); return@addSnapshotListener }
                    val plan = snap?.documents?.firstOrNull()?.let { docToPlan(it) }
                    trySend(plan)
                }
            awaitClose { listener.remove() }
        }
    }

    override suspend fun getActivePlan(): Result<ReadingPlan?> = runCatching {
        val uid = currentUid ?: return@runCatching null
        plansCol(uid).whereEqualTo("isActive", true).limit(1)
            .get().await().documents.firstOrNull()?.let { docToPlan(it) }
    }

    override suspend fun startPlan(plan: ReadingPlan): Result<Unit> = runCatching {
        val uid = currentUid ?: throw IllegalStateException("Not signed in")
        // Deactivate existing plans
        val existing = plansCol(uid).whereEqualTo("isActive", true).get().await()
        existing.documents.forEach { it.reference.update("isActive", false).await() }

        val data = mapOf(
            "id"            to plan.id,
            "title"         to plan.title,
            "description"   to plan.description,
            "scripture"     to plan.scripture,
            "totalDays"     to plan.totalDays,
            "completedDays" to 0,
            "currentChapter"to 1,
            "currentVerse"  to 1,
            "startedAt"     to System.currentTimeMillis(),
            "lastReadAt"    to System.currentTimeMillis(),
            "isActive"      to true
        )
        plansCol(uid).document(plan.id).set(data).await()
    }

    override suspend fun updateProgress(
        planId: String, completedDays: Int, chapter: Int, verse: Int
    ): Result<Unit> = runCatching {
        val uid = currentUid ?: throw IllegalStateException("Not signed in")
        plansCol(uid).document(planId).update(
            mapOf(
                "completedDays"  to completedDays,
                "currentChapter" to chapter,
                "currentVerse"   to verse,
                "lastReadAt"     to System.currentTimeMillis()
            )
        ).await()
    }

    override suspend fun completePlan(planId: String): Result<Unit> = runCatching {
        val uid = currentUid ?: throw IllegalStateException("Not signed in")
        plansCol(uid).document(planId).update(
            mapOf("isActive" to false, "completedDays" to Int.MAX_VALUE)
        ).await()
    }

    private fun docToPlan(doc: com.google.firebase.firestore.DocumentSnapshot): ReadingPlan? =
        runCatching {
            ReadingPlan(
                id             = doc.getString("id") ?: doc.id,
                title          = doc.getString("title") ?: "",
                description    = doc.getString("description") ?: "",
                scripture      = doc.getString("scripture") ?: "BHAGAVAD_GITA",
                totalDays      = (doc.getLong("totalDays") ?: 18).toInt(),
                completedDays  = (doc.getLong("completedDays") ?: 0).toInt(),
                currentChapter = (doc.getLong("currentChapter") ?: 1).toInt(),
                currentVerse   = (doc.getLong("currentVerse") ?: 1).toInt(),
                startedAt      = doc.getLong("startedAt") ?: 0L,
                lastReadAt     = doc.getLong("lastReadAt") ?: 0L
            )
        }.getOrNull()
}
