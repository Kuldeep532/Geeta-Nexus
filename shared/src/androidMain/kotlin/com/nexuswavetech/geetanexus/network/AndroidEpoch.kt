package com.nexuswavetech.geetanexus.network

actual fun currentEpochSeconds(): Long = System.currentTimeMillis() / 1000L
