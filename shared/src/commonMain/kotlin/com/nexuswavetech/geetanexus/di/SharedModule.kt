package com.nexuswavetech.geetanexus.di

import com.nexuswavetech.geetanexus.data.AiRepositoryImpl
import com.nexuswavetech.geetanexus.data.GitaRepositoryImpl
import com.nexuswavetech.geetanexus.data.remote.GitaRemoteDataSource
import com.nexuswavetech.geetanexus.domain.repository.AiRepository
import com.nexuswavetech.geetanexus.domain.repository.GitaRepository
import com.nexuswavetech.geetanexus.network.CloudflareGatewayClient
import com.nexuswavetech.geetanexus.network.SignatureProvider
import org.koin.dsl.module

// Note: referenced as `sharedModule` (lowercase) from platform code
val sharedModule = module {
    single { SignatureProvider() }
    single { CloudflareGatewayClient(get()) }
    single { GitaRemoteDataSource(get()) }
    single<GitaRepository> { GitaRepositoryImpl(get()) }
    single<AiRepository>   { AiRepositoryImpl(get()) }
}
