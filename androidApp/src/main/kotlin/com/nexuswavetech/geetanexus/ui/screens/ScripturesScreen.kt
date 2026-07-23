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
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.domain.models.ScriptureType
import com.nexuswavetech.geetanexus.ui.navigation.Screen

private data class ScriptureCard(
    val type: ScriptureType,
    val verseCount: String,
    val gradient: List<Color>,
    val description: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScripturesScreen(navController: NavController) {
    val cards = listOf(
        ScriptureCard(
            type        = ScriptureType.BHAGAVAD_GITA,
            verseCount  = "18 Chapters • 700 Verses",
            gradient    = listOf(Color(0xFFFF8F00), Color(0xFFE65100)),
            description = "The eternal dialogue between Arjuna and Lord Krishna on the battlefield of Kurukshetra — a timeless guide to righteous living, selfless action, and bhakti."
        ),
        ScriptureCard(
            type        = ScriptureType.SHIVA_MAHAPURANA,
            verseCount  = "7 Samhitas • 24,000 Shlokas",
            gradient    = listOf(Color(0xFF6A1B9A), Color(0xFF4527A0)),
            description = "One of the eighteen Mahapuranas — the supreme glory of Lord Shiva, His divine sports, the Twelve Jyotirlingas, and the path to moksha through His grace."
        ),
        ScriptureCard(
            type        = ScriptureType.RAMCHARITMANAS,
            verseCount  = "7 Kandas • 1,074 Chaupais",
            gradient    = listOf(Color(0xFF1565C0), Color(0xFF0D47A1)),
            description = "Goswami Tulsidas's immortal Avadhi retelling of the Ramayana — the story of Shri Ram, an embodiment of dharma, compassion, and the ideal of a just king."
        )
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("Scriptures", fontWeight = FontWeight.Bold)
                        Text("Sacred Texts of Sanatan Dharma", style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
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
                Text(
                    "\"तमसो मा ज्योतिर्गमय\" — Lead me from darkness to light",
                    style    = MaterialTheme.typography.bodyMedium,
                    color    = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign= TextAlign.Center,
                    modifier = Modifier.fillMaxWidth().padding(bottom = 4.dp)
                )
            }

            cards.forEach { card ->
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(20.dp))
                            .background(Brush.linearGradient(card.gradient))
                            .clickable {
                                if (card.type == ScriptureType.BHAGAVAD_GITA)
                                    navController.navigate(Screen.Chapters.route)
                                else
                                    navController.navigate(Screen.ScriptureDetail.route(card.type.name))
                            }
                            .padding(24.dp)
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                            Row(verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                                Text(card.type.emoji, fontSize = 40.sp)
                                Column {
                                    Text(card.type.displayName, style = MaterialTheme.typography.headlineSmall,
                                        color = Color.White, fontWeight = FontWeight.Bold)
                                    Text(card.type.language, style = MaterialTheme.typography.labelMedium,
                                        color = Color.White.copy(alpha = 0.8f))
                                }
                            }
                            Text(card.description, style = MaterialTheme.typography.bodyMedium,
                                color = Color.White.copy(alpha = 0.9f), lineHeight = 22.sp)
                            Row(modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically) {
                                Text(card.verseCount, style = MaterialTheme.typography.labelMedium,
                                    color = Color.White.copy(alpha = 0.85f))
                                Row(verticalAlignment = Alignment.CenterVertically,
                                    horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Text("Read & Listen", color = Color.White,
                                        style = MaterialTheme.typography.labelLarge)
                                    Icon(Icons.Default.ArrowForward, contentDescription = null,
                                        tint = Color.White, modifier = Modifier.size(16.dp))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ── Scripture Detail (Shiva Purana / Ramcharitmanas) ──────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScriptureDetailScreen(scriptureType: String, navController: NavController) {
    val type     = runCatching { ScriptureType.valueOf(scriptureType) }.getOrDefault(ScriptureType.SHIVA_MAHAPURANA)
    val sections = com.nexuswavetech.geetanexus.data.ScriptureData.sectionsFor(type)

    val gradient = when (type) {
        ScriptureType.SHIVA_MAHAPURANA -> listOf(Color(0xFF6A1B9A), Color(0xFF4527A0))
        ScriptureType.RAMCHARITMANAS   -> listOf(Color(0xFF1565C0), Color(0xFF0D47A1))
        else                           -> listOf(Color(0xFFFF8F00), Color(0xFFE65100))
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(type.displayName, fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier            = Modifier.fillMaxSize().padding(padding),
            contentPadding      = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            item {
                Box(modifier = Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(20.dp))
                    .background(Brush.linearGradient(gradient))
                    .padding(24.dp),
                    contentAlignment = Alignment.Center) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally,
                        modifier = Modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(type.emoji, fontSize = 60.sp)
                        Text(type.displayName, style = MaterialTheme.typography.headlineMedium,
                            color = Color.White, fontWeight = FontWeight.Bold, textAlign = TextAlign.Center)
                        Text(type.language, style = MaterialTheme.typography.bodyMedium,
                            color = Color.White.copy(alpha = 0.8f))
                    }
                }
            }

            item {
                val sectionLabel = if (type == ScriptureType.SHIVA_MAHAPURANA) "Samhitas (Parts)" else "Kandas (Books)"
                Text(sectionLabel, style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold, modifier = Modifier.padding(top = 8.dp))
            }

            sections.forEach { section ->
                item {
                    Card(
                        modifier  = Modifier.fillMaxWidth().clickable {
                            navController.navigate(Screen.ScriptureSectionDetail.route(type.name, section.id))
                        },
                        shape     = RoundedCornerShape(16.dp),
                        elevation = CardDefaults.cardElevation(2.dp)
                    ) {
                        Row(modifier = Modifier.padding(16.dp),
                            horizontalArrangement = Arrangement.spacedBy(16.dp),
                            verticalAlignment = Alignment.CenterVertically) {
                            Surface(shape = RoundedCornerShape(12.dp),
                                color = MaterialTheme.colorScheme.primaryContainer,
                                modifier = Modifier.size(48.dp)) {
                                Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                                    Text("${section.number}", style = MaterialTheme.typography.titleMedium,
                                        fontWeight = FontWeight.Bold,
                                        color = MaterialTheme.colorScheme.onPrimaryContainer)
                                }
                            }
                            Column(modifier = Modifier.weight(1f)) {
                                Text(section.title, style = MaterialTheme.typography.titleSmall,
                                    fontWeight = FontWeight.SemiBold)
                                Text(section.subtitle, style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                                Text("~${section.verseCount} shlokas",
                                    style = MaterialTheme.typography.labelSmall,
                                    color = MaterialTheme.colorScheme.primary)
                            }
                            Icon(Icons.Default.PlayCircle, contentDescription = "Read",
                                tint = MaterialTheme.colorScheme.primary)
                        }
                    }
                }
            }
        }
    }
}

// ── Scripture Section Screen ───────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScriptureSectionScreen(
    scriptureType: String,
    sectionId: String,
    navController: NavController,
    audioViewModel: AudioViewModel
) {
    val type    = runCatching { ScriptureType.valueOf(scriptureType) }.getOrDefault(ScriptureType.SHIVA_MAHAPURANA)
    val section = com.nexuswavetech.geetanexus.data.ScriptureData.sectionsFor(type).find { it.id == sectionId }

    val isPlaying   by audioViewModel.isPlaying.collectAsState()
    val isLoading   by audioViewModel.isLoading.collectAsState()
    val currentId   by audioViewModel.currentId.collectAsState()
    val isThisPlay  = currentId == sectionId && isPlaying

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text(section?.title ?: "Section", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
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
            if (section == null) {
                item { Text("Section not found.", style = MaterialTheme.typography.bodyLarge) }
                return@LazyColumn
            }

            item {
                Card(shape = RoundedCornerShape(16.dp)) {
                    Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(section.subtitle, style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.SemiBold)
                        Text(section.description, style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant, lineHeight = 24.sp)
                        Text("~${section.verseCount} shlokas", style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.primary)
                    }
                }
            }

            // Unified audio player card
            item {
                ElevatedCard(shape = RoundedCornerShape(16.dp), modifier = Modifier.fillMaxWidth()) {
                    Column(modifier = Modifier.padding(20.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("🎧 Listen to ${section.title}",
                            style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.SemiBold)
                        Text("AI-powered TTS narration", style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                            FilledTonalButton(
                                onClick  = {
                                    audioViewModel.playVerseAudio(
                                        verseId = sectionId,
                                        text    = "${section.title}: ${section.description.take(300)}"
                                    )
                                },
                                modifier = Modifier.weight(1f)
                            ) {
                                if (isLoading && currentId == sectionId) {
                                    CircularProgressIndicator(modifier = Modifier.size(18.dp), strokeWidth = 2.dp)
                                } else {
                                    Icon(
                                        imageVector  = if (isThisPlay) Icons.Default.Pause else Icons.Default.PlayArrow,
                                        contentDescription = null, modifier = Modifier.size(20.dp)
                                    )
                                    Spacer(Modifier.width(8.dp))
                                    Text(if (isThisPlay) "Pause" else "Play")
                                }
                            }
                            if (isThisPlay) {
                                OutlinedButton(onClick = { audioViewModel.stop() }) {
                                    Icon(Icons.Default.Stop, contentDescription = "Stop")
                                }
                            }
                        }
                    }
                }
            }

            item {
                Card(shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.tertiaryContainer)) {
                    Row(modifier = Modifier.padding(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Default.Info, contentDescription = null,
                            tint = MaterialTheme.colorScheme.onTertiaryContainer)
                        Column {
                            Text("Full verse content coming soon", style = MaterialTheme.typography.titleSmall,
                                fontWeight = FontWeight.SemiBold,
                                color = MaterialTheme.colorScheme.onTertiaryContainer)
                            Text(
                                "Complete shloka-by-shloka reading with Sanskrit, transliteration, and commentary will be available in the next update.",
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onTertiaryContainer
                            )
                        }
                    }
                }
            }
        }
    }
}
