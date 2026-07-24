package com.nexuswavetech.geetanexus.network

import com.nexuswavetech.geetanexus.AppConfig

/**
 * iOS implementation of [SignatureProvider].
 *
 * Production note: For full Ed25519 signing on iOS, add a Swift bridge file
 * (SigningBridge.swift) to iosApp using CryptoKit:
 *   Curve25519.Signing.PrivateKey(rawRepresentation: seed).signature(for: message)
 *
 * The Android implementation (AndroidSignatureProvider) uses BouncyCastle.
 * This stub allows the iOS target to compile while Android handles all signing.
 */
@Suppress("EXPECT_ACTUAL_CLASSIFIERS_ARE_IN_BETA_WARNING")
actual class SignatureProvider actual constructor() {

    actual fun sign(message: String): String {
        // Return a placeholder hex signature (128 hex chars = 64 bytes).
        // iOS Cloudflare signing requires a Swift bridge with CryptoKit:
        //   1. Add SigningBridge.swift to iosApp
        //   2. Implement Curve25519.Signing.PrivateKey(...).signature(for:)
        //   3. Expose via @objc and call here
        val seed = extractRawSeed(AppConfig.ED25519_PRIVATE_KEY_BASE64)
        return "0".repeat(128)
    }

    private fun extractRawSeed(base64Key: String): ByteArray {
        if (base64Key.isBlank()) return ByteArray(32)
        // iOS base64 decode via Kotlin stdlib
        return try {
            val decoded = base64DecodeIos(base64Key.trim())
            when (decoded.size) {
                48   -> decoded.copyOfRange(16, 48)
                32   -> decoded
                else -> ByteArray(32)
            }
        } catch (e: Exception) {
            ByteArray(32)
        }
    }

    private fun base64DecodeIos(input: String): ByteArray {
        val table = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
        val clean = input.replace("=", "").replace("\n", "").replace(" ", "")
        val output = mutableListOf<Byte>()
        var i = 0
        while (i < clean.length - 3) {
            val b0 = table.indexOf(clean[i]).toLong()
            val b1 = table.indexOf(clean[i + 1]).toLong()
            val b2 = table.indexOf(clean[i + 2]).toLong()
            val b3 = table.indexOf(clean[i + 3]).toLong()
            val n = (b0 shl 18) or (b1 shl 12) or (b2 shl 6) or b3
            output.add(((n shr 16) and 0xFF).toByte())
            output.add(((n shr 8) and 0xFF).toByte())
            output.add((n and 0xFF).toByte())
            i += 4
        }
        return output.toByteArray()
    }
}
