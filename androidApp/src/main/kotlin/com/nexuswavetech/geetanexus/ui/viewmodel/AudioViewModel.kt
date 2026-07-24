package com.nexuswavetech.geetanexus.ui.viewmodel

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import com.nexuswavetech.geetanexus.domain.repository.AiRepository
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File

/**
 * Manages audio playback for the app.
 *
 * TTS Flow (fully API-free on client):
 *   [AiRepository.textToSpeech] → [AiRepositoryImpl] → [GitaRemoteDataSource.textToSpeech]
 *       → Cloudflare Gateway (fetch HuggingFace key) → HuggingFace TTS API
 *
 * No API keys ever touch this ViewModel.
 */
class AudioViewModel(
    application: Application,
    private val aiRepository: AiRepository
) : AndroidViewModel(application) {

    private val tag = "AudioViewModel"

    // ── ExoPlayer ─────────────────────────────────────────────────────────────
    val exoPlayer: ExoPlayer = ExoPlayer.Builder(application).build().apply {
        addListener(object : Player.Listener {
            override fun onIsPlayingChanged(playing: Boolean) {
                _isPlaying.value = playing
            }
            override fun onPlaybackStateChanged(state: Int) {
                _isBuffering.value = (state == Player.STATE_BUFFERING)
                if (state == Player.STATE_ENDED) _isPlaying.value = false
            }
        })
    }

    // ── State ─────────────────────────────────────────────────────────────────
    private val _isPlaying   = MutableStateFlow(false)
    private val _isBuffering = MutableStateFlow(false)
    private val _isLoading   = MutableStateFlow(false)
    private val _error       = MutableStateFlow<String?>(null)
    private val _position    = MutableStateFlow(0L)
    private val _duration    = MutableStateFlow(0L)
    private val _currentId   = MutableStateFlow<String?>(null)

    val isPlaying:   StateFlow<Boolean>  = _isPlaying.asStateFlow()
    val isBuffering: StateFlow<Boolean>  = _isBuffering.asStateFlow()
    val isLoading:   StateFlow<Boolean>  = _isLoading.asStateFlow()
    val error:       StateFlow<String?>  = _error.asStateFlow()
    val position:    StateFlow<Long>     = _position.asStateFlow()
    val duration:    StateFlow<Long>     = _duration.asStateFlow()
    val currentId:   StateFlow<String?>  = _currentId.asStateFlow()

    init {
        viewModelScope.launch {
            while (isActive) {
                delay(500)
                if (exoPlayer.isPlaying) {
                    _position.value = exoPlayer.currentPosition
                    _duration.value = exoPlayer.duration.coerceAtLeast(0L)
                }
            }
        }
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /**
     * Generate TTS audio for [text] and play it via ExoPlayer.
     * Toggle pause/resume if the same [verseId] is already playing.
     */
    fun playVerseAudio(verseId: String, text: String) {
        if (_currentId.value == verseId && exoPlayer.isPlaying) {
            exoPlayer.pause()
            return
        }
        if (_currentId.value == verseId && !exoPlayer.isPlaying && exoPlayer.playbackState != Player.STATE_IDLE) {
            exoPlayer.play()
            return
        }

        viewModelScope.launch(Dispatchers.IO) {
            _isLoading.value = true
            _error.value     = null
            _currentId.value = verseId

            try {
                val result = aiRepository.textToSpeech(text.take(500))
                result.onSuccess { bytes ->
                    val cacheFile = File(
                        getApplication<Application>().cacheDir,
                        "tts_${verseId.replace(".", "_")}.mp3"
                    )
                    cacheFile.writeBytes(bytes)

                    withContext(Dispatchers.Main) {
                        exoPlayer.setMediaItem(MediaItem.fromUri(cacheFile.toURI().toString()))
                        exoPlayer.prepare()
                        exoPlayer.play()
                    }
                }.onFailure { e ->
                    Log.w(tag, "TTS failed: ${e.message}")
                    _error.value = "Audio unavailable — check internet connection."
                }
            } catch (e: Exception) {
                Log.e(tag, "TTS error", e)
                _error.value = "Could not load audio: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    /** Stream from a direct URL (pre-recorded audio). */
    fun playUrl(url: String, trackId: String) {
        _currentId.value = trackId
        _error.value     = null
        exoPlayer.setMediaItem(MediaItem.fromUri(url))
        exoPlayer.prepare()
        exoPlayer.play()
    }

    fun pauseResume() {
        if (exoPlayer.isPlaying) exoPlayer.pause() else exoPlayer.play()
    }

    fun seekTo(positionMs: Long) {
        exoPlayer.seekTo(positionMs)
        _position.value = positionMs
    }

    fun skipForward(ms: Long = 10_000L) {
        exoPlayer.seekTo((exoPlayer.currentPosition + ms).coerceAtMost(exoPlayer.duration))
    }
    fun skipBackward(ms: Long = 10_000L) {
        exoPlayer.seekTo((exoPlayer.currentPosition - ms).coerceAtLeast(0L))
    }

    fun setPlaybackSpeed(speed: Float) { exoPlayer.setPlaybackSpeed(speed) }

    fun dismissError() { _error.value = null }

    fun stop() {
        exoPlayer.stop()
        _isPlaying.value = false
        _currentId.value = null
        _position.value  = 0L
    }

    override fun onCleared() {
        exoPlayer.release()
        super.onCleared()
    }
}
