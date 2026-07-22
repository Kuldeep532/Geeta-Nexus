package com.nexuswavetech.geetanexus.ui.screens

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.*
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.AppConfig

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MoreScreen(navController: NavController) {
    val context = LocalContext.current

    fun openUrl(url: String) {
        context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
    }

    val sections = listOf(
        MoreSection(
            heading = "Community",
            items = listOf(
                MoreItem("Discord",   Icons.Default.Forum,    AppConfig.DISCORD_URL),
                MoreItem("Instagram", Icons.Default.PhotoCamera, AppConfig.INSTAGRAM_URL),
                MoreItem("LinkedIn",  Icons.Default.Business, AppConfig.LINKEDIN_URL),
                MoreItem("Facebook",  Icons.Default.People,   AppConfig.FACEBOOK_URL),
                MoreItem("Website",   Icons.Default.Language, AppConfig.WEBSITE_URL),
            )
        ),
        MoreSection(
            heading = "Information",
            items = listOf(
                MoreItem("Privacy Policy",    Icons.Default.PrivacyTip,     null),
                MoreItem("Terms of Service",  Icons.Default.Gavel,          null),
                MoreItem("About",             Icons.Default.Info,            null),
            )
        )
    )

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("More") },
                navigationIcon = {
                    IconButton(
                        onClick  = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "Go back" }
                    ) { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null) }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier       = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(4.dp)
        ) {
            sections.forEach { section ->
                item {
                    Text(
                        text     = section.heading,
                        style    = MaterialTheme.typography.labelLarge,
                        color    = MaterialTheme.colorScheme.primary,
                        modifier = Modifier.padding(vertical = 8.dp)
                    )
                }
                items(section.items) { item ->
                    Card(modifier = Modifier.fillMaxWidth().padding(vertical = 2.dp)) {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable(onClickLabel = item.label) {
                                    item.url?.let { openUrl(it) }
                                }
                                .padding(16.dp)
                                .semantics { contentDescription = item.label },
                            verticalAlignment = Alignment.CenterVertically,
                            horizontalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            Icon(item.icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
                            Text(item.label, style = MaterialTheme.typography.bodyLarge)
                            Spacer(Modifier.weight(1f))
                            if (item.url != null) {
                                Icon(Icons.Default.OpenInNew, contentDescription = "External link", modifier = Modifier.size(16.dp), tint = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                        }
                    }
                }
                item { Spacer(Modifier.height(8.dp)) }
            }
        }
    }
}

private data class MoreSection(val heading: String, val items: List<MoreItem>)
private data class MoreItem(val label: String, val icon: ImageVector, val url: String?)
