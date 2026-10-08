package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
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
fun MandirScreen(navController: NavController) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("राधा कृष्ण मंदिर", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "Back to previous screen" }
                    ) { Icon(Icons.Default.ArrowBack, contentDescription = null) }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            item {
                Card(
                    modifier = Modifier.fillMaxWidth(),
                    shape = RoundedCornerShape(24.dp)
                ) {
                    Column(
                        modifier = Modifier.padding(24.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(10.dp)
                    ) {
                        Text("राधा कृष्ण", style = MaterialTheme.typography.headlineMedium, fontWeight = FontWeight.Bold)
                        Text(
                            "यह गीता नेक्सस का आध्यात्मिक मंदिर है। यहाँ से पूजा, दर्शन और भक्ति से जुड़े अनुभव एक ही स्थान पर मिलेंगे।",
                            style = MaterialTheme.typography.bodyLarge
                        )
                        Button(
                            onClick = { },
                            modifier = Modifier.fillMaxWidth().semantics {
                                contentDescription = "Open Radha Krishna Mandir"
                            }
                        ) {
                            Icon(Icons.Default.TempleHindu, contentDescription = null)
                            Spacer(Modifier.width(8.dp))
                            Text("मंदिर में प्रवेश करें")
                        }
                    }
                }
            }
        }
    }
}
