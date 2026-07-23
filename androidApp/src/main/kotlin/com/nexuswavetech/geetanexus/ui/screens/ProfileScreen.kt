package com.nexuswavetech.geetanexus.ui.screens

import android.app.Activity
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.AppConfig
import com.nexuswavetech.geetanexus.data.LocalUserRepository
import com.nexuswavetech.geetanexus.ui.navigation.Screen
import com.nexuswavetech.geetanexus.ui.viewmodel.HomeViewModel
import kotlinx.coroutines.launch
import org.koin.androidx.compose.koinViewModel
import org.koin.java.KoinJavaComponent

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ProfileScreen(
    navController: NavController,
    homeViewModel: HomeViewModel = koinViewModel()
) {
    val context  = LocalContext.current
    val user     by homeViewModel.currentUser.collectAsState()
    val userRepo by lazy { KoinJavaComponent.get<LocalUserRepository>(LocalUserRepository::class.java) }
    val scope    = rememberCoroutineScope()

    var isSigningIn by remember { mutableStateOf(false) }
    var signInError by remember { mutableStateOf<String?>(null) }

    val saffron = Color(0xFFFF6F00)
    val gold    = Color(0xFFFFB300)

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Profile", fontWeight = FontWeight.Bold) },
                actions = {
                    if (user != null) {
                        IconButton(onClick = { homeViewModel.signOut() }) {
                            Icon(Icons.Default.Logout, contentDescription = "Sign out")
                        }
                    }
                }
            )
        }
    ) { padding ->
        LazyColumn(
            modifier            = Modifier.fillMaxSize().padding(padding),
            contentPadding      = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            if (user != null) {
                val u = user!!

                // Signed-in header
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clip(RoundedCornerShape(24.dp))
                            .background(Brush.linearGradient(listOf(saffron, gold)))
                            .padding(24.dp)
                    ) {
                        Row(
                            horizontalArrangement = Arrangement.spacedBy(16.dp),
                            verticalAlignment     = Alignment.CenterVertically
                        ) {
                            Surface(shape = CircleShape, color = Color.White.copy(alpha = 0.25f),
                                modifier = Modifier.size(64.dp)) {
                                Box(contentAlignment = Alignment.Center, modifier = Modifier.fillMaxSize()) {
                                    Text(u.displayName.firstOrNull()?.uppercase() ?: "D",
                                        fontSize = 28.sp, color = Color.White, fontWeight = FontWeight.Bold)
                                }
                            }
                            Column {
                                Text(u.displayName, style = MaterialTheme.typography.headlineSmall,
                                    color = Color.White, fontWeight = FontWeight.Bold)
                                Text(u.email, style = MaterialTheme.typography.bodySmall,
                                    color = Color.White.copy(alpha = 0.85f))
                                Surface(shape = RoundedCornerShape(8.dp), color = Color.White.copy(alpha = 0.2f)) {
                                    Text(u.levelTitle, modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp),
                                        style = MaterialTheme.typography.labelSmall, color = Color.White)
                                }
                            }
                        }
                    }
                }

                // Stats
                item {
                    ElevatedCard(shape = RoundedCornerShape(20.dp)) {
                        Row(modifier = Modifier.fillMaxWidth().padding(20.dp),
                            horizontalArrangement = Arrangement.SpaceEvenly) {
                            StatItem("Level",   "${u.level}",              "⭐")
                            VerticalDivider(modifier = Modifier.height(48.dp))
                            StatItem("XP",      "${u.xp}",                 "✨")
                            VerticalDivider(modifier = Modifier.height(48.dp))
                            StatItem("Streak",  "${u.streakDays}d",        "🔥")
                            VerticalDivider(modifier = Modifier.height(48.dp))
                            StatItem("Chapters","${u.chaptersRead.size}",  "📖")
                        }
                    }
                }

                // XP progress
                item {
                    Card(shape = RoundedCornerShape(16.dp)) {
                        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            Row(horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                                Text("Progress to Level ${u.level + 1}", style = MaterialTheme.typography.labelMedium)
                                Text("${u.xp} / ${u.xpForNextLevel} XP", style = MaterialTheme.typography.labelSmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant)
                            }
                            LinearProgressIndicator(
                                progress = { (u.xp.toFloat() / u.xpForNextLevel).coerceIn(0f, 1f) },
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                    }
                }

            } else {
                // Guest state
                item {
                    ElevatedCard(shape = RoundedCornerShape(24.dp)) {
                        Column(
                            modifier            = Modifier.fillMaxWidth().padding(32.dp),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            Text("🧘", fontSize = 60.sp)
                            Text("Welcome, Seeker", style = MaterialTheme.typography.headlineSmall,
                                fontWeight = FontWeight.Bold)
                            Text(
                                "Sign in to save your progress, bookmarks, and reading streak across devices.",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )

                            signInError?.let { err ->
                                Card(shape = RoundedCornerShape(12.dp),
                                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer)) {
                                    Text(err, modifier = Modifier.padding(12.dp),
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onErrorContainer)
                                }
                            }

                            Button(
                                onClick  = {
                                    val activity = context as? Activity ?: return@Button
                                    isSigningIn = true
                                    signInError = null
                                    scope.launch {
                                        val result = userRepo.signInWithCredentialManager(activity)
                                        result.fold(
                                            onSuccess = { homeViewModel.loadUser() },
                                            onFailure = { e ->
                                                signInError = when {
                                                    e.message?.contains("cancel", true) == true   -> "Sign-in cancelled. Try again."
                                                    e.message?.contains("credential", true) == true -> "No Google account found on this device."
                                                    else -> "Sign-in failed: ${e.message}"
                                                }
                                            }
                                        )
                                        isSigningIn = false
                                    }
                                },
                                enabled  = !isSigningIn,
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                if (isSigningIn) {
                                    CircularProgressIndicator(modifier = Modifier.size(20.dp), strokeWidth = 2.dp,
                                        color = MaterialTheme.colorScheme.onPrimary)
                                } else {
                                    Icon(Icons.Default.AccountCircle, contentDescription = null, modifier = Modifier.size(20.dp))
                                    Spacer(Modifier.width(8.dp))
                                    Text("Sign in with Google")
                                }
                            }

                            TextButton(onClick = { navController.popBackStack() }) {
                                Text("Continue as Guest")
                            }
                        }
                    }
                }
            }

            // Settings (always visible)
            item {
                ElevatedCard(shape = RoundedCornerShape(20.dp)) {
                    Column(modifier = Modifier.padding(8.dp)) {
                        ProfileMenuItem(Icons.Default.Search,   "Search Verses") { navController.navigate(Screen.Search.route) }
                        HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                        ProfileMenuItem(Icons.Default.Info,     "About Us")      { navController.navigate(Screen.About.route)   }
                        HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                        ProfileMenuItem(Icons.Default.Security, "Privacy Policy"){ navController.navigate(Screen.Privacy.route) }
                        HorizontalDivider(modifier = Modifier.padding(horizontal = 16.dp))
                        ProfileMenuItem(Icons.Default.Gavel,    "Terms of Service"){ navController.navigate(Screen.Terms.route) }
                    }
                }
            }

            item {
                Text("© 2025 ${AppConfig.COMPANY_NAME}  •  v${AppConfig.APP_VERSION}",
                    style = MaterialTheme.typography.labelSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.fillMaxWidth())
            }
        }
    }
}

@Composable
private fun StatItem(label: String, value: String, icon: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally, verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Text(icon, fontSize = 20.sp)
        Text(value, style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.Bold)
        Text(label, style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}

@Composable
private fun ProfileMenuItem(icon: ImageVector, label: String, onClick: () -> Unit) {
    Row(
        modifier          = Modifier.fillMaxWidth().clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 14.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Icon(icon, contentDescription = null, tint = MaterialTheme.colorScheme.primary)
        Text(label, style = MaterialTheme.typography.bodyLarge, modifier = Modifier.weight(1f))
        Icon(Icons.Default.ChevronRight, contentDescription = null, tint = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
