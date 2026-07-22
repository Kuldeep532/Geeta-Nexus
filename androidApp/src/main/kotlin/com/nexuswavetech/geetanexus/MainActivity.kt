package com.nexuswavetech.geetanexus

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.*
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.semantics.*
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.nexuswavetech.geetanexus.ui.navigation.GeetaNexusNavGraph
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import com.nexuswavetech.geetanexus.ui.theme.GeetaNexusTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            GeetaNexusTheme {
                GeetaNexusScaffold()
            }
        }
    }
}

private data class NavItem(
    val screen: Screen,
    val label: String,
    val icon: ImageVector,
    val contentDescription: String
)

private val bottomNavItems = listOf(
    NavItem(Screen.Home,      "Home",      Icons.Default.Home,           "Navigate to Home"),
    NavItem(Screen.Chapters,  "Gita",      Icons.Default.MenuBook,       "Navigate to Bhagavad Gita chapters"),
    NavItem(Screen.AiChat,    "Aira",      Icons.Default.AutoAwesome,    "Open AI spiritual assistant"),
    NavItem(Screen.Bookmarks, "Saved",     Icons.Default.Bookmark,       "View bookmarked verses"),
    NavItem(Screen.Profile,   "Profile",   Icons.Default.AccountCircle,  "View your profile"),
)

// Screens that should NOT show the bottom bar
private val fullScreenRoutes = setOf(
    Screen.VerseReader.route,
    Screen.Onboarding.route
)

@Composable
fun GeetaNexusScaffold() {
    val navController = rememberNavController()
    val navBackStack  by navController.currentBackStackEntryAsState()
    val currentRoute  = navBackStack?.destination?.route

    val showBottomBar = currentRoute !in fullScreenRoutes &&
        !currentRoute.orEmpty().startsWith("verse/")

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            AnimatedVisibility(
                visible = showBottomBar,
                enter   = slideInVertically { it },
                exit    = slideOutVertically { it }
            ) {
                NavigationBar(
                    containerColor = MaterialTheme.colorScheme.surface
                ) {
                    val hierarchy = navBackStack?.destination?.hierarchy
                    bottomNavItems.forEach { item ->
                        val selected = hierarchy?.any { it.route == item.screen.route } == true
                        NavigationBarItem(
                            selected = selected,
                            onClick  = {
                                navController.navigate(item.screen.route) {
                                    popUpTo(navController.graph.findStartDestination().id) {
                                        saveState = true
                                    }
                                    launchSingleTop = true
                                    restoreState    = true
                                }
                            },
                            icon = {
                                Icon(
                                    imageVector         = item.icon,
                                    contentDescription  = item.contentDescription
                                )
                            },
                            label = {
                                Text(
                                    text = item.label,
                                    style = MaterialTheme.typography.labelLarge
                                )
                            },
                            alwaysShowLabel = false
                        )
                    }
                }
            }
        }
    ) { innerPadding ->
        GeetaNexusNavGraph(
            navController    = navController,
            startDestination = Screen.Home.route
        )
    }
}
