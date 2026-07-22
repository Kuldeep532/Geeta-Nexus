package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.domain.models.Chapter
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import com.nexuswavetech.geetanexus.ui.viewmodel.GitaUiState
import com.nexuswavetech.geetanexus.ui.viewmodel.GitaViewModel
import org.koin.androidx.compose.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChaptersScreen(
    navController: NavController,
    viewModel: GitaViewModel = koinViewModel()
) {
    val state by viewModel.chaptersState.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Bhagavad Gita") },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "Go back" }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentAlignment = Alignment.Center
        ) {
            when (val s = state) {
                is GitaUiState.Loading -> CircularProgressIndicator()
                is GitaUiState.Error   -> ErrorState(s.message) { viewModel.loadChapters() }
                is GitaUiState.Success -> ChaptersGrid(s.chapters) { chapter ->
                    navController.navigate(Screen.ChapterDetail.route(chapter.number))
                }
            }
        }
    }
}

@Composable
private fun ChaptersGrid(chapters: List<Chapter>, onClick: (Chapter) -> Unit) {
    LazyVerticalGrid(
        columns             = GridCells.Fixed(2),
        modifier            = Modifier.fillMaxSize(),
        contentPadding      = PaddingValues(12.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement   = Arrangement.spacedBy(12.dp)
    ) {
        items(chapters) { chapter ->
            ChapterCard(chapter = chapter, onClick = { onClick(chapter) })
        }
    }
}

@Composable
private fun ChapterCard(chapter: Chapter, onClick: () -> Unit) {
    Card(
        onClick   = onClick,
        modifier  = Modifier
            .fillMaxWidth()
            .semantics(mergeDescendants = true) {
                contentDescription =
                    "Chapter ${chapter.number}: ${chapter.name}, ${chapter.versesCount} verses"
            }
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Text(
                text  = "Chapter ${chapter.number}",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.primary
            )
            Text(
                text     = chapter.name,
                style    = MaterialTheme.typography.titleMedium,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text  = "${chapter.versesCount} verses",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun ChapterDetailScreen(
    chapterNumber: Int,
    navController: NavController,
    viewModel: GitaViewModel = koinViewModel()
) {
    val versesState by viewModel.versesState.collectAsState()
    val chaptersState by viewModel.chaptersState.collectAsState()

    LaunchedEffect(chapterNumber) { viewModel.loadVerses(chapterNumber) }

    val chapter = (chaptersState as? GitaUiState.Success)?.chapters
        ?.firstOrNull { it.number == chapterNumber }

    Scaffold(
        topBar = {
            TopAppBar(
                title  = { Text(chapter?.let { "Ch. $chapterNumber: ${it.name}" } ?: "Chapter $chapterNumber") },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentAlignment = Alignment.Center
        ) {
            when (val s = versesState) {
                is com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState.Loading ->
                    CircularProgressIndicator()
                is com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState.Error   ->
                    ErrorState(s.message) { viewModel.loadVerses(chapterNumber) }
                is com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState.Success -> {
                    androidx.compose.foundation.lazy.LazyColumn(
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        chapter?.summary?.takeIf { it.isNotBlank() }?.let { summary ->
                            item {
                                Card(
                                    modifier = Modifier.fillMaxWidth(),
                                    colors   = CardDefaults.cardColors(
                                        containerColor = MaterialTheme.colorScheme.primaryContainer
                                    )
                                ) {
                                    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                                        Text("Chapter Summary", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.primary)
                                        Text(summary, style = MaterialTheme.typography.bodyMedium)
                                    }
                                }
                            }
                        }

                        items(s.verses.size) { idx ->
                            val verse = s.verses[idx]
                            Card(
                                onClick  = {
                                    navController.navigate(Screen.VerseReader.route(chapterNumber, verse.verseNumber))
                                },
                                modifier = Modifier.fillMaxWidth().semantics {
                                    contentDescription = "Verse ${verse.verseNumber}"
                                }
                            ) {
                                Column(Modifier.padding(14.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Text("BG ${verse.chapterNumber}.${verse.verseNumber}", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.primary)
                                    Text(verse.sanskrit, style = MaterialTheme.typography.bodySmall, maxLines = 2, overflow = TextOverflow.Ellipsis)
                                    if (verse.translation.isNotBlank()) {
                                        Text(verse.translation, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant, maxLines = 2, overflow = TextOverflow.Ellipsis)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun ErrorState(message: String, onRetry: () -> Unit) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(12.dp),
        modifier            = Modifier.padding(32.dp)
    ) {
        Text(text = message, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.error)
        Button(onClick = onRetry) { Text("Retry") }
    }
}
