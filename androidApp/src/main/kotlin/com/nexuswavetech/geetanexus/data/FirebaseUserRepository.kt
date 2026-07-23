package com.nexuswavetech.geetanexus.data

import android.content.Context
import android.util.Log
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.firebase.auth.EmailAuthProvider
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.BuildConfig
import com.nexuswavetech.geetanexus.domain.models.UserProfile
import com.nexuswavetech.geetanexus.domain.repository.UserRepository
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.tasks.await
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

private val Context.userDataStore by preferencesDataStore(name = "user_prefs_v2")

/**
 * Firebase-backed UserRepository.
 *
 * Auth methods (all via Credential Manager):
 *   - Google Sign-In (Credential Manager)
 *   - Email/Password
 *   - Anonymous / Guest
 *
 * User profile cached locally for offline support.
 */
class FirebaseUserRepository(private val context: Context) : UserRepository {

    private val tag = "FirebaseUserRepository"
    private val USER_JSON_KEY = stringPreferencesKey("firebase_user_json")
    private val json = Json { ignoreUnknownKeys = true }
    private val auth: FirebaseAuth get() = Firebase.auth

    override suspend fun getCurrentUser(): UserProfile? {
        val firebaseUser = auth.currentUser
        if (firebaseUser != null) {
            return firebaseUser.toProfile()
        }
        // Fallback to local cache
        val stored = context.userDataStore.data.first()[USER_JSON_KEY] ?: return null
        return runCatching { json.decodeFromString<UserProfile>(stored) }.getOrNull()
    }

    /** Google Sign-In via Credential Manager (modern, no deprecated APIs). */
    suspend fun signInWithGoogle(activityContext: Context): Result<UserProfile> = runCatching {
        val credentialManager = CredentialManager.create(activityContext)

        val googleIdOption = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(false)
            .setServerClientId(BuildConfig.GOOGLE_WEB_CLIENT_ID)
            .setAutoSelectEnabled(false)
            .build()

        val request = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        val result = credentialManager.getCredential(activityContext, request)
        val credential = result.credential

        val googleIdTokenCredential = when {
            credential is CustomCredential &&
            credential.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL ->
                GoogleIdTokenCredential.createFrom(credential.data)
            else -> throw IllegalStateException("Unexpected credential type: ${credential.type}")
        }

        val firebaseCredential = GoogleAuthProvider.getCredential(
            googleIdTokenCredential.idToken, null
        )
        val authResult = auth.signInWithCredential(firebaseCredential).await()
        val user = authResult.user ?: throw Exception("Authentication failed")
        val profile = user.toProfile()
        persistUser(profile)
        profile
    }

    override suspend fun signInWithGoogle(idToken: String): Result<UserProfile> = runCatching {
        val firebaseCredential = GoogleAuthProvider.getCredential(idToken, null)
        val authResult = auth.signInWithCredential(firebaseCredential).await()
        val user = authResult.user ?: throw Exception("Authentication failed")
        val profile = user.toProfile()
        persistUser(profile)
        profile
    }

    override suspend fun signInWithEmailPassword(
        email: String, password: String
    ): Result<UserProfile> = runCatching {
        val authResult = auth.signInWithEmailAndPassword(email, password).await()
        val user = authResult.user ?: throw Exception("Sign-in failed")
        val profile = user.toProfile()
        persistUser(profile)
        profile
    }

    override suspend fun signUpWithEmailPassword(
        email: String, password: String, name: String
    ): Result<UserProfile> = runCatching {
        val authResult = auth.createUserWithEmailAndPassword(email, password).await()
        val user = authResult.user ?: throw Exception("Sign-up failed")
        user.updateProfile(
            com.google.firebase.auth.userProfileChangeRequest { displayName = name }
        ).await()
        user.reload().await()
        val profile = auth.currentUser!!.toProfile().copy(displayName = name)
        persistUser(profile)
        profile
    }

    override suspend fun signInAsGuest(): Result<UserProfile> = runCatching {
        val authResult = auth.signInAnonymously().await()
        val user = authResult.user ?: throw Exception("Guest sign-in failed")
        val profile = user.toProfile()
        persistUser(profile)
        profile
    }

    override suspend fun signOut() {
        auth.signOut()
        context.userDataStore.edit { it.remove(USER_JSON_KEY) }
    }

    override suspend fun updateProfile(profile: UserProfile): Result<Unit> = runCatching {
        persistUser(profile)
    }

    override suspend fun deleteAccount(): Result<Unit> = runCatching {
        auth.currentUser?.delete()?.await()
        context.userDataStore.edit { it.remove(USER_JSON_KEY) }
    }

    private suspend fun persistUser(profile: UserProfile) {
        context.userDataStore.edit { prefs ->
            prefs[USER_JSON_KEY] = json.encodeToString(profile)
        }
    }

    private fun FirebaseUser.toProfile() = UserProfile(
        uid         = uid,
        displayName = displayName ?: "Devotee",
        email       = email ?: "",
        photoUrl    = photoUrl?.toString(),
        isAnonymous = isAnonymous
    )
}
