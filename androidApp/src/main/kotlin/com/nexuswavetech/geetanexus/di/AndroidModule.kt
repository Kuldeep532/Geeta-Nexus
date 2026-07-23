package com.nexuswavetech.geetanexus.di

import com.nexuswavetech.geetanexus.data.*
import com.nexuswavetech.geetanexus.domain.repository.*
import com.nexuswavetech.geetanexus.network.CloudflareGatewayClient
import com.nexuswavetech.geetanexus.ui.viewmodel.*
import org.koin.android.ext.koin.androidApplication
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module

val androidModule = module {

    // ── Repositories ──────────────────────────────────────────────────────────
    single<UserRepository>        { FirebaseUserRepository(androidContext()) }
    single<BookmarkRepository>    { FirestoreBookmarkRepository(androidContext()) }
    single<NotesRepository>       { FirestoreNotesRepository(androidContext()) }
    single<ReadingPlanRepository> { FirestoreReadingPlanRepository(androidContext()) }

    // Expose FirebaseUserRepository directly (for Credential Manager sign-in)
    single { get<UserRepository>() as FirebaseUserRepository }

    // ── ViewModels ────────────────────────────────────────────────────────────
    viewModel { HomeViewModel(get(), get()) }
    viewModel { GitaViewModel(get(), get()) }
    viewModel { AiChatViewModel(get<CloudflareGatewayClient>()) }
    viewModel { AudioViewModel(androidApplication(), get<CloudflareGatewayClient>()) }
    viewModel { QuizViewModel(get()) }
    viewModel { NotesViewModel(get()) }
    viewModel { ReadingPlanViewModel(get()) }
    viewModel { AuthViewModel(get()) }
}
