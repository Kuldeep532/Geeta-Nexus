package com.nexuswavetech.geetanexus.data

import android.util.Base64 as AndroidBase64

actual fun encodeBase64(bytes: ByteArray): String =
    AndroidBase64.encodeToString(bytes, AndroidBase64.NO_WRAP)

actual fun decodeBase64(base64: String): ByteArray =
    AndroidBase64.decode(base64, AndroidBase64.DEFAULT)
