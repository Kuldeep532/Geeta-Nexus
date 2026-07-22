package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.gestures.detectHorizontalDragGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.domain.models.Verse
import com.nexuswavetech.geetanexus.ui.viewmodel.GitaViewModel
import com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState
import org.koin.androidx.compose.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VerseReaderScreen(
    chapterNumber: Int,
    verseNumber: Int,
    navController: NavController,
    viewModel: GitaViewModel = koinViewModel()
) {
    val versesState   by viewModel.versesState.collectAsState()
    val bookmarkedIds by viewModel.bookmarkedIds.collectAsState()

    LaunchedEffect(chapterNumber) { viewModel.loadVerses(chapterNumber) }

    // Once loaded, jump to the requested verse
    LaunchedEffect(versesState, verseNumber) {
        val s = versesState
        if (s is VerseUiState.Success) {
            val idx = s.verses.indexOfFirst { it.verseNumber == verseNumber }
            if (idx >= 0) viewModel.goToVerse(idx)
        }
    }

    when (val s = versesState) {
        is VerseUiState.Loading -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        is VerseUiState.Error   -> ErrorState(s.message) { viewModel.loadVerses(chapterNumber) }
        is VerseUiState.Success -> {
            val verse = s.verses.getOrNull(s.currentIndex) ?: return
            val isBookmarked = bookmarkedIds.contains(verse.id)

            Scaffold(
                topBar = {
                    TopAppBar(
                        title = { Text(verse.displayNumber) },
                        navigationIcon = {
                            IconButton(
                                onClick = { navController.popBackStack() },
                                modifier = Modifier.semantics { contentDescription = "Go back" }
                            ) { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null) }
                        },
                        actions = {
                            IconButton(
                                onClick = { viewModel.toggleBookmark(verse) },
                                modifier = Modifier.semantics {
                                    contentDescription = if (isBookmarked) "Remove bookmark" else "Add bookmark"
                                }
                            ) {
                                Icon(
                                    if (isBookmarked) Icons.Default.Bookmark else Icons.Default.BookmarkBorder,
                                    contentDescription = null,
                                    tint = if (isBookmarked) MaterialTheme.colorScheme.primary
                                           else MaterialTheme.colorScheme.onSurface
                                )
                            }
                        }
                    )
                },
                bottomBar = {
                    VerseNavigationBar(
                        currentIndex = s.currentIndex,
                        total        = s.verses.size,
                        onPrevious   = { viewModel.goToVerse(s.currentIndex - 1) },
                        onNext       = { viewModel.goToVerse(s.currentIndex + 1) }
                    )
                }
            ) { padding ->
                AnimatedContent(
                    targetState = verse,
                    label       = "verse-transition",
                    transitionSpec = {
                        slideInHorizontally { it } + fadeIn() togetherWith
                        slideOutHorizontally { -it } + fadeOut()
                    }
                ) { currentVerse ->
                    VerseContent(
                        verse    = currentVerse,
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(padding)
                            .pointerInput(Unit) {
                                detectHorizontalDragGestures { _, dragAmount ->
                                    if (dragAmount < -50) viewModel.goToVerse(s.currentIndex + 1)
                                    else if (dragAmount > 50) viewModel.goToVerse(s.currentIndex - 1)
                                }
                            }
                    )
                }
            }
        }
    }
}

@Composable
private fun VerseContent(verse: Verse, modifier: Modifier = Modifier) {
    Column(
        modifier = modifier
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalArrangement = Arrangement.spacedBy(20.dp)
    ) {
        // Sanskrit
        VerseSection(
            heading = "Sanskrit",
            body    = verse.sanskrit,
            fontStyle = FontStyle.Italic
        )

        // Transliteration
        if (verse.transliteration.isNotBlank()) {
            VerseSection(heading = "Transliteration", body = verse.transliteration)
        }

        // Word meanings
        if (verse.wordMeanings.isNotBlank()) {
            VerseSection(heading = "Word by Word", body = verse.wordMeanings)
        }

        // Translation
        if (verse.translation.isNotBlank()) {
            HorizontalDivider()
            VerseSection(heading = "Translation", body = verse.translation)
        }

        // Commentary
        if (verse.commentary.isNotBlank()) {
            HorizontalDivider()
            VerseSection(heading = "Commentary", body = verse.commentary)
        }

        Spacer(Modifier.height(8.dp))
    }
}

@Composable
private fun VerseSection(heading: String, body: String, fontStyle: FontStyle = FontStyle.Normal) {
    Column(
        modifier            = Modifier.semantics(mergeDescendants = true) {},
        verticalArrangement = Arrangement.spacedBy(6.dp)
    ) {
        Text(
            text  = heading,
            style = MaterialTheme.typography.labelLarge,
            color = MaterialTheme.colorScheme.primary
        )
        Text(
            text      = body,
            style     = MaterialTheme.typography.bodyLarge,
            fontStyle = fontStyle
        )
    }
}

@Composable
private fun VerseNavigationBar(
    currentIndex: Int,
    total: Int,
    onPrevious: () -> Unit,
    onNext: () -> Unit
) {
    BottomAppBar {
        Row(
            modifier = Modifier.fillMaxWidth().padding(horizontal = 8.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment     = Alignment.CenterVertically
        ) {
            IconButton(
                onClick  = onPrevious,
                enabled  = currentIndex > 0,
                modifier = Modifier.semantics { contentDescription = "Previous verse" }
            ) { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null) }

            Text(
                text  = "${currentIndex + 1} / $total",
                style = MaterialTheme.typography.bodyMedium
            )

            IconButton(
                onClick  = onNext,
                enabled  = currentIndex < total - 1,
                modifier = Modifier.semantics { contentDescription = "Next verse" }
            ) { Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null) }
        }
    }
}
