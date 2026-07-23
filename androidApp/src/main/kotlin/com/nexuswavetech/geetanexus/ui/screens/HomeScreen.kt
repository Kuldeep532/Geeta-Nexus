package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.domain.models.Verse
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import com.nexuswavetech.geetanexus.ui.viewmodel.HomeViewModel
import org.koin.androidx.compose.koinViewModel
import java.util.Calendar

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    navController: NavController,
    homeViewModel: HomeViewModel = koinViewModel()
) {
    val dailyVerse by homeViewModel.dailyVerse.collectAsState()
    val user       by homeViewModel.currentUser.collectAsState()

    val hour     = Calendar.getInstance().get(Calendar.HOUR_OF_DAY)
    val greeting = when {
        hour < 5  -> "Good Night"
        hour < 12 -> "Good Morning"
        hour < 17 -> "Good Afternoon"
        hour < 21 -> "Good Evening"
        else      -> "Good Night"
    }
    val userName = user?.displayName?.split(" ")?.firstOrNull() ?: "Seeker"

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(AppConfig.APP_NAME, fontWeight = FontWeight.Bold)
                        Text(AppConfig.COMPANY_NAME, style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                },
                actions = {
                    IconButton(onClick = { navController.navigate(Screen.Search.route) }) {
                        Icon(Icons.Default.Search, contentDescription = "Search")
                    }
                    IconButton(onClick = { navController.navigate(Screen.Profile.route) }) {
                        Icon(Icons.Default.AccountCircle, contentDescription = "Profile")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier            = Modifier.fillMaxSize().padding(padding),
            contentPadding      = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("$greeting, $userName 🙏",
                        style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.SemiBold)
                    Text("Begin your spiritual journey today",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }

            item { DailyVerseCard(verse = dailyVerse, onClick = {
                dailyVerse?.let {
                    navController.navigate(Screen.VerseReader.route(it.chapterNumber, it.verseNumber))
                }
            }) }

            item { Text("Explore", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold) }
            item { QuickActionsGrid(navController = navController) }

            item { Text("Sacred Texts", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold) }
            item { ScripturesTeaserRow(navController = navController) }

            item { Spacer(Modifier.height(8.dp)) }
        }
    }
}

@Composable
private fun DailyVerseCard(verse: Verse?, onClick: () -> Unit) {
    ElevatedCard(modifier = Modifier.fillMaxWidth(), shape = RoundedCornerShape(24.dp), onClick = onClick) {
        Box(modifier = Modifier
            .fillMaxWidth()
            .background(Brush.linearGradient(listOf(Color(0xFFFF8F00), Color(0xFFE65100))))
            .padding(20.dp)
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically) {
                    Text("🪷 Daily Verse", style = MaterialTheme.typography.labelLarge,
                        color = Color.White.copy(alpha = 0.9f), fontWeight = FontWeight.SemiBold)
                    verse?.let {
                        Surface(shape = RoundedCornerShape(8.dp), color = Color.White.copy(alpha = 0.2f)) {
                            Text("BG ${it.chapterNumber}.${it.verseNumber}",
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                                style = MaterialTheme.typography.labelSmall, color = Color.White)
                        }
                    }
                }

                if (verse != null) {
                    Text(verse.text.take(120) + if (verse.text.length > 120) "…" else "",
                        style = MaterialTheme.typography.bodyMedium, color = Color.White,
                        fontStyle = FontStyle.Italic, lineHeight = 22.sp)
                    HorizontalDivider(color = Color.White.copy(alpha = 0.3f))
                    Text(verse.translation.take(180) + if (verse.translation.length > 180) "…" else "",
                        style = MaterialTheme.typography.bodySmall, color = Color.White.copy(alpha = 0.9f),
                        lineHeight = 20.sp)
                } else {
                    LinearProgressIndicator(modifier = Modifier.fillMaxWidth(),
                        color = Color.White.copy(alpha = 0.7f), trackColor = Color.White.copy(alpha = 0.2f))
                }

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                    Text("Read full verse →", style = MaterialTheme.typography.labelMedium,
                        color = Color.White, fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

private data class QuickAction(val label: String, val emoji: String, val color: Color, val route: String)

@Composable
private fun QuickActionsGrid(navController: NavController) {
    val actions = listOf(
        QuickAction("Bhagavad Gita", "📖", Color(0xFF1565C0), Screen.Chapters.route),
        QuickAction("Ask Aira AI",   "🤖", Color(0xFF6A1B9A), Screen.AiChat.route),
        QuickAction("Bookmarks",     "🔖", Color(0xFF2E7D32), Screen.Bookmarks.route),
        QuickAction("All Scriptures","🔱", Color(0xFFBF360C), Screen.Scriptures.route),
    )
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
        actions.chunked(2).forEach { pair ->
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                pair.forEach { action ->
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .aspectRatio(1.5f)
                            .clip(RoundedCornerShape(16.dp))
                            .background(Brush.linearGradient(listOf(action.color, action.color.copy(alpha = 0.7f))))
                            .clickable { navController.navigate(action.route) }
                            .padding(12.dp)
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                            Text(action.emoji, fontSize = 24.sp)
                            Text(action.label, style = MaterialTheme.typography.labelLarge,
                                color = Color.White, fontWeight = FontWeight.SemiBold)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ScripturesTeaserRow(navController: NavController) {
    val items = listOf(
        Triple("🪷", "Bhagavad\nGita",   Screen.Chapters.route),
        Triple("🔱", "Shiva\nMahapurana", Screen.ScriptureDetail.route("SHIVA_MAHAPURANA")),
        Triple("🙏", "Ramcharit\nmanas", Screen.ScriptureDetail.route("RAMCHARITMANAS")),
    )
    Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
        items.forEach { (emoji, name, route) ->
            ElevatedCard(modifier = Modifier.weight(1f).clickable { navController.navigate(route) },
                shape = RoundedCornerShape(16.dp)) {
                Column(modifier = Modifier.padding(12.dp), horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text(emoji, fontSize = 28.sp)
                    Text(name, style = MaterialTheme.typography.labelSmall,
                        fontWeight = FontWeight.SemiBold, lineHeight = 14.sp)
                }
            }
        }
    }
}
