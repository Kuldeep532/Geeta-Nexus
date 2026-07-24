package com.nexuswavetech.geetanexus.di

import com.nexuswavetech.geetanexus.data.*
import com.nexuswavetech.geetanexus.domain.repository.*
import com.nexuswavetech.geetanexus.ui.viewmodel.*
import org.koin.android.ext.koin.androidApplication
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module

/**
 * Android-specific Koin module.
 *
 * Wires:
 *  - Firebase repositories (Auth, Firestore Bookmarks, Notes, ReadingPlan)
 *  - All ViewModels
 *
 * Shared repositories (GitaRepository, AiRepository, QuizRepository, CloudflareGatewayClient)
 * are provided by [sharedModule] in shared/di/SharedModule.kt.
 */
val androidModule = module {

    // ── Repositories ─────────────────────────────────────────────────────────
    // Firebase-backed — require programmatic Firebase init (FirebaseManager)
    single<UserRepository>        { FirebaseUserRepository(androidContext()) }
    single<BookmarkRepository>    { FirestoreBookmarkRepository(androidContext()) }
    single<NotesRepository>       { FirestoreNotesRepository(androidContext()) }
    single<ReadingPlanRepository> { FirestoreReadingPlanRepository(androidContext()) }

    // Expose FirebaseUserRepository directly (used by AuthViewModel for Google sign-in)
    single { get<UserRepository>() as FirebaseUserRepository }

    // ── ViewModels ────────────────────────────────────────────────────────────
    // HomeViewModel: needs GitaRepository + UserRepository (both from sharedModule / androidModule)
    viewModel { HomeViewModel(get(), get()) }

    // GitaViewModel: needs GitaRepository + BookmarkRepository
    viewModel { GitaViewModel(get(), get()) }

    // AiChatViewModel: uses AiRepository (provided by sharedModule → AiRepositoryImpl → Gemini)
    // No API keys in the ViewModel — all keys fetched via CloudflareGatewayClient
    viewModel { AiChatViewModel(get<AiRepository>()) }

    // AudioViewModel: uses AiRepository for TTS (HuggingFace via Cloudflare)
    viewModel { AudioViewModel(androidApplication(), get<AiRepository>()) }

    // Feature ViewModels
    viewModel { QuizViewModel(get()) }
    viewModel { NotesViewModel(get()) }
    viewModel { ReadingPlanViewModel(get()) }

    // AuthViewModel: uses FirebaseUserRepository directly (for Credential Manager Google sign-in)
    viewModel { AuthViewModel(get()) }
}
