package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
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
import com.nexuswavetech.geetanexus.domain.models.ScriptureSection
import com.nexuswavetech.geetanexus.domain.models.ScriptureType
import com.nexuswavetech.geetanexus.ui.viewmodel.AudioViewModel

/**
 * Displays content for a specific scripture section (samhita/kanda).
 *
 * Shows:
 *  - Section overview with gradient header
 *  - Full description
 *  - Key themes and highlights
 *  - Audio playback button (via TTS)
 *  - Representative verses/dohas (static curated content)
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ScriptureSectionScreen(
    scriptureType:  String,
    sectionId:      String,
    navController:  NavController,
    audioViewModel: AudioViewModel
) {
    val type    = runCatching { ScriptureType.valueOf(scriptureType) }.getOrDefault(ScriptureType.SHIVA_MAHAPURANA)
    val section = remember(sectionId) { findSection(type, sectionId) }
    val highlights = remember(sectionId) { getHighlights(sectionId) }

    val isLoading by audioViewModel.isLoading.collectAsState()
    val isPlaying by audioViewModel.isPlaying.collectAsState()
    val currentId by audioViewModel.currentId.collectAsState()
    val error     by audioViewModel.error.collectAsState()

    val isThisPlaying = currentId == sectionId && isPlaying

    val gradient = when (type) {
        ScriptureType.SHIVA_MAHAPURANA -> listOf(Color(0xFF6A1B9A), Color(0xFF4527A0))
        ScriptureType.RAMCHARITMANAS   -> listOf(Color(0xFF1565C0), Color(0xFF0D47A1))
        ScriptureType.BHAGAVAD_GITA    -> listOf(Color(0xFFFF8F00), Color(0xFFE65100))
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text(section?.title ?: "Section", fontWeight = FontWeight.Bold, maxLines = 1)
                        Text(section?.subtitle ?: type.displayName,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                },
                navigationIcon = {
                    IconButton(
                        onClick  = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "Go back" }
                    ) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null)
                    }
                },
                actions = {
                    // Audio TTS button
                    IconButton(
                        onClick = {
                            val descText = section?.description ?: "Loading content"
                            audioViewModel.playVerseAudio(sectionId, descText)
                        },
                        modifier = Modifier.semantics {
                            contentDescription = if (isThisPlaying) "Pause narration" else "Play audio narration"
                        }
                    ) {
                        if (isLoading && currentId == sectionId) {
                            CircularProgressIndicator(modifier = Modifier.size(22.dp), strokeWidth = 2.dp)
                        } else {
                            Icon(
                                imageVector = if (isThisPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                                contentDescription = null
                            )
                        }
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier       = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // ── Error banner ──────────────────────────────────────────────
            if (error != null) {
                item {
                    Card(colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.errorContainer)) {
                        Row(
                            modifier = Modifier.fillMaxWidth().padding(12.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(error!!, style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onErrorContainer,
                                modifier = Modifier.weight(1f))
                            TextButton(onClick = { audioViewModel.dismissError() }) {
                                Text("Dismiss")
                            }
                        }
                    }
                }
            }

            // ── Header ────────────────────────────────────────────────────
            section?.let { sec ->
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(24.dp))
                            .background(Brush.linearGradient(gradient))
                            .padding(24.dp)
                            .semantics { contentDescription = "${sec.title}: ${sec.subtitle}" }
                    ) {
                        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                            Row(
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment     = Alignment.Top,
                                modifier              = Modifier.fillMaxWidth()
                            ) {
                                Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                                    Text(type.emoji, fontSize = 36.sp)
                                    Text(sec.title, style = MaterialTheme.typography.headlineSmall,
                                        color = Color.White, fontWeight = FontWeight.Bold)
                                    Text(sec.subtitle, style = MaterialTheme.typography.bodyMedium,
                                        color = Color.White.copy(alpha = 0.85f))
                                }
                                Surface(
                                    shape = RoundedCornerShape(10.dp),
                                    color = Color.White.copy(alpha = 0.15f)
                                ) {
                                    Text("${sec.verseCount}\nverses",
                                        modifier = Modifier.padding(10.dp),
                                        style = MaterialTheme.typography.labelSmall,
                                        color = Color.White,
                                        textAlign = androidx.compose.ui.text.style.TextAlign.Center)
                                }
                            }

                            HorizontalDivider(color = Color.White.copy(alpha = 0.25f))

                            Text(sec.description, style = MaterialTheme.typography.bodyMedium,
                                color = Color.White.copy(alpha = 0.9f), lineHeight = 22.sp)
                        }
                    }
                }
            }

            // ── Key Highlights ────────────────────────────────────────────
            if (highlights.isNotEmpty()) {
                item {
                    Text("मुख्य विषय", style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold)
                }
                item {
                    ElevatedCard(shape = RoundedCornerShape(16.dp)) {
                        Column(
                            modifier = Modifier.padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            highlights.forEach { highlight ->
                                Row(
                                    horizontalArrangement = Arrangement.spacedBy(10.dp),
                                    verticalAlignment     = Alignment.Top
                                ) {
                                    Text("🪷", fontSize = 16.sp)
                                    Text(highlight,
                                        style = MaterialTheme.typography.bodyMedium,
                                        modifier = Modifier.weight(1f))
                                }
                            }
                        }
                    }
                }
            }

            // ── Representative Verse/Doha ─────────────────────────────────
            val verse = getRepresentativeVerse(sectionId)
            if (verse != null) {
                item {
                    Text("प्रमुख श्लोक / दोहा", style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold)
                }
                item {
                    ElevatedCard(shape = RoundedCornerShape(16.dp)) {
                        Column(
                            modifier = Modifier.padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            Text(verse.original, style = MaterialTheme.typography.bodyLarge,
                                fontStyle = FontStyle.Italic,
                                color = MaterialTheme.colorScheme.primary, lineHeight = 26.sp)
                            HorizontalDivider()
                            Text(verse.translation, style = MaterialTheme.typography.bodyMedium,
                                lineHeight = 22.sp)
                            Text(verse.reference, style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant)
                        }
                    }
                }
            }

            // ── Study Note ────────────────────────────────────────────────
            item {
                Card(
                    shape  = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(
                        containerColor = MaterialTheme.colorScheme.secondaryContainer)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth().padding(16.dp),
                        horizontalArrangement = Arrangement.spacedBy(12.dp),
                        verticalAlignment     = Alignment.CenterVertically
                    ) {
                        Icon(Icons.Default.Info, contentDescription = null,
                            tint = MaterialTheme.colorScheme.secondary)
                        Text(
                            "इस अध्याय को पूरी एकाग्रता के साथ पढ़ें। " +
                            "Tap the play button above to listen to an overview narration.",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSecondaryContainer,
                            modifier = Modifier.weight(1f)
                        )
                    }
                }
            }
        }
    }
}

// ── Data helpers ──────────────────────────────────────────────────────────────

private data class RepresentativeVerse(
    val original:    String,
    val translation: String,
    val reference:   String
)

private fun findSection(type: ScriptureType, sectionId: String): ScriptureSection? {
    val all = when (type) {
        ScriptureType.SHIVA_MAHAPURANA -> shivaSamhitas
        ScriptureType.RAMCHARITMANAS   -> ramKandas
        ScriptureType.BHAGAVAD_GITA    -> emptyList()
    }
    return all.firstOrNull { it.id == sectionId }
}

private fun getHighlights(sectionId: String): List<String> = when (sectionId) {
    "shiva_1" -> listOf(
        "Shivalinga की महिमा और उसके पूजन की विधि",
        "ब्रह्म, विष्णु और शिव की परस्पर श्रेष्ठता का प्रश्न",
        "काल-चक्र और सृष्टि का क्रम",
        "मोक्ष प्राप्ति के चार मार्ग"
    )
    "shiva_2" -> listOf(
        "शिव-पार्वती विवाह की अलौकिक कथा",
        "सती के दाह और पार्वती का जन्म",
        "कामदेव का दहन और पुनर्जन्म",
        "कार्तिकेय और गणेश का जन्म"
    )
    "shiva_3" -> listOf(
        "रुद्र के सौ नाम और उनके अर्थ",
        "शिव भक्तों की मुक्ति की कथाएँ",
        "Shiva Puja की विधि और महत्त्व",
        "पंचाक्षर मंत्र 'ॐ नमः शिवाय' की शक्ति"
    )
    "shiva_4" -> listOf(
        "द्वादश ज्योतिर्लिंगों की स्थापना की कथाएँ",
        "सोमनाथ से घृष्णेश्वर तक की यात्रा",
        "तीर्थ-यात्रा का धर्म और महत्त्व",
        "शिव-कृपा से पापमुक्ति के उदाहरण"
    )
    "shiva_5" -> listOf(
        "उमा-पार्वती की कठोर तपस्या",
        "शिव-शक्ति का दार्शनिक तत्त्व",
        "प्रकृति और पुरुष का संगम",
        "स्त्री-शक्ति की आराधना की परंपरा"
    )
    "shiva_6" -> listOf(
        "कैलाश — शिव का दिव्य धाम",
        "देवताओं और ऋषियों की शिव-सभा",
        "शिवलोक की प्राप्ति का मार्ग",
        "मृत्यु के बाद की आत्मा की यात्रा"
    )
    "shiva_7" -> listOf(
        "शैव सिद्धांत — Shaiva Philosophy",
        "पाश, पशु और पति का त्रिकोण",
        "चेतना की प्रकृति और परमशिव",
        "वायु-पुराण का अंतिम दर्शन"
    )
    "ram_1" -> listOf(
        "बालराम की लीलाएँ और गुरुकुल शिक्षा",
        "ताड़का, सुबाहु और मारीच का वध",
        "अहिल्या का उद्धार — पाप-मुक्ति का प्रतीक",
        "सीता-स्वयंवर और शिव-धनुष भंग"
    )
    "ram_2" -> listOf(
        "कैकेयी के वरदान और राम का वनवास",
        "लक्ष्मण-उर्मिला का त्याग",
        "दशरथ की प्रेम-मृत्यु",
        "भरत की राम-भक्ति और खड़ाऊँ-राज्य"
    )
    "ram_3" -> listOf(
        "अगस्त्य मुनि से दिव्यास्त्र प्राप्ति",
        "सूर्पणखा प्रसंग और रावण की प्रेरणा",
        "मारीच का सुवर्ण-मृग रूप",
        "जटायु का बलिदान — वृद्ध वीरता का प्रतीक"
    )
    "ram_4" -> listOf(
        "हनुमान-राम की पहली भेंट",
        "सुग्रीव से मैत्री और बाली-वध",
        "हनुमान की भक्ति — दास्य भाव का चरमोत्कर्ष",
        "सीता की खोज का महाअभियान"
    )
    "ram_5" -> listOf(
        "हनुमान की लंका-छलाँग — 100 योजन समुद्र पार",
        "अशोक वाटिका में सीता से भेंट",
        "रावण-सभा में निर्भीक उपस्थिति",
        "लंका-दहन — शक्ति और भक्ति का संगम"
    )
    "ram_6" -> listOf(
        "राम सेतु का निर्माण — श्रद्धा की शक्ति",
        "मेघनाद और कुंभकर्ण का वध",
        "लक्ष्मण मूर्छा और संजीवनी",
        "रावण-वध — अहंकार का अंत"
    )
    "ram_7" -> listOf(
        "राम-राज्य — आदर्श शासन का स्वरूप",
        "काक भुशुण्डि और गरुड़ का संवाद",
        "राम-कथा की महिमा और नाम-जप",
        "शिव-पार्वती संवाद में राम-तत्त्व"
    )
    else -> emptyList()
}

private fun getRepresentativeVerse(sectionId: String): RepresentativeVerse? = when (sectionId) {
    "shiva_1" ->
        RepresentativeVerse("ॐ नमः शिवाय", "I bow to Lord Shiva — the auspicious one.", "Panchakshara Mantra")
    "shiva_2" ->
        RepresentativeVerse(
            "नमामि शमीशान निर्वाण रूपं।\nविभुं व्यापकं ब्रह्म वेद स्वरूपं।",
            "I salute that Lord of all, the embodiment of liberation, all-pervading, the very form of Brahma and the Vedas.",
            "Shiva Tandava Stotram"
        )
    "shiva_3" ->
        RepresentativeVerse("त्र्यम्बकं यजामहे सुगन्धिं पुष्टिवर्धनम्।",
            "We worship Tryambaka (Shiva, the three-eyed one), the all-fragrant, the sustainer of life.",
            "Maha Mrityunjaya Mantra, RV 7.59.12")
    "shiva_4" ->
        RepresentativeVerse("द्वादशैतानि नामानि प्रातरुत्थाय यः पठेत्।",
            "One who recites these twelve names of the Jyotirlingas upon waking shall be freed from all sins.",
            "Dwadasha Jyotirlinga Stotram")
    "shiva_5" ->
        RepresentativeVerse(
            "या देवी सर्वभूतेषु शक्तिरूपेण संस्थिता।\nनमस्तस्यै नमस्तस्यै नमस्तस्यै नमो नमः।",
            "To the Goddess who is present in all beings as energy — salutations, salutations, salutations!",
            "Devi Mahatmyam"
        )
    "ram_1" ->
        RepresentativeVerse(
            "रामं स्कन्धमनुप्राप्तं वयसा सोडशे स्थितम्।",
            "Ram, having reached adolescence at sixteen years, was the very image of virtue and splendour.",
            "Ramcharitmanas, Bal Kanda"
        )
    "ram_2" ->
        RepresentativeVerse(
            "रामं दशरथानन्दं वसिष्ठप्रियनन्दनम्।\nकौसल्या आनन्दकरं रामं सत्यपराक्रमम्।।",
            "Salutations to Ram — the joy of Dasharatha, the beloved of Vasistha, the delight of Kaushalya, the one of true valor.",
            "Ramcharitmanas, Ayodhya Kanda"
        )
    "ram_5" ->
        RepresentativeVerse(
            "मंगल भवन अमंगल हारी।\nद्रवहु सुदसरथ अजर बिहारी।।",
            "He who brings auspiciousness and removes inauspiciousness — may the son of Dasharatha, who roams in the forest, grant us grace.",
            "Ramcharitmanas, Sundar Kanda"
        )
    "ram_6" ->
        RepresentativeVerse(
            "बंदऊँ राम लखन वैदेही। जे तुलसी के परम सनेही।।",
            "I bow to Ram, Lakshman and Vaidehi — who are Tulsidas's supreme beloved.",
            "Ramcharitmanas, Doha 1"
        )
    "ram_7" ->
        RepresentativeVerse(
            "राम नाम मणि दीप धरु जीभा देहरी द्वार।\nतुलसी भीतर बाहेरहुँ जौं चाहसि उजियार।।",
            "Keep Ram's name as a jewel-lamp at the threshold of your tongue's door. O Tulsi, if you seek light both within and without — do this.",
            "Ramcharitmanas, Uttar Kanda"
        )
    else -> null
}
