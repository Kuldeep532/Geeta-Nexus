package com.nexuswavetech.geetanexus

import android.app.Application
import com.nexuswavetech.geetanexus.di.androidModule
import com.nexuswavetech.geetanexus.di.sharedModule
import org.koin.android.ext.koin.androidContext
import org.koin.core.context.startKoin

class GeetaNexusApp : Application() {

    override fun onCreate() {
        super.onCreate()

        // Inject Ed25519 private key from BuildConfig into shared AppConfig
        AppConfig.ED25519_PRIVATE_KEY_BASE64 = BuildConfig.ED25519_PRIVATE_KEY

        startKoin {
            androidContext(this@GeetaNexusApp)
            modules(sharedModule, androidModule)
        }
    }
}
