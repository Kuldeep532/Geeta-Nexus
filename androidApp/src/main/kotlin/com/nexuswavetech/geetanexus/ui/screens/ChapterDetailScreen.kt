package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import com.nexuswavetech.geetanexus.ui.viewmodel.GitaUiState
import com.nexuswavetech.geetanexus.ui.viewmodel.GitaViewModel
import com.nexuswavetech.geetanexus.ui.viewmodel.VerseUiState
import org.koin.androidx.compose.koinViewModel

/**
 * Shows all verses of a specific Bhagavad Gita chapter.
 * Tapping a verse navigates to [VerseReaderScreen].
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ChapterDetailScreen(
    chapterNumber: Int,
    navController: NavController,
    viewModel: GitaViewModel = koinViewModel()
) {
    LaunchedEffect(chapterNumber) {
        viewModel.loadVerses(chapterNumber)
    }

    val versesState    by viewModel.versesState.collectAsState()
    val bookmarkedIds  by viewModel.bookmarkedIds.collectAsState()
    val chaptersState  by viewModel.chaptersState.collectAsState()

    // Derive chapter name from loaded chapters if available
    val chapterName = remember(chaptersState) {
        val s = chaptersState
        if (s is GitaUiState.Success)
            s.chapters.firstOrNull { it.number == chapterNumber }?.name ?: "Chapter $chapterNumber"
        else "Chapter $chapterNumber"
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Chapter $chapterNumber", fontWeight = FontWeight.Bold)
                        Text(chapterName,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1, overflow = TextOverflow.Ellipsis)
                    }
                },
                navigationIcon = {
                    IconButton(
                        onClick   = { navController.popBackStack() },
                        modifier  = Modifier.semantics { contentDescription = "Go back" }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
                    }
                }
            )
        }
    ) { padding ->
        Box(
            modifier         = Modifier.fillMaxSize().padding(padding),
            contentAlignment = Alignment.Center
        ) {
            when (val s = versesState) {
                is VerseUiState.Loading -> CircularProgressIndicator(
                    modifier = Modifier.semantics { contentDescription = "Loading verses" }
                )

                is VerseUiState.Error -> ErrorState(
                    message = s.message,
                    onRetry = { viewModel.loadVerses(chapterNumber) }
                )

                is VerseUiState.Success -> {
                    LazyColumn(
                        modifier       = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(horizontal = 16.dp, vertical = 12.dp),
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        item {
                            Text(
                                "${s.verses.size} Verses",
                                style = MaterialTheme.typography.labelMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.padding(bottom = 4.dp)
                            )
                        }

                        itemsIndexed(s.verses) { _, verse ->
                            val isBookmarked = verse.id in bookmarkedIds
                            Card(
                                onClick  = {
                                    navController.navigate(
                                        Screen.VerseReader.route(verse.chapterNumber, verse.verseNumber)
                                    )
                                },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .semantics {
                                        contentDescription =
                                            "Verse BG ${verse.chapterNumber}.${verse.verseNumber}" +
                                            if (isBookmarked) ", bookmarked" else ""
                                    }
                            ) {
                                Column(
                                    modifier = Modifier.padding(14.dp),
                                    verticalArrangement = Arrangement.spacedBy(6.dp)
                                ) {
                                    Row(
                                        modifier              = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment     = Alignment.CenterVertically
                                    ) {
                                        Surface(
                                            shape = CircleShape,
                                            color = MaterialTheme.colorScheme.primaryContainer
                                        ) {
                                            Text(
                                                "${verse.verseNumber}",
                                                modifier   = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                                                style      = MaterialTheme.typography.labelMedium,
                                                fontWeight = FontWeight.Bold,
                                                color      = MaterialTheme.colorScheme.primary
                                            )
                                        }
                                        if (isBookmarked) {
                                            Icon(
                                                imageVector        = Bookmark,
                                                contentDescription = "Bookmarked",
                                                tint               = MaterialTheme.colorScheme.primary,
                                                modifier           = Modifier.size(16.dp)
                                            )
                                        }
                                    }

                                    if (verse.text.isNotBlank()) {
                                        Text(
                                            verse.text.take(150) + if (verse.text.length > 150) "…" else "",
                                            style   = MaterialTheme.typography.bodySmall,
                                            maxLines = 2,
                                            overflow = TextOverflow.Ellipsis
                                        )
                                    }

                                    if (verse.translation.isNotBlank()) {
                                        Text(
                                            verse.translation.take(120) + if (verse.translation.length > 120) "…" else "",
                                            style   = MaterialTheme.typography.bodySmall,
                                            color   = MaterialTheme.colorScheme.onSurfaceVariant,
                                            maxLines = 2,
                                            overflow = TextOverflow.Ellipsis
                                        )
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
