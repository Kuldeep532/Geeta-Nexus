package com.nexuswavetech.geetanexus.network

import android.util.Base64
import com.nexuswavetech.geetanexus.AppConfig
import org.bouncycastle.crypto.params.Ed25519PrivateKeyParameters
import org.bouncycastle.crypto.signers.Ed25519Signer

/**
 * Android/JVM implementation of [SignatureProvider].
 *
 * Supports two key formats:
 *   1. PKCS8 DER (base64) — 48 bytes: header (16 bytes) + raw seed (32 bytes)
 *      e.g. keys starting with "MC4CAQAwBQYDK2Vw..."
 *   2. Raw seed (base64) — exactly 32 bytes
 *
 * Key material is injected at build time via BuildConfig from CI/CD secrets.
 * It is NEVER committed to source control.
 */
actual class SignatureProvider actual constructor() {

    actual fun sign(message: String): String {
        val seed = extractRawSeed(AppConfig.ED25519_PRIVATE_KEY_BASE64)
        require(seed.size == 32) {
            "Ed25519 key seed must be 32 bytes. Got ${seed.size}. " +
            "Check that ED25519_PRIVATE_KEY is set in CI/CD secrets."
        }

        val privateKey = Ed25519PrivateKeyParameters(seed, 0)
        val signer = Ed25519Signer().apply {
            init(true, privateKey)
            val bytes = message.toByteArray(Charsets.UTF_8)
            update(bytes, 0, bytes.size)
        }
        return signer.generateSignature().joinToString("") { "%02x".format(it) }
    }

    companion object {
        /**
         * Extracts the raw 32-byte Ed25519 seed from either:
         *   - PKCS8 DER (48 bytes): skip first 16 header bytes → last 32 bytes
         *   - Raw seed (32 bytes): use directly
         */
        fun extractRawSeed(base64Key: String): ByteArray {
            val decoded = Base64.decode(base64Key.trim(), Base64.DEFAULT)
            return when (decoded.size) {
                48   -> decoded.copyOfRange(16, 48)  // PKCS8: drop 16-byte header
                32   -> decoded                       // Raw seed
                else -> throw IllegalArgumentException(
                    "Unexpected Ed25519 key length: ${decoded.size}. " +
                    "Expected 48 (PKCS8) or 32 (raw seed)."
                )
            }
        }
    }
}
