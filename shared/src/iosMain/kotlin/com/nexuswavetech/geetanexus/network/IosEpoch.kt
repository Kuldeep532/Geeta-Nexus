package com.nexuswavetech.geetanexus.network

import platform.Foundation.NSDate

actual fun currentEpochSeconds(): Long =
    NSDate().timeIntervalSince1970.toLong()
