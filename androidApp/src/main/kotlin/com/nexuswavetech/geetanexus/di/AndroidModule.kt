package com.nexuswavetech.geetanexus.di

import com.nexuswavetech.geetanexus.data.LocalBookmarkRepository
import com.nexuswavetech.geetanexus.data.LocalUserRepository
import com.nexuswavetech.geetanexus.domain.repository.BookmarkRepository
import com.nexuswavetech.geetanexus.domain.repository.UserRepository
import com.nexuswavetech.geetanexus.network.CloudflareGatewayClient
import com.nexuswavetech.geetanexus.ui.viewmodel.AiChatViewModel
import com.nexuswavetech.geetanexus.ui.viewmodel.AudioViewModel
import com.nexuswavetech.geetanexus.ui.viewmodel.GitaViewModel
import com.nexuswavetech.geetanexus.ui.viewmodel.HomeViewModel
import org.koin.android.ext.koin.androidApplication
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.dsl.module

val androidModule = module {

    // ── Repositories ──────────────────────────────────────────────────────────
    single<BookmarkRepository> { LocalBookmarkRepository(androidContext()) }
    single<UserRepository>     { LocalUserRepository(androidContext()) }

    // Expose LocalUserRepository directly (for Credential Manager sign-in from Activity)
    single { get<UserRepository>() as LocalUserRepository }

    // ── ViewModels ────────────────────────────────────────────────────────────
    viewModel { HomeViewModel(get(), get()) }
    viewModel { GitaViewModel(get(), get()) }
    viewModel { AiChatViewModel(get<CloudflareGatewayClient>()) }
    viewModel { AudioViewModel(androidApplication(), get<CloudflareGatewayClient>()) }
}
