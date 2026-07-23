package com.nexuswavetech.geetanexus

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.*
import androidx.navigation.NavDestination.Companion.hierarchy
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.nexuswavetech.geetanexus.ui.navigation.GeetaNexusNavGraph
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import com.nexuswavetech.geetanexus.ui.navigation.fullScreenRoutes
import com.nexuswavetech.geetanexus.ui.theme.GeetaNexusTheme
import com.nexuswavetech.geetanexus.ui.viewmodel.AudioViewModel
import org.koin.androidx.compose.koinViewModel

data class BottomNavItem(
    val screen: Screen,
    val label: String,
    val icon: ImageVector,
    val selectedIcon: ImageVector = icon,
    val contentDescription: String
)

val bottomNavItems = listOf(
    BottomNavItem(Screen.Home,       "Home",       Icons.Default.Home,        Icons.Filled.Home,       "Home screen"),
    BottomNavItem(Screen.Scriptures, "Scriptures", Icons.Default.MenuBook,    Icons.Filled.MenuBook,   "Sacred scriptures"),
    BottomNavItem(Screen.AiChat,     "Aira AI",    Icons.Default.AutoAwesome, Icons.Filled.AutoAwesome,"Aira spiritual AI"),
    BottomNavItem(Screen.Quiz,       "Quiz",       Icons.Default.Quiz,        Icons.Filled.Quiz,       "Spiritual quiz"),
    BottomNavItem(Screen.More,       "More",       Icons.Default.MoreHoriz,   Icons.Filled.MoreHoriz,  "More options"),
)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            GeetaNexusTheme {
                GeetaNexusAppRoot()
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun GeetaNexusAppRoot() {
    val navController      = rememberNavController()
    val audioViewModel     = koinViewModel<AudioViewModel>()
    val backStackEntry     by navController.currentBackStackEntryAsState()
    val currentDestination  = backStackEntry?.destination
    val currentRoute        = currentDestination?.route ?: ""

    val showBottomBar = fullScreenRoutes.none { currentRoute.startsWith(it.substringBefore("{")) }

    Scaffold(
        modifier = Modifier.fillMaxSize(),
        bottomBar = {
            AnimatedVisibility(
                visible = showBottomBar,
                enter   = slideInVertically { it },
                exit    = slideOutVertically { it }
            ) {
                NavigationBar {
                    bottomNavItems.forEach { item ->
                        val selected = currentDestination?.hierarchy?.any {
                            it.route == item.screen.route
                        } == true
                        NavigationBarItem(
                            selected  = selected,
                            onClick   = {
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
                                    imageVector        = if (selected) item.selectedIcon else item.icon,
                                    contentDescription = null   // label handles accessibility
                                )
                            },
                            label = {
                                Text(
                                    text = item.label,
                                    modifier = Modifier.semantics {
                                        contentDescription = item.contentDescription +
                                            if (selected) ", selected" else ""
                                    }
                                )
                            }
                        )
                    }
                }
            }
        }
    ) { padding ->
        GeetaNexusNavGraph(
            navController  = navController,
            audioViewModel = audioViewModel,
            modifier       = Modifier.padding(padding)
        )
    }
}
