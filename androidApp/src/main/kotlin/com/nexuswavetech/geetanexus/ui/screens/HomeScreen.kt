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
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
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
                        Text(AppConfig.COMPANY_NAME,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                },
                actions = {
                    IconButton(
                        onClick = { navController.navigate(Screen.Search.route) },
                        modifier = Modifier.semantics { contentDescription = "Search verses" }
                    ) { Icon(Icons.Default.Search, contentDescription = null) }
                    IconButton(
                        onClick = { navController.navigate(Screen.Profile.route) },
                        modifier = Modifier.semantics { contentDescription = "My profile" }
                    ) { Icon(Icons.Default.AccountCircle, contentDescription = null) }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier            = Modifier.fillMaxSize().padding(padding),
            contentPadding      = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Greeting ──────────────────────────────────────────────────────
            item {
                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                    Text("$greeting, $userName 🙏",
                        style = MaterialTheme.typography.headlineSmall,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.semantics {
                            contentDescription = "$greeting $userName, welcome to Gita Nexus"
                        })
                    Text("आज की आध्यात्मिक यात्रा शुरू करें",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }

            // ── Daily Verse Card ──────────────────────────────────────────────
            item {
                DailyVerseCard(verse = dailyVerse, onClick = {
                    dailyVerse?.let {
                        navController.navigate(Screen.VerseReader.route(it.chapterNumber, it.verseNumber))
                    }
                })
            }

            // ── Quick Actions ─────────────────────────────────────────────────
            item {
                Text("त्वरित पहुँच",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold)
            }
            item { QuickActionsGrid(navController = navController) }

            // ── Features Row ──────────────────────────────────────────────────
            item {
                Text("विशेष सुविधाएँ",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold)
            }
            item { FeaturesRow(navController = navController) }

            // ── Sacred Texts ──────────────────────────────────────────────────
            item {
                Text("पवित्र ग्रंथ",
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold)
            }
            item { ScripturesTeaserRow(navController = navController) }

            item { Spacer(Modifier.height(8.dp)) }
        }
    }
}

// ── Daily Verse Card ──────────────────────────────────────────────────────────

@Composable
private fun DailyVerseCard(verse: Verse?, onClick: () -> Unit) {
    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .semantics { contentDescription = "Today's daily verse card. Tap to read." },
        shape    = RoundedCornerShape(24.dp),
        onClick  = onClick
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .background(Brush.linearGradient(listOf(Color(0xFFFF8F00), Color(0xFFE65100))))
                .padding(20.dp)
        ) {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Row(
                    modifier              = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment     = Alignment.CenterVertically
                ) {
                    Text("🪷 आज का श्लोक",
                        style = MaterialTheme.typography.labelLarge,
                        color = Color.White.copy(alpha = 0.9f),
                        fontWeight = FontWeight.SemiBold)
                    verse?.let {
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = Color.White.copy(alpha = 0.2f)
                        ) {
                            Text("BG ${it.chapterNumber}.${it.verseNumber}",
                                modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp),
                                style = MaterialTheme.typography.labelSmall,
                                color = Color.White)
                        }
                    }
                }

                if (verse != null) {
                    Text(
                        verse.text.take(100) + if (verse.text.length > 100) "…" else "",
                        style = MaterialTheme.typography.bodyMedium,
                        color = Color.White,
                        fontStyle = FontStyle.Italic,
                        lineHeight = 22.sp
                    )
                    HorizontalDivider(color = Color.White.copy(alpha = 0.3f))
                    Text(
                        verse.translation.take(160) + if (verse.translation.length > 160) "…" else "",
                        style = MaterialTheme.typography.bodySmall,
                        color = Color.White.copy(alpha = 0.9f),
                        lineHeight = 20.sp
                    )
                } else {
                    LinearProgressIndicator(
                        modifier   = Modifier.fillMaxWidth(),
                        color      = Color.White.copy(alpha = 0.7f),
                        trackColor = Color.White.copy(alpha = 0.2f)
                    )
                    Text("श्लोक लोड हो रहा है…",
                        color = Color.White.copy(alpha = 0.7f),
                        style = MaterialTheme.typography.bodySmall)
                }

                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                    Text("पूरा पढ़ें →",
                        style = MaterialTheme.typography.labelMedium,
                        color = Color.White,
                        fontWeight = FontWeight.SemiBold)
                }
            }
        }
    }
}

// ── Quick Actions Grid ────────────────────────────────────────────────────────

private data class QuickAction(
    val label: String,
    val emoji: String,
    val gradientStart: Color,
    val gradientEnd:   Color,
    val route: String,
    val description: String
)

