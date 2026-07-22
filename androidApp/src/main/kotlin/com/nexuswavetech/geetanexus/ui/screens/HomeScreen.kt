package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import com.nexuswavetech.geetanexus.ui.viewmodel.HomeViewModel
import org.koin.androidx.compose.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    navController: NavController,
    viewModel: HomeViewModel = koinViewModel()
) {
    val dailyVerse  by viewModel.dailyVerse.collectAsState()
    val currentUser by viewModel.currentUser.collectAsState()
    val isLoading   by viewModel.isLoading.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(
                        text  = "Gita Nexus",
                        style = MaterialTheme.typography.titleLarge
                    )
                },
                actions = {
                    IconButton(
                        onClick = { navController.navigate(Screen.Search.route) },
                        modifier = Modifier.semantics { contentDescription = "Search verses" }
                    ) { Icon(Icons.Default.Search, contentDescription = null) }

                    IconButton(
                        onClick = { navController.navigate(Screen.Profile.route) },
                        modifier = Modifier.semantics { contentDescription = "Open profile" }
                    ) { Icon(Icons.Default.AccountCircle, contentDescription = null) }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .padding(padding)
                .padding(horizontal = 16.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            Spacer(Modifier.height(4.dp))

            // ── Greeting ──────────────────────────────────────────────────
            currentUser?.let { user ->
                Text(
                    text  = "Namaste, ${user.displayName.split(" ").first()} 🙏",
                    style = MaterialTheme.typography.headlineMedium
                )
            } ?: Text(
                text  = "Namaste 🙏",
                style = MaterialTheme.typography.headlineMedium
            )

            // ── Daily Verse Card ──────────────────────────────────────────
            if (isLoading) {
                Card(modifier = Modifier.fillMaxWidth().height(180.dp)) {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator()
                    }
                }
            } else {
                dailyVerse?.let { verse ->
                    Card(
                        modifier = Modifier
                            .fillMaxWidth()
                            .semantics(mergeDescendants = true) {
                                contentDescription = "Daily verse: ${verse.displayNumber}"
                            }
                            .clickable {
                                navController.navigate(
                                    Screen.VerseReader.route(verse.chapterNumber, verse.verseNumber)
                                )
                            },
                        colors = CardDefaults.cardColors(
                            containerColor = MaterialTheme.colorScheme.primaryContainer
                        ),
                        shape = RoundedCornerShape(16.dp)
                    ) {
                        Column(
                            modifier = Modifier.padding(20.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Row(
                                horizontalArrangement = Arrangement.SpaceBetween,
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text(
                                    text  = "Daily Verse",
                                    style = MaterialTheme.typography.labelLarge,
                                    color = MaterialTheme.colorScheme.primary
                                )
                                Text(
                                    text  = verse.displayNumber,
                                    style = MaterialTheme.typography.labelLarge,
                                    color = MaterialTheme.colorScheme.primary
                                )
                            }
                            Text(
                                text      = verse.sanskrit,
                                style     = MaterialTheme.typography.bodyMedium,
                                fontStyle = FontStyle.Italic
                            )
                            if (verse.translation.isNotBlank()) {
                                HorizontalDivider(modifier = Modifier.padding(vertical = 2.dp))
                                Text(
                                    text  = verse.translation,
                                    style = MaterialTheme.typography.bodyMedium
                                )
                            }
                        }
                    }
                }
            }

            // ── Quick Access Grid ─────────────────────────────────────────
            Text(
                text  = "Explore",
                style = MaterialTheme.typography.titleMedium
            )

            val quickActions = listOf(
                QuickAction("Read Gita",    Icons.Default.MenuBook,       Screen.Chapters.route),
                QuickAction("Ask Aira AI",  Icons.Default.AutoAwesome,    Screen.AiChat.route),
                QuickAction("Bookmarks",    Icons.Default.Bookmark,       Screen.Bookmarks.route),
                QuickAction("More",         Icons.Default.GridView,       Screen.More.route),
            )

            val cols = 2
            quickActions.chunked(cols).forEach { row ->
                Row(
                    modifier            = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    row.forEach { action ->
                        QuickActionCard(
                            action    = action,
                            modifier  = Modifier.weight(1f),
                            onClick   = { navController.navigate(action.route) }
                        )
                    }
                    if (row.size < cols) Spacer(Modifier.weight(1f))
                }
            }

            Spacer(Modifier.height(16.dp))
        }
    }
}

private data class QuickAction(val label: String, val icon: ImageVector, val route: String)

@Composable
private fun QuickActionCard(
    action: QuickAction,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(
        onClick   = onClick,
        modifier  = modifier
            .height(100.dp)
            .semantics { contentDescription = action.label },
        shape     = RoundedCornerShape(12.dp)
    ) {
        Column(
            modifier              = Modifier.fillMaxSize().padding(16.dp),
            verticalArrangement   = Arrangement.Center,
            horizontalAlignment   = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector        = action.icon,
                contentDescription = null,
                tint               = MaterialTheme.colorScheme.primary,
                modifier           = Modifier.size(28.dp)
            )
            Spacer(Modifier.height(8.dp))
            Text(
                text      = action.label,
                style     = MaterialTheme.typography.labelLarge,
                textAlign = TextAlign.Center
            )
        }
    }
}
