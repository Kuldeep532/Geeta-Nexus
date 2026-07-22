package com.nexuswavetech.geetanexus.network

import android.util.Base64
import com.nexuswavetech.geetanexus.AppConfig
import org.bouncycastle.crypto.params.Ed25519PrivateKeyParameters
import org.bouncycastle.crypto.signers.Ed25519Signer

/**
 * Android/JVM implementation of [SignatureProvider].
 *
 * Uses BouncyCastle's [Ed25519Signer] to produce the hex-encoded signature
 * required by the Cloudflare Worker gateway.
 *
 * Key material: [AppConfig.ED25519_PRIVATE_KEY_BASE64] must be set to the
 * raw 32-byte Ed25519 private key seed, base64-encoded. On Android this is
 * injected via BuildConfig (see androidApp/build.gradle.kts).
 */
actual class SignatureProvider actual constructor() {

    actual fun sign(message: String): String {
        val seed = Base64.decode(AppConfig.ED25519_PRIVATE_KEY_BASE64, Base64.DEFAULT)
        require(seed.size == 32) {
            "Ed25519 private key seed must be 32 bytes. Got ${seed.size}. " +
            "Check AppConfig.ED25519_PRIVATE_KEY_BASE64."
        }

        val privateKey = Ed25519PrivateKeyParameters(seed, 0)
        val signer = Ed25519Signer().apply {
            init(true, privateKey)
            val bytes = message.toByteArray(Charsets.UTF_8)
            update(bytes, 0, bytes.size)
        }
        return signer.generateSignature().joinToString("") { "%02x".format(it) }
    }
}
