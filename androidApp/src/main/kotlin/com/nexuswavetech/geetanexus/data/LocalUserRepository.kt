package com.nexuswavetech.geetanexus.data

import android.content.Context
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.nexuswavetech.geetanexus.domain.models.UserProfile
import com.nexuswavetech.geetanexus.domain.repository.UserRepository
import kotlinx.coroutines.flow.first
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

private val Context.localUserDataStore by preferencesDataStore(name = "user_prefs_local")

/**
 * Local DataStore-backed [UserRepository].
 *
 * This is the offline fallback for when Firebase is unavailable.
 * In production, [FirebaseUserRepository] is the primary implementation.
 *
 * NOTE: Google Sign-In and Email/Password auth require Firebase.
 * Only profile caching and guest mode work offline.
 */
@Deprecated("Use FirebaseUserRepository — this is an offline-only fallback.")
class LocalUserRepository(private val context: Context) : UserRepository {

    private val USER_JSON_KEY = stringPreferencesKey("user_profile_json")
    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun getCurrentUser(): UserProfile? {
        val stored = context.localUserDataStore.data.first()[USER_JSON_KEY] ?: return null
        return runCatching { json.decodeFromString<UserProfile>(stored) }.getOrNull()
    }

    override suspend fun signInWithGoogle(idToken: String): Result<UserProfile> =
        Result.failure(UnsupportedOperationException("Requires Firebase. Use FirebaseUserRepository."))

    override suspend fun signInWithEmailPassword(
        email: String, password: String
    ): Result<UserProfile> =
        Result.failure(UnsupportedOperationException("Requires Firebase. Use FirebaseUserRepository."))

    override suspend fun signUpWithEmailPassword(
        email: String, password: String, name: String
    ): Result<UserProfile> =
        Result.failure(UnsupportedOperationException("Requires Firebase. Use FirebaseUserRepository."))

    override suspend fun signInAsGuest(): Result<UserProfile> = runCatching {
        val profile = UserProfile(
            uid         = "guest_${System.currentTimeMillis()}",
            displayName = "Guest Seeker",
            email       = "",
            isAnonymous = true
        )
        persistUser(profile)
        profile
    }

    override suspend fun signOut() {
        context.localUserDataStore.edit { it.remove(USER_JSON_KEY) }
    }

    override suspend fun updateProfile(profile: UserProfile): Result<Unit> = runCatching {
        persistUser(profile)
    }

    override suspend fun deleteAccount(): Result<Unit> = runCatching {
        context.localUserDataStore.edit { it.remove(USER_JSON_KEY) }
    }

    private suspend fun persistUser(profile: UserProfile) {
        context.localUserDataStore.edit { prefs ->
            prefs[USER_JSON_KEY] = json.encodeToString(profile)
        }
    }
}
