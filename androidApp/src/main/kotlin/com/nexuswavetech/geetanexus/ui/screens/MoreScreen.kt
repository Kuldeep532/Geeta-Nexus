package com.nexuswavetech.geetanexus.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.ui.navigation.Screen

// ── Data ──────────────────────────────────────────────────────────────────────

data class CommunityItem(
    val label: String,
    val subtitle: String,
    val emoji: String,
    val url: String
)

data class InfoItem(
    val label: String,
    val icon: ImageVector,
    val route: String? = null,
    val url: String? = null
)

// ── Screen ─────────────────────────────────────────────────────────────────────

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoreScreen(navController: NavController) {
    val context = LocalContext.current

    fun openUrl(url: String) {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    }

    val communityItems = listOf(
        CommunityItem("Website",   "nexusweb.co.in",         "🌐", AppConfig.Social.WEBSITE),
        CommunityItem("Discord",   "Join our community",     "💬", AppConfig.Social.DISCORD),
        CommunityItem("Instagram", "@nexuswavetech",         "📸", AppConfig.Social.INSTAGRAM),
        CommunityItem("YouTube",   "Watch our content",      "▶️", AppConfig.Social.YOUTUBE),
        CommunityItem("LinkedIn",  "Nexus Waves Technologies","💼", AppConfig.Social.LINKEDIN),
        CommunityItem("Facebook",  "Follow us on Facebook",  "📘", AppConfig.Social.FACEBOOK),
        CommunityItem("Email",     AppConfig.COMPANY_EMAIL,  "✉️", AppConfig.Social.EMAIL),
    )

    val infoItems = listOf(
        InfoItem("About Us",       Icons.Default.Info,           route = Screen.About.route),
        InfoItem("Privacy Policy", Icons.Default.Security,       route = Screen.Privacy.route),
        InfoItem("Terms of Service",Icons.Default.Gavel,         route = Screen.Terms.route),
        InfoItem("Rate the App",   Icons.Default.StarRate,       url = "market://details?id=com.nexuswavetech.geetanexus"),
        InfoItem("Share App",      Icons.Default.Share,          url = null),
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = {
                    Column {
                        Text("More", fontWeight = FontWeight.Bold)
                        Text(AppConfig.COMPANY_NAME, style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
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
            // Community section
            item {
                Text("Community & Social", style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold, modifier = Modifier.padding(bottom = 4.dp))
            }
            item {
                ElevatedCard(shape = RoundedCornerShape(20.dp)) {
                    Column(modifier = Modifier.padding(8.dp)) {
                        communityItems.forEachIndexed { index, item ->
                            CommunityRow(item = item, onClick = { openUrl(item.url) })
                            if (index < communityItems.lastIndex) {
                                HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                            }
                        }
                    }
                }
            }

            // App info section
            item {
                Text("App Info", style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold, modifier = Modifier.padding(bottom = 4.dp))
            }
            item {
                ElevatedCard(shape = RoundedCornerShape(20.dp)) {
                    Column(modifier = Modifier.padding(8.dp)) {
                        infoItems.forEachIndexed { index, item ->
                            InfoRow(
                                item = item,
                                onClick = {
                                    when {
                                        item.route != null -> navController.navigate(item.route)
                                        item.label == "Share App" -> {
                                            val shareIntent = Intent(Intent.ACTION_SEND).apply {
                                                type = "text/plain"
                                                putExtra(Intent.EXTRA_TEXT,
                                                    "Explore the Bhagavad Gita, Shiva Mahapurana & Ramcharitmanas with Gita Nexus! ${AppConfig.Social.WEBSITE}")
                                            }
                                            context.startActivity(Intent.createChooser(shareIntent, "Share Gita Nexus"))
                                        }
                                        item.url != null -> runCatching { openUrl(item.url) }
                                    }
                                }
                            )
                            if (index < infoItems.lastIndex) {
                                HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                            }
                        }
                    }
                }
            }

            // API keys info card
            item {
                Card(
                    shape  = RoundedCornerShape(16.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.tertiaryContainer)
                ) {
                    Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Default.Key, contentDescription = null,
                                tint = MaterialTheme.colorScheme.onTertiaryContainer, modifier = Modifier.size(18.dp))
                            Text("Cloudflare API Keys Required", style = MaterialTheme.typography.labelLarge,
                                fontWeight = FontWeight.SemiBold, color = MaterialTheme.colorScheme.onTertiaryContainer)
                        }
                        Text("Add these secrets to your Cloudflare Worker for full AI features:",
                            style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onTertiaryContainer)
                        listOf(
                            "GEMINI_AI_API_KEY → aistudio.google.com",
                            "HF_TTS_API_KEY → huggingface.co/settings/tokens",
                            "HF_STT_API_KEY → huggingface.co/settings/tokens",
                            "HF_CHAT_API_KEY → huggingface.co/settings/tokens"
                        ).forEach { key ->
                            Text("• $key", style = MaterialTheme.typography.labelSmall,
                                color = MaterialTheme.colorScheme.onTertiaryContainer)
                        }
                    }
                }
            }

            // Footer
            item {
                Column(
                    modifier              = Modifier.fillMaxWidth().padding(vertical = 8.dp),
                    horizontalAlignment   = Alignment.CenterHorizontally,
                    verticalArrangement   = Arrangement.spacedBy(4.dp)
                ) {
                    Text("🪷 ${AppConfig.APP_NAME} v${AppConfig.APP_VERSION}",
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                    Text("© 2025 ${AppConfig.COMPANY_NAME}. All rights reserved.",
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
            }
        }
    }
}

// ── Row components ─────────────────────────────────────────────────────────────

@Composable
private fun CommunityRow(item: CommunityItem, onClick: () -> Unit) {
    Row(
        modifier          = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Text(item.emoji, fontSize = 24.sp, modifier = Modifier.size(32.dp))
        Column(modifier = Modifier.weight(1f)) {
            Text(item.label, style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Medium)
            Text(item.subtitle, style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
        Icon(Icons.Default.OpenInNew, contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant, modifier = Modifier.size(16.dp))
    }
}

@Composable
private fun InfoRow(item: InfoItem, onClick: () -> Unit) {
    Row(
        modifier          = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Icon(item.icon, contentDescription = null,
            tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(22.dp))
        Text(item.label, style = MaterialTheme.typography.bodyLarge,
            fontWeight = FontWeight.Medium, modifier = Modifier.weight(1f))
        Icon(Icons.Default.ChevronRight, contentDescription = null,
            tint = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
