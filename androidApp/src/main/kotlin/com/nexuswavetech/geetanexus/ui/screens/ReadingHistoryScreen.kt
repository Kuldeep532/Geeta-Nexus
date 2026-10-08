package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.History
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReadingHistoryScreen(navController: NavController) {
    Scaffold(topBar = {
        TopAppBar(
            title = { Text("Reading History", fontWeight = FontWeight.Bold) },
            navigationIcon = {
                IconButton(onClick = { navController.popBackStack() },
                    modifier = Modifier.semantics { contentDescription = "Back" }) {
                    Icon(Icons.Default.ArrowBack, contentDescription = null)
                }
            }
        )
    }) { padding ->
        Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
            Column(horizontalAlignment = Alignment.CenterHorizontally) {
                Icon(Icons.Default.History, contentDescription = "Reading history", modifier = Modifier.size(48.dp))
                Spacer(Modifier.height(12.dp))
                Text("आपकी पढ़ने की यात्रा यहाँ दिखाई देगी।", style = MaterialTheme.typography.bodyLarge)
            }
        }
    }
}
