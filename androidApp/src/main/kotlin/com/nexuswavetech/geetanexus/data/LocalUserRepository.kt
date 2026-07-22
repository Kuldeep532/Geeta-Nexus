package com.nexuswavetech.geetanexus.data

import android.content.Context
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.domain.models.UserProfile
import com.nexuswavetech.geetanexus.domain.repository.UserRepository
import kotlinx.coroutines.flow.first
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

private val Context.userDataStore by preferencesDataStore(name = "user_prefs")

class LocalUserRepository(private val context: Context) : UserRepository {

    private val USER_JSON_KEY = stringPreferencesKey("user_profile_json")
    private val json = Json { ignoreUnknownKeys = true }

    override suspend fun getCurrentUser(): UserProfile? {
        val stored = context.userDataStore.data.first()[USER_JSON_KEY] ?: return null
        return runCatching { json.decodeFromString<UserProfile>(stored) }.getOrNull()
    }

    override suspend fun signInWithGoogle(idToken: String): Result<UserProfile> = runCatching {
        // Parse token claims (in production, verify server-side)
        val profile = UserProfile(
            uid         = idToken.hashCode().toString(),
            displayName = "Devotee",   // Replace with parsed name from ID token
            email       = ""           // Replace with parsed email from ID token
        )
        persistUser(profile)
        profile
    }

    /**
     * Launch Google Sign-In using Android Credential Manager.
     * Must be called from an Activity context.
     */
    suspend fun signInWithCredentialManager(activityContext: Context): Result<UserProfile> = runCatching {
        val credentialManager = CredentialManager.create(activityContext)

        val googleIdOption = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(false)
            .setServerClientId(AppConfig.GOOGLE_WEB_CLIENT_ID)
            .build()

        val request = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        val result       = credentialManager.getCredential(activityContext, request)
        val credential   = result.credential
        val googleIdCred = GoogleIdTokenCredential.createFrom(credential.data)

        val profile = UserProfile(
            uid         = googleIdCred.id,
            displayName = googleIdCred.displayName ?: "Devotee",
            email       = googleIdCred.id,
            photoUrl    = googleIdCred.profilePictureUri?.toString()
        )
        persistUser(profile)
        profile
    }

    override suspend fun signOut() {
        context.userDataStore.edit { it.remove(USER_JSON_KEY) }
    }

    override suspend fun updateProfile(profile: UserProfile): Result<Unit> = runCatching {
        persistUser(profile)
    }

    private suspend fun persistUser(profile: UserProfile) {
        context.userDataStore.edit { prefs ->
            prefs[USER_JSON_KEY] = json.encodeToString(profile)
        }
    }
}
