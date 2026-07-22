package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.pager.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import kotlinx.coroutines.launch

private data class OnboardingPage(
    val icon: ImageVector,
    val title: String,
    val body: String
)

private val pages = listOf(
    OnboardingPage(
        icon  = Icons.Default.MenuBook,
        title = "Sacred Wisdom",
        body  = "Read all 700 verses of the Bhagavad Gita in Sanskrit, transliteration, and English — chapter by chapter or verse by verse."
    ),
    OnboardingPage(
        icon  = Icons.Default.AutoAwesome,
        title = "Ask Aira AI",
        body  = "Your AI spiritual companion answers life questions, guides you to relevant verses, and offers practical wisdom rooted in the Gita."
    ),
    OnboardingPage(
        icon  = Icons.Default.Bookmark,
        title = "Save & Reflect",
        body  = "Bookmark verses that resonate, track your daily sadhana, and journal your reflections — all in one place."
    )
)

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun OnboardingScreen(navController: NavController) {
    val pagerState = rememberPagerState { pages.size }
    val scope      = rememberCoroutineScope()

    fun finish() = navController.navigate(Screen.Home.route) {
        popUpTo(Screen.Onboarding.route) { inclusive = true }
    }

    Column(
        modifier = Modifier.fillMaxSize().statusBarsPadding().navigationBarsPadding(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        HorizontalPager(
            state    = pagerState,
            modifier = Modifier.weight(1f)
        ) { pageIndex ->
            val page = pages[pageIndex]
            Column(
                modifier              = Modifier.fillMaxSize().padding(40.dp),
                horizontalAlignment   = Alignment.CenterHorizontally,
                verticalArrangement   = Arrangement.Center
            ) {
                Surface(
                    shape = MaterialTheme.shapes.large,
                    color = MaterialTheme.colorScheme.primaryContainer,
                    modifier = Modifier.size(120.dp).semantics { heading() }
                ) {
                    Box(contentAlignment = Alignment.Center) {
                        Icon(
                            imageVector        = page.icon,
                            contentDescription = null,
                            modifier           = Modifier.size(56.dp),
                            tint               = MaterialTheme.colorScheme.primary
                        )
                    }
                }
                Spacer(Modifier.height(32.dp))
                Text(
                    text      = page.title,
                    style     = MaterialTheme.typography.headlineMedium,
                    textAlign = TextAlign.Center
                )
                Spacer(Modifier.height(16.dp))
                Text(
                    text      = page.body,
                    style     = MaterialTheme.typography.bodyLarge,
                    textAlign = TextAlign.Center,
                    color     = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        // Page indicator
        Row(
            modifier              = Modifier.padding(16.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            repeat(pages.size) { idx ->
                val width = if (pagerState.currentPage == idx) 24.dp else 8.dp
                Surface(
                    modifier = Modifier.height(8.dp).width(width).semantics {
                        contentDescription = "Page ${idx + 1} of ${pages.size}"
                    },
                    shape = MaterialTheme.shapes.small,
                    color = if (pagerState.currentPage == idx) MaterialTheme.colorScheme.primary
                            else MaterialTheme.colorScheme.onSurface.copy(alpha = 0.2f)
                ) {}
            }
        }

        // Navigation buttons
        Row(
            modifier              = Modifier.fillMaxWidth().padding(horizontal = 24.dp, vertical = 16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment     = Alignment.CenterVertically
        ) {
            if (pagerState.currentPage < pages.lastIndex) {
                TextButton(
                    onClick  = ::finish,
                    modifier = Modifier.semantics { contentDescription = "Skip onboarding" }
                ) { Text("Skip") }

                Button(
                    onClick  = { scope.launch { pagerState.animateScrollToPage(pagerState.currentPage + 1) } },
                    modifier = Modifier.semantics { contentDescription = "Next page" }
                ) { Text("Next") }
            } else {
                Spacer(Modifier.weight(1f))
                Button(
                    onClick  = ::finish,
                    modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Get started" }
                ) { Text("Get Started  🙏") }
            }
        }
    }
}
