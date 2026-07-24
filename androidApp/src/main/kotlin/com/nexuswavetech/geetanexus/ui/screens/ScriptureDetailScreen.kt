package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.domain.models.ScriptureSection
import com.nexuswavetech.geetanexus.domain.models.ScriptureType
import com.nexuswavetech.geetanexus.ui.navigation.Screen

/**
 * Shows sections (chapters/kandas/samhitas) for a specific scripture.
 * - SHIVA_MAHAPURANA → 7 Samhitas
 * - RAMCHARITMANAS → 7 Kandas
 * - BHAGAVAD_GITA → redirects to ChaptersScreen (not used directly)
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScriptureDetailScreen(
    scriptureType: String,
    navController: NavController
) {
    val type     = runCatching { ScriptureType.valueOf(scriptureType) }.getOrDefault(ScriptureType.SHIVA_MAHAPURANA)
    val sections = remember(scriptureType) { getSectionsFor(type) }

    val gradient = when (type) {
        ScriptureType.SHIVA_MAHAPURANA -> listOf(Color(0xFF6A1B9A), Color(0xFF4527A0))
        ScriptureType.RAMCHARITMANAS   -> listOf(Color(0xFF1565C0), Color(0xFF0D47A1))
        ScriptureType.BHAGAVAD_GITA    -> listOf(Color(0xFFFF8F00), Color(0xFFE65100))
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Text(type.displayName, fontWeight = FontWeight.Bold)
                },
                navigationIcon = {
                    IconButton(
                        onClick  = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "Go back" }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier       = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            // ── Header Banner ──────────────────────────────────────────────
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(20.dp))
                        .background(Brush.linearGradient(gradient))
                        .padding(20.dp)
                        .semantics { contentDescription = "${type.displayName} overview" }
                ) {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(type.emoji, fontSize = 40.sp)
                        Text(type.displayName,
                            style = MaterialTheme.typography.headlineSmall,
                            color = Color.White, fontWeight = FontWeight.Bold)
                        Text(
                            when (type) {
                                ScriptureType.SHIVA_MAHAPURANA ->
                                    "7 Samhitas • 24,000 Shlokas • The glory of Lord Shiva"
                                ScriptureType.RAMCHARITMANAS   ->
                                    "7 Kandas • 1,074 Chaupais • The story of Shri Ram"
                                ScriptureType.BHAGAVAD_GITA    ->
                                    "18 Chapters • 700 Verses • The song of the Lord"
                            },
                            style = MaterialTheme.typography.bodySmall,
                            color = Color.White.copy(alpha = 0.85f)
                        )
                    }
                }
            }

            item {
                Text(
                    when (type) {
                        ScriptureType.SHIVA_MAHAPURANA -> "7 Samhitas"
                        ScriptureType.RAMCHARITMANAS   -> "7 Kandas"
                        ScriptureType.BHAGAVAD_GITA    -> "Chapters"
                    },
                    style      = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold
                )
            }

            // ── Sections List ──────────────────────────────────────────────
            items(sections) { section ->
                SectionCard(
                    section    = section,
                    gradient   = gradient,
                    onClick    = {
                        navController.navigate(
                            Screen.ScriptureSectionDetail.route(scriptureType, section.id)
                        )
                    }
                )
            }
        }
    }
}

@Composable
private fun SectionCard(
    section:  ScriptureSection,
    gradient: List<Color>,
    onClick:  () -> Unit
) {
    Card(
        onClick   = onClick,
        modifier  = Modifier
            .fillMaxWidth()
            .semantics { contentDescription = "${section.title}: ${section.subtitle}" },
        shape     = RoundedCornerShape(16.dp)
    ) {
        Row(
            modifier          = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically,
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            // Number badge
            Box(
                modifier         = Modifier
                    .size(48.dp)
                    .clip(RoundedCornerShape(12.dp))
                    .background(Brush.linearGradient(gradient)),
                contentAlignment = Alignment.Center
            ) {
                Text("${section.number}",
                    style = MaterialTheme.typography.titleMedium,
                    color = Color.White, fontWeight = FontWeight.Bold)
            }

            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Text(section.title, style = MaterialTheme.typography.titleSmall,
                    fontWeight = FontWeight.SemiBold)
                Text(section.subtitle, style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.primary)
                Text(
                    section.description.take(100) + if (section.description.length > 100) "…" else "",
                    style   = MaterialTheme.typography.bodySmall,
                    color   = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 2, overflow = TextOverflow.Ellipsis
                )
                Text("${section.verseCount} verses",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}

// ── Static Section Data ───────────────────────────────────────────────────────

private fun getSectionsFor(type: ScriptureType): List<ScriptureSection> = when (type) {
    ScriptureType.SHIVA_MAHAPURANA -> shivaSamhitas
    ScriptureType.RAMCHARITMANAS   -> ramKandas
    ScriptureType.BHAGAVAD_GITA    -> emptyList()
}

// Internal so ScriptureSectionScreen can access without duplication
internal val shivaSamhitas = listOf(
    ScriptureSection(
        id = "shiva_1", scripture = ScriptureType.SHIVA_MAHAPURANA, number = 1,
        title = "Vidyeshwara Samhita", subtitle = "Knowledge of the Lord",
        description = "Opens with the greatness of the Shivalinga, the nature of Shiva as the Supreme Brahman, and the path of liberation. Covers cosmology, time cycles, and the philosophical basis of Shaivism.",
        verseCount = 10000
    ),
    ScriptureSection(
        id = "shiva_2", scripture = ScriptureType.SHIVA_MAHAPURANA, number = 2,
        title = "Rudra Samhita", subtitle = "The Story of Rudra",
        description = "The most extensive section — narrates Shiva's cosmic manifestations, His marriage to Parvati, the birth of Kartikeya and Ganesha, and the destruction of Tripura. Contains Parvati's tapasya.",
        verseCount = 8000
    ),
    ScriptureSection(
        id = "shiva_3", scripture = ScriptureType.SHIVA_MAHAPURANA, number = 3,
        title = "Shatrudra Samhita", subtitle = "Hundred Forms of Rudra",
        description = "Describes the hundred names and forms of Rudra, methods of worship, the greatness of Shiva devotees, and stories of liberation through Shiva's grace including tales of great saints.",
        verseCount = 5000
    ),
    ScriptureSection(
        id = "shiva_4", scripture = ScriptureType.SHIVA_MAHAPURANA, number = 4,
        title = "Kotirdura Samhita", subtitle = "Ten Million Rudras",
        description = "Narrates the stories of Shiva's countless forms as Rudra across all ages, the significance of the twelve Jyotirlingas (from Somnath to Ghrishneshwar), and methods of pilgrimage.",
        verseCount = 9000
    ),
    ScriptureSection(
        id = "shiva_5", scripture = ScriptureType.SHIVA_MAHAPURANA, number = 5,
        title = "Uma Samhita", subtitle = "The Story of Uma-Parvati",
        description = "Focuses on Goddess Parvati — her birth as Uma, her profound tapasya to win Shiva, the union of Shiva-Shakti, and the philosophical aspects of the Divine Mother as the primordial energy.",
        verseCount = 8000
    ),
    ScriptureSection(
        id = "shiva_6", scripture = ScriptureType.SHIVA_MAHAPURANA, number = 6,
        title = "Kailash Samhita", subtitle = "The Abode of Shiva",
        description = "Describes Mount Kailash as Shiva's cosmic abode, the divine assembly of gods and sages there, the nature of Shivaloka (Kailash realm), and the path of devotees who attain it.",
        verseCount = 6000
    ),
    ScriptureSection(
        id = "shiva_7", scripture = ScriptureType.SHIVA_MAHAPURANA, number = 7,
        title = "Vayaviya Samhita", subtitle = "The Words of Vayu",
        description = "Narrated by the Wind God Vayu — contains the most profound philosophical teachings including the Shaiva Siddhanta, metaphysics of liberation, and esoteric knowledge of consciousness.",
        verseCount = 4000
    )
)

internal val ramKandas = listOf(
    ScriptureSection(
        id = "ram_1", scripture = ScriptureType.RAMCHARITMANAS, number = 1,
        title = "Bal Kanda", subtitle = "The Book of Childhood",
        description = "Birth and early life of Shri Ram in Ayodhya, education under Vishwamitra, liberation of Ahalya, Ram's participation in Sita's Swayamvar and the breaking of Shiva's bow.",
        verseCount = 361
    ),
    ScriptureSection(
        id = "ram_2", scripture = ScriptureType.RAMCHARITMANAS, number = 2,
        title = "Ayodhya Kanda", subtitle = "The Book of Ayodhya",
        description = "Ram's planned coronation, Kaikeyi's boons, Ram's exile for 14 years with Sita and Lakshman, King Dasharatha's death of grief, and Bharat's meeting with Ram at Chitrakoot.",
        verseCount = 326
    ),
    ScriptureSection(
        id = "ram_3", scripture = ScriptureType.RAMCHARITMANAS, number = 3,
        title = "Aranya Kanda", subtitle = "The Book of the Forest",
        description = "Ram's life in the Dandaka forest, encounters with sages and demons, Surpanakha's disfigurement, the golden deer deception, Sita's abduction by Ravana, and Jatayu's heroic sacrifice.",
        verseCount = 46
    ),
    ScriptureSection(
        id = "ram_4", scripture = ScriptureType.RAMCHARITMANAS, number = 4,
        title = "Kishkindha Kanda", subtitle = "The Book of Kishkindha",
        description = "Ram meets Hanuman and Sugriva, slays Bali, and the search for Sita begins. Hanuman is identified as the ideal devotee — selfless, powerful, and surrendered to Ram.",
        verseCount = 30
    ),
    ScriptureSection(
        id = "ram_5", scripture = ScriptureType.RAMCHARITMANAS, number = 5,
        title = "Sundar Kanda", subtitle = "The Beautiful Book",
        description = "Hanuman's flight to Lanka, search for Sita in Ashok Vatika, meeting with Sita, burning of Lanka, and return. The most beloved kanda — a complete text of hope, devotion, and victory.",
        verseCount = 60
    ),
    ScriptureSection(
        id = "ram_6", scripture = ScriptureType.RAMCHARITMANAS, number = 6,
        title = "Lanka Kanda", subtitle = "The Book of Lanka",
        description = "The great war — construction of Ram Setu, battles with demon generals, Lakshman's revival by Sanjivani herb, and the final defeat and redemption of Ravana.",
        verseCount = 117
    ),
    ScriptureSection(
        id = "ram_7", scripture = ScriptureType.RAMCHARITMANAS, number = 7,
        title = "Uttar Kanda", subtitle = "The Final Book",
        description = "Ram's return to Ayodhya, the ideal Ram Rajya, philosophical dialogues between Kak Bhushundi and Garuda, and Shiva's explanation of Ram Katha's glory to Parvati.",
        verseCount = 130
    )
)
