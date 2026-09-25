package com.nexuswavetech.geetanexus.data

import android.content.Context
import androidx.credentials.CredentialManager
import androidx.credentials.CustomCredential
import androidx.credentials.GetCredentialRequest
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.nexuswavetech.geetanexus.BuildConfig
import com.nexuswavetech.geetanexus.domain.models.UserProfile
import com.nexuswavetech.geetanexus.domain.repository.UserRepository
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.auth.Auth
import io.github.jan.supabase.auth.providers.Email
import io.github.jan.supabase.auth.providers.Google
import io.github.jan.supabase.auth.providers.IDToken
import io.github.jan.supabase.auth.user.UserInfo
import kotlinx.coroutines.flow.first
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.buildJsonObject
import kotlinx.serialization.json.put

private val Context.supabaseUserStore by preferencesDataStore(name = "supabase_user_prefs")

class SupabaseUserRepository(private val context: Context) : UserRepository {
    private val userJsonKey = stringPreferencesKey("user_profile_json")
    private val json = Json { ignoreUnknownKeys = true }

    private val supabase by lazy {
        createSupabaseClient(
            supabaseUrl = BuildConfig.SUPABASE_URL,
            supabaseKey = BuildConfig.SUPABASE_PUBLISHABLE_KEY
        ) {
            install(Auth) {
                autoLoadFromStorage = true
                alwaysAutoRefresh = true
            }
        }
    }

    private fun UserInfo.toProfile() = UserProfile(
        uid = id,
        displayName = userMetadata?.get("full_name")?.toString()?.trim('"')
            ?: userMetadata?.get("name")?.toString()?.trim('"')
            ?: email?.substringBefore("@").orEmpty().ifBlank { "Devotee" },
        email = email.orEmpty(),
        photoUrl = userMetadata?.get("avatar_url")?.toString()?.trim('"'),
        isAnonymous = isAnonymous
    )

    override suspend fun getCurrentUser(): UserProfile? {
        val user = supabase.auth.currentUserOrNull()
        if (user != null) return user.toProfile().also { persistUser(it) }
        return context.supabaseUserStore.data.first()[userJsonKey]
            ?.let { runCatching { json.decodeFromString<UserProfile>(it) }.getOrNull() }
    }

    suspend fun signInWithGoogle(activityContext: Context): Result<UserProfile> = runCatching {
        val credentialManager = CredentialManager.create(activityContext)
        val rawNonce = java.util.UUID.randomUUID().toString()
        val hashedNonce = java.security.MessageDigest.getInstance("SHA-256")
            .digest(rawNonce.toByteArray())
            .joinToString("") { "%02x".format(it) }

        val option = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(false)
            .setServerClientId(BuildConfig.GOOGLE_WEB_CLIENT_ID)
            .setNonce(hashedNonce)
            .setAutoSelectEnabled(false)
            .build()

        val result = credentialManager.getCredential(
            context = activityContext,
            request = GetCredentialRequest.Builder().addCredentialOption(option).build()
        )
        val credential = result.credential
        val token = (credential as? CustomCredential)
            ?.takeIf { it.type == GoogleIdTokenCredential.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL }
            ?.let { GoogleIdTokenCredential.createFrom(it.data).idToken }
            ?: error("Google sign-in was not completed")

        supabase.auth.loginWith(IDToken) {
            idToken = token
            provider = Google
            nonce = rawNonce
        }

        val user = supabase.auth.currentUserOrNull() ?: error("Supabase sign-in failed")
        user.toProfile().also { persistUser(it) }
    }

    override suspend fun signInWithGoogle(idToken: String): Result<UserProfile> = runCatching {
        supabase.auth.loginWith(IDToken) {
            this.idToken = idToken
            provider = Google
        }
        val user = supabase.auth.currentUserOrNull() ?: error("Supabase sign-in failed")
        user.toProfile().also { persistUser(it) }
    }

    override suspend fun signInWithEmailPassword(email: String, password: String): Result<UserProfile> = runCatching {
        supabase.auth.loginWith(Email) {
            this.email = email.trim()
            this.password = password
        }
        val user = supabase.auth.currentUserOrNull() ?: error("Sign-in failed")
        user.toProfile().also { persistUser(it) }
    }

    override suspend fun signUpWithEmailPassword(email: String, password: String, name: String): Result<UserProfile> = runCatching {
        supabase.auth.signUpWith(Email) {
            this.email = email.trim()
            this.password = password
            data = buildJsonObject { put("full_name", name.trim()) }
        }
        val user = supabase.auth.currentUserOrNull()
            ?: error("Account created. Please verify your email and sign in again.")
        user.toProfile().also { persistUser(it) }
    }

    override suspend fun signInAsGuest(): Result<UserProfile> = runCatching {
        supabase.auth.signInAnonymously()
        val user = supabase.auth.currentUserOrNull() ?: error("Guest sign-in failed")
        user.toProfile().also { persistUser(it) }
    }

    override suspend fun signOut() {
        supabase.auth.logout()
        context.supabaseUserStore.edit { it.remove(userJsonKey) }
    }

    override suspend fun updateProfile(profile: UserProfile): Result<Unit> = runCatching {
        supabase.auth.updateUser {
            data = buildJsonObject {
                put("full_name", profile.displayName)
                profile.photoUrl?.let { put("avatar_url", it) }
            }
        }
        persistUser(profile.copy(uid = supabase.auth.currentUserOrNull()?.id ?: profile.uid))
    }

    override suspend fun deleteAccount(): Result<Unit> =
        Result.failure(UnsupportedOperationException("Account deletion requires a secure server-side flow."))

    private suspend fun persistUser(profile: UserProfile) {
        context.supabaseUserStore.edit { it[userJsonKey] = json.encodeToString(profile) }
    }
}