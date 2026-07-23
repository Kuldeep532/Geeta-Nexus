package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyListScope
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.AppConfig

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TermsScreen(navController: NavController) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Terms of Service", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(onClick = { navController.popBackStack() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
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
            item {
                Text("Effective date: June 2025", style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }

            termsSection("1. Acceptance of Terms",
                "By downloading, installing, or using ${AppConfig.APP_NAME} ("the App"), you agree to be bound by these Terms of Service. If you do not agree to these terms, do not use the App.\n\nThe App is operated by ${AppConfig.COMPANY_NAME} ("Company", "we", "us").")

            termsSection("2. Description of Service",
                "${AppConfig.APP_NAME} provides:\n• Digital access to the Bhagavad Gita, Shiva Mahapurana, and Ramcharitmanas\n• An AI-powered spiritual guidance assistant (Aira)\n• Text-to-speech audio narration of sacred texts\n• Personal bookmarking and journaling features\n• Community and devotional resources\n\nThe App is provided free of charge. Premium features may be introduced in future updates.")

            termsSection("3. User Conduct",
                "You agree NOT to:\n• Use the App for any unlawful purpose\n• Attempt to reverse-engineer, decompile, or extract source code\n• Use the AI assistant to generate harmful, offensive, or misleading content\n• Circumvent the security measures (Ed25519 signature verification) protecting the API\n• Impersonate another person or entity\n• Use the App to spam or harass others")

            termsSection("4. Intellectual Property",
                "The sacred texts included (Bhagavad Gita, Shiva Mahapurana, Ramcharitmanas) are in the public domain. The translations and commentary used may be sourced from various open-license providers.\n\nThe App's source code, design, branding, logo, and AI system (Aira) are the intellectual property of ${AppConfig.COMPANY_NAME}. You may not reproduce, distribute, or create derivative works without written permission.\n\nUser-generated content (journal entries, bookmarks) remains your property and is stored only on your device.")

            termsSection("5. AI Disclaimer",
                "Aira, our AI spiritual guide, is powered by Google Gemini and other AI models. While we strive for accuracy:\n\n• AI responses are for informational and inspirational purposes only\n• AI may make errors in interpreting scripture — always consult a qualified guru or scholar for important spiritual decisions\n• The AI does not replace professional advice of any kind (medical, legal, financial, or otherwise)\n• We are not responsible for decisions made based solely on AI-generated responses")

            termsSection("6. Audio Content",
                "Text-to-speech audio is generated on-demand using AI models. The audio:\n• Is for personal, non-commercial use only\n• May not be downloaded, distributed, or used commercially\n• Quality may vary based on AI model performance\n• Requires internet connectivity to generate")

            termsSection("7. Availability & Changes",
                "We reserve the right to:\n• Modify, suspend, or discontinue any part of the App without notice\n• Update these Terms at any time (continued use = acceptance)\n• Change or remove features, including AI capabilities, based on third-party API availability\n\nWe will make reasonable efforts to notify users of significant changes.")

            termsSection("8. Limitation of Liability",
                "${AppConfig.COMPANY_NAME} and its officers, directors, employees, and agents shall not be liable for:\n• Any indirect, incidental, special, or consequential damages\n• Loss of data or profits\n• Errors in AI-generated spiritual guidance\n• Service interruptions\n\nThe App is provided 'as is' without warranties of any kind.")

            termsSection("9. Governing Law",
                "These Terms shall be governed by and construed in accordance with the laws of India. Any disputes shall be subject to the exclusive jurisdiction of courts in India.")

            termsSection("10. Contact",
                "For questions about these Terms:\n\n${AppConfig.COMPANY_NAME}\nEmail: ${AppConfig.COMPANY_EMAIL}\nWebsite: ${AppConfig.Social.WEBSITE}")
        }
    }
}

private fun LazyListScope.termsSection(title: String, body: String) {
    item {
        ElevatedCard(shape = RoundedCornerShape(16.dp)) {
            Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(title, style = MaterialTheme.typography.titleSmall, fontWeight = FontWeight.Bold)
                Text(body, style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant, lineHeight = 22.sp)
            }
        }
    }
}
