package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.AppConfig

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AboutScreen(navController: NavController) {
    val saffron = Color(0xFFFF6F00)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("About Us", fontWeight = FontWeight.Bold) },
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
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            // Hero
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(24.dp))
                        .background(
                            Brush.linearGradient(listOf(Color(0xFFFF8F00), Color(0xFFE65100)))
                        )
                        .padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("🪷", fontSize = 56.sp)
                        Text(AppConfig.APP_NAME, style = MaterialTheme.typography.headlineMedium,
                            color = Color.White, fontWeight = FontWeight.Bold)
                        Text("v${AppConfig.APP_VERSION}", style = MaterialTheme.typography.labelLarge,
                            color = Color.White.copy(alpha = 0.8f))
                        Spacer(Modifier.height(4.dp))
                        Text(AppConfig.COMPANY_NAME, style = MaterialTheme.typography.bodyMedium,
                            color = Color.White.copy(alpha = 0.9f), fontWeight = FontWeight.SemiBold)
                    }
                }
            }

            // Mission
            item {
                InfoCard(
                    icon  = Icons.Default.Favorite,
                    title = "Our Mission",
                    body  = "Gita Nexus was born from a deep reverence for India's ancient spiritual wisdom. Our mission is to make the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas accessible to every seeker — with AI-powered guidance, audio recitation, and a modern reading experience. We believe ancient wisdom holds the answers to modern problems."
                )
            }

            // What we offer
            item {
                ElevatedCard(shape = RoundedCornerShape(20.dp)) {
                    Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                        Text("What Gita Nexus Offers", style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
                        FeatureRow(icon = "📖", text = "Complete Bhagavad Gita — 18 chapters, 700 verses with Sanskrit, transliteration & commentary")
                        FeatureRow(icon = "🔱", text = "Shiva Mahapurana — 7 Samhitas with descriptions and AI narration")
                        FeatureRow(icon = "🙏", text = "Ramcharitmanas — 7 Kandas by Goswami Tulsidas")
                        FeatureRow(icon = "🤖", text = "Aira AI — Gemini-powered spiritual guide for your questions")
                        FeatureRow(icon = "🎧", text = "AI Text-to-Speech audio for every verse — listen while you commute")
                        FeatureRow(icon = "🔖", text = "Bookmarks, Daily Verse, and spiritual journal")
                        FeatureRow(icon = "🌐", text = "Cross-platform — Android & iOS, built with Kotlin Multiplatform")
                    }
                }
            }

            // Company
            item {
                InfoCard(
                    icon  = Icons.Default.Business,
                    title = "About ${AppConfig.COMPANY_NAME}",
                    body  = "${AppConfig.COMPANY_NAME} is a technology company dedicated to building products that bridge India's rich cultural and spiritual heritage with modern technology. We create apps and platforms that serve the community with purpose, transparency, and devotion.\n\nHeadquartered in India, our small but passionate team works to bring the wisdom of the ancients to billions of smartphones."
                )
            }

            // Tech stack
            item {
                Card(shape = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.secondaryContainer)) {
                    Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text("Built With", style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.SemiBold,
                            color = MaterialTheme.colorScheme.onSecondaryContainer)
                        Text("Kotlin Multiplatform • Jetpack Compose • Material 3 • Google Gemini 1.5 Flash • Cloudflare Workers • Media3 ExoPlayer • Hugging Face AI",
                            style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSecondaryContainer)
                    }
                }
            }

            // Contact
            item {
                InfoCard(
                    icon  = Icons.Default.Email,
                    title = "Contact Us",
                    body  = "For support, feedback, or partnership enquiries:\n\n${AppConfig.COMPANY_EMAIL}\n\nWe read every message and respond within 48 hours."
                )
            }

            // Legal links
            item {
                Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.SpaceEvenly) {
                    TextButton(onClick = { navController.navigate(com.nexuswavetech.geetanexus.ui.navigation.Screen.Privacy.route) }) {
                        Text("Privacy Policy")
                    }
                    TextButton(onClick = { navController.navigate(com.nexuswavetech.geetanexus.ui.navigation.Screen.Terms.route) }) {
                        Text("Terms of Service")
                    }
                }
            }

            item {
                Text(
                    "ॐ नमः शिवाय • जय श्री राम • हरे कृष्ण",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center,
                    modifier = Modifier.fillMaxWidth().padding(bottom = 8.dp)
                )
            }
        }
    }
}

@Composable
private fun InfoCard(icon: ImageVector, title: String, body: String) {
    ElevatedCard(shape = RoundedCornerShape(20.dp)) {
        Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalAlignment = Alignment.CenterVertically) {
                Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                Text(title, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
            }
            Text(body, style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant, lineHeight = 24.sp)
        }
    }
}

@Composable
private fun FeatureRow(icon: String, text: String) {
    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
        Text(icon, fontSize = 18.sp)
        Text(text, style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.weight(1f))
    }
}
