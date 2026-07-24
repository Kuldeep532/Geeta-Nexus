package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
fun PrivacyPolicyScreen(navController: NavController) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Privacy Policy", fontWeight = FontWeight.Bold) },
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
                Text("Last updated: June 2025", style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant)
            }

            privacySection("1. Introduction",
                "${AppConfig.COMPANY_NAME} ("we", "our", "us") operates the ${AppConfig.APP_NAME} mobile application. This Privacy Policy explains how we collect, use, and protect your information when you use our app.")

            privacySection("2. Information We Collect",
                "**Account Information**: When you sign in with Google, we receive your name, email address, and profile photo from Google. We do not receive your Google password.\n\n**Usage Data**: We may collect anonymised usage statistics (screens visited, features used) to improve the app. This data does not identify you personally.\n\n**Voice Data**: If you use the voice input (STT) feature, your voice is sent to our AI backend for transcription. We do not store voice recordings beyond the duration of the transcription request.\n\n**Device Information**: We may collect device type, OS version, and crash logs for debugging purposes.")

            privacySection("3. How We Use Your Information",
                "• To provide and personalise the app experience\n• To save your bookmarks and reading progress locally on your device\n• To process your questions through our AI assistant (Aira)\n• To generate audio (TTS) for verses you request\n• To analyse anonymous usage patterns and improve features\n• To respond to your support requests")

            privacySection("4. Data Storage",
                "Most of your data (bookmarks, reading progress, journal entries) is stored **locally on your device** using Android DataStore and Firebase Firestore (for synced data). We do not store raw conversation data permanently.\n\nWhen you use Aira AI, your question is sent securely to Google Gemini via our Cloudflare Worker gateway. The Worker fetches API keys at runtime — no keys are stored on your device. These AI requests are not stored permanently.\n\nWe use Cloudflare Workers as an API gateway. Cloudflare may log metadata such as request timestamps and IP addresses per their own Privacy Policy.")

            privacySection("5. Third-Party Services",
                "We use the following third-party services:\n\n**Google Sign-In**: For authentication. Subject to Google's Privacy Policy.\n**Google Gemini AI**: For AI-powered spiritual guidance. Subject to Google's AI Terms.\n**Hugging Face**: For text-to-speech and speech-to-text. Subject to Hugging Face's Privacy Policy.\n**Cloudflare**: For API gateway and security. Subject to Cloudflare's Privacy Policy.\n**DharmicData (GitHub)**: Open-source Bhagavad Gita data (public repository).")

            privacySection("6. Data Security",
                "We implement industry-standard security measures:\n• Ed25519 digital signature authentication for all API requests\n• HTTPS/TLS encryption for all network communication\n• No cleartext data transmission (enforced via network security config)\n• API keys never stored in app code — served via secure Cloudflare gateway\n• No sensitive data stored in shared preferences unencrypted")

            privacySection("7. Children's Privacy",
                "${AppConfig.APP_NAME} is not directed to children under 13. We do not knowingly collect personal information from children under 13. If you believe a child has provided us with personal information, please contact us immediately.")

            privacySection("8. Your Rights",
                "You have the right to:\n• Access the personal data we hold about you\n• Request deletion of your data\n• Sign out at any time (this removes your profile from the app)\n• Disable voice features and AI features\n\nTo exercise these rights, contact us at ${AppConfig.COMPANY_EMAIL}")

            privacySection("9. Changes to This Policy",
                "We may update this Privacy Policy from time to time. We will notify you of significant changes by updating the 'Last updated' date. Continued use of the app after changes constitutes acceptance of the updated policy.")

            privacySection("10. Contact Us",
                "If you have any questions about this Privacy Policy, please contact:\n\n${AppConfig.COMPANY_NAME}\nEmail: ${AppConfig.COMPANY_EMAIL}\nWebsite: ${AppConfig.Social.WEBSITE}")
        }
    }
}

@Suppress("FunctionName")
private fun androidx.compose.foundation.lazy.LazyListScope.privacySection(title: String, body: String) {
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
