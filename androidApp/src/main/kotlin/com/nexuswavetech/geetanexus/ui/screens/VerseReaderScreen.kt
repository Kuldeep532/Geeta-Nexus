package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.ui.viewmodel.AudioViewModel
import com.nexuswavetech.geetanexus.ui.viewmodel.GitaViewModel
import org.koin.androidx.compose.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VerseReaderScreen(
    chapterNumber: Int,
    verseNumber: Int,
    navController: NavController,
    audioViewModel: AudioViewModel,
    gitaViewModel: GitaViewModel = koinViewModel()
) {
    val verseState by gitaViewModel.currentVerseState.collectAsState()
    val isBookmarked by gitaViewModel.isCurrentVerseBookmarked.collectAsState()
    val isPlaying   by audioViewModel.isPlaying.collectAsState()
    val isLoading   by audioViewModel.isLoading.collectAsState()
    val currentAudioId by audioViewModel.currentId.collectAsState()
    val position    by audioViewModel.position.collectAsState()
    val duration    by audioViewModel.duration.collectAsState()

    var dragDelta by remember { mutableStateOf(0f) }
    var slideDirection by remember { mutableStateOf(1) }

    LaunchedEffect(chapterNumber, verseNumber) {
        gitaViewModel.loadVerse(chapterNumber, verseNumber)
    }

    val verse = (verseState as? com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState.Success)?.verse
    val verseId = verse?.id ?: "$chapterNumber.$verseNumber"
    val isThisAudioPlaying = currentAudioId == verseId && isPlaying

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text("Chapter $chapterNumber · Verse $verseNumber", fontWeight = FontWeight.SemiBold)
                },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                },
                actions = {
                    // Bookmark toggle
                    IconButton(onClick = { verse?.let { gitaViewModel.toggleBookmark(it) } }) {
                        Icon(
                            imageVector  = if (isBookmarked) Icons.Default.Bookmark else Icons.Default.BookmarkBorder,
                            contentDescription = "Bookmark",
                            tint = if (isBookmarked) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface
                        )
                    }
                    // Share
                    IconButton(onClick = { /* share intent */ }) {
                        Icon(Icons.Default.Share, contentDescription = "Share")
                    }
                }
            )
        },
        // Unified audio mini-player at bottom
        bottomBar = {
            if (verse != null) {
                Surface(shadowElevation = 8.dp) {
                    Column(modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)) {
                        // Progress bar (only when audio active for this verse)
                        if (currentAudioId == verseId && duration > 0) {
                            LinearProgressIndicator(
                                progress = { (position.toFloat() / duration).coerceIn(0f, 1f) },
                                modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp)
                            )
                        }
                        Row(
                            modifier              = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment     = Alignment.CenterVertically
                        ) {
                            // Navigation
                            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                IconButton(
                                    onClick = {
                                        if (verseNumber > 1)
                                            navController.navigate(
                                                com.nexuswavetech.geetanexus.ui.navigation.Screen.VerseReader.route(chapterNumber, verseNumber - 1)
                                            ) { popUpTo(navController.currentBackStackEntry?.destination?.route ?: "") { inclusive = true } }
                                    },
                                    enabled = verseNumber > 1
                                ) {
                                    Icon(Icons.Default.SkipPrevious, contentDescription = "Previous verse")
                                }
                                IconButton(
                                    onClick = {
                                        navController.navigate(
                                            com.nexuswavetech.geetanexus.ui.navigation.Screen.VerseReader.route(chapterNumber, verseNumber + 1)
                                        ) { popUpTo(navController.currentBackStackEntry?.destination?.route ?: "") { inclusive = true } }
                                    }
                                ) {
                                    Icon(Icons.Default.SkipNext, contentDescription = "Next verse")
                                }
                            }

                            // Audio controls
                            Row(
                                horizontalArrangement = Arrangement.spacedBy(4.dp),
                                verticalAlignment     = Alignment.CenterVertically
                            ) {
                                if (currentAudioId == verseId) {
                                    IconButton(onClick = { audioViewModel.skipBackward() }) {
                                        Icon(Icons.Default.Replay10, contentDescription = "-10s")
                                    }
                                }
                                FilledTonalIconButton(
                                    onClick = {
                                        val text = "${verse.text} ${verse.translation}"
                                        audioViewModel.playVerseAudio(verseId, text)
                                    }
                                ) {
                                    if (isLoading && currentAudioId == verseId) {
                                        CircularProgressIndicator(modifier = Modifier.size(20.dp), strokeWidth = 2.dp)
                                    } else {
                                        Icon(
                                            imageVector  = if (isThisAudioPlaying) Icons.Default.Pause else Icons.Default.RecordVoiceOver,
                                            contentDescription = "Play audio"
                                        )
                                    }
                                }
                                if (currentAudioId == verseId) {
                                    IconButton(onClick = { audioViewModel.skipForward() }) {
                                        Icon(Icons.Default.Forward10, contentDescription = "+10s")
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    ) { padding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .pointerInput(chapterNumber, verseNumber) {
                    detectHorizontalDragGestures(
                        onDragEnd = {
                            if (dragDelta < -80f && verseNumber > 1) {
                                slideDirection = -1
                                navController.navigate(
                                    com.nexuswavetech.geetanexus.ui.navigation.Screen.VerseReader.route(chapterNumber, verseNumber - 1)
                                ) { popUpTo(navController.currentBackStackEntry?.destination?.route ?: "") { inclusive = true } }
                            } else if (dragDelta > 80f) {
                                slideDirection = 1
                                navController.navigate(
                                    com.nexuswavetech.geetanexus.ui.navigation.Screen.VerseReader.route(chapterNumber, verseNumber + 1)
                                ) { popUpTo(navController.currentBackStackEntry?.destination?.route ?: "") { inclusive = true } }
                            }
                            dragDelta = 0f
                        },
                        onHorizontalDrag = { _, delta -> dragDelta += delta }
                    )
                }
        ) {
            when (val state = verseState) {
                is com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState.Loading -> {
                    CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                }
                is com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState.Error -> {
                    Column(modifier = Modifier.align(Alignment.Center), horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(state.message, style = MaterialTheme.typography.bodyLarge)
                        TextButton(onClick = { gitaViewModel.loadVerse(chapterNumber, verseNumber) }) { Text("Retry") }
                    }
                }
                is com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState.Success -> {
                    val v = state.verse
                    LazyColumn(
                        modifier       = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        // Sanskrit
                        item {
                            ElevatedCard(shape = RoundedCornerShape(20.dp)) {
                                Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                        Icon(Icons.Default.AutoStories, contentDescription = null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(20.dp))
                                        Text("Sanskrit", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.primary, fontWeight = FontWeight.SemiBold)
                                    }
                                    Text(v.text, style = MaterialTheme.typography.bodyLarge, fontStyle = FontStyle.Italic, lineHeight = MaterialTheme.typography.bodyLarge.lineHeight * 1.4f)
                                }
                            }
                        }

                        // Transliteration
                        if (v.transliteration.isNotBlank()) {
                            item {
                                Card(shape = RoundedCornerShape(16.dp)) {
                                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                        Text("Transliteration", style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.secondary, fontWeight = FontWeight.SemiBold)
                                        Text(v.transliteration, style = MaterialTheme.typography.bodyMedium, fontStyle = FontStyle.Italic)
                                    }
                                }
                            }
                        }

                        // Word meanings
                        if (v.wordMeanings.isNotBlank()) {
                            item {
                                Card(shape = RoundedCornerShape(16.dp)) {
                                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                        Text("Word Meanings", style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.secondary, fontWeight = FontWeight.SemiBold)
                                        Text(v.wordMeanings, style = MaterialTheme.typography.bodySmall)
                                    }
                                }
                            }
                        }

                        // Translation
                        item {
                            ElevatedCard(shape = RoundedCornerShape(16.dp)) {
                                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                    Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                        Icon(Icons.Default.Translate, contentDescription = null, tint = MaterialTheme.colorScheme.tertiary, modifier = Modifier.size(18.dp))
                                        Text("Translation", style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.tertiary, fontWeight = FontWeight.SemiBold)
                                    }
                                    Text(v.translation, style = MaterialTheme.typography.bodyMedium, lineHeight = MaterialTheme.typography.bodyMedium.lineHeight * 1.5f)
                                }
                            }
                        }

                        // Commentary
                        if (v.commentary.isNotBlank()) {
                            item {
                                Card(shape = RoundedCornerShape(16.dp),
                                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant)) {
                                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                        Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                                            Icon(Icons.Default.Lightbulb, contentDescription = null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(18.dp))
                                            Text("Commentary", style = MaterialTheme.typography.labelMedium, fontWeight = FontWeight.SemiBold)
                                        }
                                        Text(v.commentary, style = MaterialTheme.typography.bodyMedium,
                                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                                            lineHeight = MaterialTheme.typography.bodyMedium.lineHeight * 1.5f)
                                    }
                                }
                            }
                        }

                        item { Spacer(modifier = Modifier.height(8.dp)) }
                    }
                }
                else -> {}
            }
        }
    }
}
