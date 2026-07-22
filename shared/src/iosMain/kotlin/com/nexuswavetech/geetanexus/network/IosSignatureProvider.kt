package com.nexuswavetech.geetanexus.network

import com.nexuswavetech.geetanexus.AppConfig
import kotlinx.cinterop.*
import platform.CoreFoundation.*
import platform.Foundation.*
import platform.Security.*

/**
 * iOS/Darwin implementation of [SignatureProvider].
 *
 * Uses Apple's Security framework (SecKey) for Ed25519 signing.
 * The raw 32-byte private key seed is base64-decoded from
 * [AppConfig.ED25519_PRIVATE_KEY_BASE64].
 */
@OptIn(ExperimentalForeignApi::class)
actual class SignatureProvider actual constructor() {

    actual fun sign(message: String): String {
        val seedB64 = AppConfig.ED25519_PRIVATE_KEY_BASE64
        val seedData = NSData.create(base64EncodedString = seedB64, options = 0u)
            ?: error("Failed to base64-decode Ed25519 private key seed")

        val attributes = mapOf<Any?, Any?>(
            kSecAttrKeyType      to kSecAttrKeyTypeEdDSA,
            kSecAttrKeyClass     to kSecAttrKeyClassPrivate,
            kSecAttrKeySizeInBits to 256
        )

        var error: CFErrorRef? = null
        val privateKey = SecKeyCreateWithData(
            seedData as CFDataRef,
            attributes as CFDictionaryRef,
            error?.ptr
        ) ?: error("Failed to create SecKey for Ed25519: $error")

        val messageData = message.encodeToByteArray().toNSData()
        val signatureData = SecKeyCreateSignature(
            privateKey,
            kSecKeyAlgorithmEdDSASignatureMessageX962SHA512,
            messageData as CFDataRef,
            error?.ptr
        ) ?: error("Ed25519 signing failed: $error")

        val bytes = (signatureData as NSData).bytes
            ?: return ""
        val length = (signatureData as NSData).length.toInt()
        return (0 until length).joinToString("") {
            "%02x".format(bytes.reinterpret<ByteVar>()[it].toInt() and 0xFF)
        }
    }
}

private fun ByteArray.toNSData(): NSData =
    this.usePinned { pinned ->
        NSData.create(bytes = pinned.addressOf(0), length = this.size.toULong())
    }
