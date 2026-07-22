package com.nexuswavetech.geetanexus.network

/**
 * Platform-specific Ed25519 signer.
 *
 * Each platform implements this using its native crypto primitives:
 *   - Android/JVM: BouncyCastle [Ed25519Signer]
 *   - iOS/Darwin:  CryptoKit   [Curve25519.Signing]
 *
 * The message to sign is always: "$apiName:$timestamp:$nonce"
 * The returned string is the lower-case hex encoding of the 64-byte signature.
 */
expect class SignatureProvider() {
    /** Sign [message] with the Ed25519 private key and return hex-encoded bytes. */
    fun sign(message: String): String
}
