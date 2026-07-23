package com.nexuswavetech.geetanexus.ui.viewmodel

import android.app.Application
import android.util.Log
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.media3.common.MediaItem
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.network.CloudflareGatewayClient
import io.ktor.client.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.request.*
import io.ktor.client.statement.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.serialization.json.Json

class AudioViewModel(
    application: Application,
    private val gatewayClient: CloudflareGatewayClient
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
    private val _isPlaying    = MutableStateFlow(false)
    private val _isBuffering  = MutableStateFlow(false)
    private val _isLoading    = MutableStateFlow(false)
    private val _error        = MutableStateFlow<String?>(null)
    private val _position     = MutableStateFlow(0L)
    private val _duration     = MutableStateFlow(0L)
    private val _currentId    = MutableStateFlow<String?>(null)
    private val _ttsMode      = MutableStateFlow(false) // true = TTS, false = streaming URL

    val isPlaying:   StateFlow<Boolean>  = _isPlaying.asStateFlow()
    val isBuffering: StateFlow<Boolean>  = _isBuffering.asStateFlow()
    val isLoading:   StateFlow<Boolean>  = _isLoading.asStateFlow()
    val error:       StateFlow<String?>  = _error.asStateFlow()
    val position:    StateFlow<Long>     = _position.asStateFlow()
    val duration:    StateFlow<Long>     = _duration.asStateFlow()
    val currentId:   StateFlow<String?>  = _currentId.asStateFlow()

    // Progress polling
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

    // ── HTTP client for TTS ───────────────────────────────────────────────────
    private val httpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) { json(Json { ignoreUnknownKeys = true }) }
    }

    // ── Public API ────────────────────────────────────────────────────────────

    /**
     * Play TTS audio for a verse. Calls FastAPI backend /tts, gets audio bytes,
     * saves to temp file, then feeds to ExoPlayer.
     */
    fun playVerseAudio(verseId: String, text: String) {
        if (_currentId.value == verseId && exoPlayer.isPlaying) {
            exoPlayer.pause(); return
        }
        viewModelScope.launch(Dispatchers.IO) {
            _isLoading.value = true
            _error.value = null
            _currentId.value = verseId
            try {
                // Try backend TTS first
                val ttsApiKey = runCatching { gatewayClient.getApiKey(AppConfig.ApiKeyName.HF_TTS) }.getOrNull()
                val backendUrl = "${AppConfig.BACKEND_BASE_URL}${AppConfig.BackendEndpoint.TTS}"
                val response: HttpResponse = httpClient.post(backendUrl) {
                    contentType(ContentType.Application.Json)
                    setBody("""{"text":"${text.replace("\"", "\\\"").take(500)}"}""")
                    if (ttsApiKey != null) header("X-API-Key", ttsApiKey)
                }
                if (response.status == HttpStatusCode.OK) {
                    val bytes = response.readBytes()
                    val tmpFile = java.io.File(getApplication<Application>().cacheDir, "tts_$verseId.mp3")
                    tmpFile.writeBytes(bytes)
                    val uri = androidx.core.net.toUri(tmpFile)
                    kotlinx.coroutines.withContext(Dispatchers.Main) {
                        exoPlayer.setMediaItem(MediaItem.fromUri(uri))
                        exoPlayer.prepare()
                        exoPlayer.play()
                    }
                } else {
                    _error.value = "TTS service unavailable (${response.status.value})"
                }
            } catch (e: Exception) {
                Log.e(tag, "TTS error", e)
                _error.value = "Audio unavailable: ${e.message}"
            } finally {
                _isLoading.value = false
            }
        }
    }

    /** Stream from a direct URL (e.g., pre-recorded chapter audio). */
    fun playUrl(url: String, trackId: String) {
        _currentId.value = trackId
        _error.value = null
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

    fun skipForward()  { exoPlayer.seekTo((exoPlayer.currentPosition + 10_000).coerceAtMost(exoPlayer.duration)) }
    fun skipBackward() { exoPlayer.seekTo((exoPlayer.currentPosition - 10_000).coerceAtLeast(0L)) }

    fun setPlaybackSpeed(speed: Float) { exoPlayer.setPlaybackSpeed(speed) }

    fun stop() {
        exoPlayer.stop()
        _isPlaying.value = false
        _currentId.value = null
        _position.value = 0L
    }

    override fun onCleared() {
        exoPlayer.release()
        httpClient.close()
        super.onCleared()
    }
}
