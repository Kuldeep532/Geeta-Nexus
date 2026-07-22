package com.nexuswavetech.geetanexus.data

import platform.Foundation.*

actual fun encodeBase64(bytes: ByteArray): String {
    val data = bytes.toNSData()
    return data.base64EncodedStringWithOptions(0u)
}

actual fun decodeBase64(base64: String): ByteArray {
    val data = NSData.create(base64EncodedString = base64, options = 0u)
        ?: return ByteArray(0)
    return data.toByteArray()
}

private fun ByteArray.toNSData(): NSData =
    this.usePinned { pinned ->
        @OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
        NSData.create(bytes = pinned.addressOf(0), length = this.size.toULong())
    }

@OptIn(kotlinx.cinterop.ExperimentalForeignApi::class)
private fun NSData.toByteArray(): ByteArray {
    val ptr = bytes ?: return ByteArray(0)
    return ByteArray(length.toInt()) { idx ->
        kotlinx.cinterop.readBytes(ptr, length.toInt())[idx]
    }
}