@Composable
private fun QuickActionsGrid(navController: NavController) {
    val actions = listOf(
        QuickAction("Bhagavad\nGita", "📖", Color(0xFF1565C0), Color(0xFF0D47A1),
            Screen.Chapters.route,   "Open Bhagavad Gita chapters"),
        QuickAction("Aira AI\nChat",  "🤖", Color(0xFF6A1B9A), Color(0xFF4527A0),
            Screen.AiChat.route,     "Chat with Aira spiritual AI"),
        QuickAction("All\nScriptures","🔱", Color(0xFFBF360C), Color(0xFF7F0000),
            Screen.Scriptures.route, "Browse all sacred scriptures"),
        QuickAction("Saved\nVerses",  "🔖", Color(0xFF2E7D32), Color(0xFF1B5E20),
            Screen.Bookmarks.route,  "View bookmarked verses"),
    )

    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
        actions.chunked(2).forEach { pair ->
            Row(
                modifier              = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                pair.forEach { action ->
                    QuickActionCard(action = action, modifier = Modifier.weight(1f)) {
                        navController.navigate(action.route)
                    }
                }
                if (pair.size == 1) Spacer(modifier = Modifier.weight(1f))
            }
        }
    }
}

@Composable
private fun QuickActionCard(action: QuickAction, modifier: Modifier, onClick: () -> Unit) {
    Box(
        modifier = modifier
            .height(90.dp)
            .clip(RoundedCornerShape(18.dp))
            .background(Brush.linearGradient(listOf(action.gradientStart, action.gradientEnd)))
            .clickable(onClick = onClick)
            .semantics { contentDescription = action.description },
        contentAlignment = Alignment.Center
    ) {
        Column(
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(6.dp)
        ) {
            Text(action.emoji, fontSize = 26.sp)
            Text(
                action.label,
                style     = MaterialTheme.typography.labelSmall,
                color     = Color.White,
                fontWeight = FontWeight.SemiBold,
                textAlign  = androidx.compose.ui.text.style.TextAlign.Center
            )
        }
    }
}

// ── Features Row ─────────────────────────────────────────────────────────────

private data class FeatureItem(
    val label: String,
    val emoji: String,
    val color: Color,
    val route: String,
    val description: String
)

@Composable
private fun FeaturesRow(navController: NavController) {
    val features = listOf(
        FeatureItem("Quiz",         "🧠", Color(0xFFE65100), Screen.Quiz.route,        "Take a spiritual quiz"),
        FeatureItem("My Notes",     "📝", Color(0xFF00695C), Screen.Notes.route,       "View and write personal notes"),
        FeatureItem("Reading Plan", "📅", Color(0xFF283593), Screen.ReadingPlan.route, "Track your reading progress"),
    )

    Row(
        modifier              = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        features.forEach { feature ->
            ElevatedCard(
                onClick   = { navController.navigate(feature.route) },
                modifier  = Modifier
                    .weight(1f)
                    .semantics { contentDescription = feature.description },
                shape     = RoundedCornerShape(16.dp)
            ) {
                Column(
                    modifier            = Modifier.fillMaxWidth().padding(12.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(feature.emoji, fontSize = 24.sp)
                    Text(
                        feature.label,
                        style      = MaterialTheme.typography.labelSmall,
                        fontWeight = FontWeight.SemiBold,
                        color      = feature.color,
                        textAlign  = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            }
        }
    }
}

// ── Scripture Teaser Row ──────────────────────────────────────────────────────

@Composable
private fun ScripturesTeaserRow(navController: NavController) {
    val scriptures = listOf(
        Triple("🪷", "Bhagavad\nGita",     Screen.Chapters.route),
        Triple("🔱", "Shiva\nMahapurana", Screen.ScriptureDetail.route("SHIVA_MAHAPURANA")),
        Triple("🏹", "Ramcharit-\nmanas", Screen.ScriptureDetail.route("RAMCHARITMANAS")),
    )

    Row(
        modifier              = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.spacedBy(10.dp)
    ) {
        scriptures.forEach { (emoji, label, route) ->
            OutlinedCard(
                onClick   = { navController.navigate(route) },
                modifier  = Modifier
                    .weight(1f)
                    .semantics { contentDescription = "Open $label" },
                shape     = RoundedCornerShape(16.dp)
            ) {
                Column(
                    modifier            = Modifier.fillMaxWidth().padding(vertical = 14.dp, horizontal = 8.dp),
                    horizontalAlignment = Alignment.CenterHorizontally,
                    verticalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    Text(emoji, fontSize = 28.sp)
                    Text(
                        label,
                        style      = MaterialTheme.typography.labelSmall,
                        fontWeight = FontWeight.SemiBold,
                        textAlign  = androidx.compose.ui.text.style.TextAlign.Center
                    )
                }
            }
        }
    }
}
