package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoAwesome
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
fun DeityIdentityScreen(navController: NavController) {
    Scaffold(topBar = {
        TopAppBar(
            title = { Text("भगवान की पहचान", fontWeight = FontWeight.Bold) },
            navigationIcon = {
                IconButton(onClick = { navController.popBackStack() },
                    modifier = Modifier.semantics { contentDescription = "Back" }) {
                    Icon(Icons.Default.ArrowBack, contentDescription = null)
                }
            }
        )
    }) { padding ->
        Box(Modifier.fillMaxSize().padding(padding), contentAlignment = Alignment.Center) {
            Column(
                horizontalAlignment = Alignment.CenterHorizontally,
                modifier = Modifier.padding(24.dp)
            ) {
                Icon(Icons.Default.AutoAwesome, contentDescription = "भगवान की पहचान", modifier = Modifier.size(52.dp))
                Spacer(Modifier.height(12.dp))
                Text("किस भगवान के बारे में जानना चाहते हैं?", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.SemiBold)
                Spacer(Modifier.height(8.dp))
                Text("यहाँ आगे देवताओं और उनके स्वरूप से जुड़ी जानकारी को सरल रूप में जोड़ा जाएगा।")
            }
        }
    }
}
