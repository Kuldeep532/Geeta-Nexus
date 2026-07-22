package com.nexuswavetech.geetanexus.di

import org.koin.core.context.startKoin

/** Called from Swift [GeetaNexusApp.init] to bootstrap Koin on iOS. */
fun initKoin() {
    startKoin {
        modules(sharedModule)
    }
}
