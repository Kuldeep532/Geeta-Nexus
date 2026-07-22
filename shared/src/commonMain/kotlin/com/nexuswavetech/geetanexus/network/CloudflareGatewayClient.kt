package com.nexuswavetech.geetanexus.network

import com.nexuswavetech.geetanexus.AppConfig
import io.ktor.client.*
import io.ktor.client.call.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.request.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import kotlin.random.Random

/**
 * Secure API key broker that routes through the Cloudflare Workers gateway.
 *
 * Every call:
 *   1. Builds a canonical message: "$apiName:$timestamp:$nonce"
 *   2. Signs it with the app's Ed25519 private key (anti-replay / app integrity)
 *   3. Sends required headers: X-API-Name, X-Timestamp, X-Nonce, X-Signature
 *   4. Returns the decrypted API key from the gateway response
 *
 * The gateway verifies the Ed25519 signature against the public key baked into
 * the Cloudflare Worker (MCowBQYDK2VwAyEAa4ZxuobCuaSe+...).  Tampered or
 * cloned apps whose private key differs will receive a 403.
 */
class CloudflareGatewayClient(
    private val signer: SignatureProvider = SignatureProvider()
) {
    private val json = Json {
        ignoreUnknownKeys = true
        isLenient = true
    }

    private val httpClient = HttpClient {
        install(ContentNegotiation) { json(json) }
        install(Logging) {
            logger = Logger.DEFAULT
            level  = LogLevel.HEADERS
        }
    }

    // ── In-memory key cache ──────────────────────────────────────────────────
    private val keyCache = mutableMapOf<String, CachedKey>()

    /**
     * Fetch (or return cached) API key for [apiName].
     *
     * @param apiName One of [AppConfig.ApiKeyName].*
     * @throws GatewayException if the gateway rejects the request
     */
    suspend fun getApiKey(apiName: String): String {
        keyCache[apiName]?.let { cached ->
            if (!cached.isExpired()) return cached.key
        }

        val timestamp = currentEpochSeconds().toString()
        val nonce     = generateNonce()
        val message   = "$apiName:$timestamp:$nonce"
        val signature = signer.sign(message)

        val response: GatewayResponse = httpClient.get(AppConfig.GATEWAY_BASE_URL) {
            headers {
                append("X-API-Name",   apiName)
                append("X-Timestamp",  timestamp)
                append("X-Nonce",      nonce)
                append("X-Signature",  signature)
            }
        }.body()

        if (response.status != "success" || response.apiKey == null) {
            throw GatewayException(
                response.messageEn ?: response.error ?: "Unknown gateway error"
            )
        }

        val key = response.apiKey
        // Cache for 55 minutes (gateway keys rarely rotate)
        keyCache[apiName] = CachedKey(key, currentEpochSeconds() + 3300)
        return key
    }

    // ── Utilities ────────────────────────────────────────────────────────────

    private fun generateNonce(): String =
        (1..16).map { Random.nextInt(0, 16).toString(16) }.joinToString("")

    private data class CachedKey(val key: String, val expiresAt: Long) {
        fun isExpired(): Boolean = currentEpochSeconds() >= expiresAt
    }

    fun close() = httpClient.close()
}

/** Thrown when the Cloudflare gateway returns a non-success status. */
class GatewayException(message: String) : Exception(message)

/** Platform-provided current Unix epoch in seconds. */
expect fun currentEpochSeconds(): Long
