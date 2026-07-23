package com.nexuswavetech.geetanexus.ui.screens

import android.app.Activity
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.input.*
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.ui.viewmodel.AuthState
import com.nexuswavetech.geetanexus.ui.viewmodel.AuthViewModel
import org.koin.androidx.compose.koinViewModel

@Composable
fun AuthScreen(
    navController: NavController,
    onAuthSuccess: () -> Unit,
    viewModel: AuthViewModel = koinViewModel()
) {
    val authState by viewModel.authState.collectAsState()
    val context   = LocalContext.current

    // Navigate on success
    LaunchedEffect(authState) {
        if (authState is AuthState.Success) {
            viewModel.reset()
            onAuthSuccess()
        }
    }

    var mode         by remember { mutableStateOf(AuthMode.CHOOSE) }
    var email        by remember { mutableStateOf("") }
    var password     by remember { mutableStateOf("") }
    var name         by remember { mutableStateOf("") }
    var showPassword by remember { mutableStateOf(false) }

    val isLoading = authState is AuthState.Loading
    val errorMsg  = (authState as? AuthState.Error)?.message

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(listOf(Color(0xFFFF8F00), Color(0xFFE65100)))
            ),
        contentAlignment = Alignment.Center
    ) {
        Card(
            shape  = RoundedCornerShape(topStart = 32.dp, topEnd = 32.dp),
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.BottomCenter)
        ) {
            Column(
                modifier = Modifier.padding(24.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Header
                Text("🪷", fontSize = 40.sp,
                    modifier = Modifier.semantics { contentDescription = "Gita Nexus logo" })
                Text("Welcome to Gita Nexus",
                    style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold,
                    textAlign = TextAlign.Center)
                Text("Sign in to save your progress and access all features across devices.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    textAlign = TextAlign.Center)

                // Error banner
                AnimatedVisibility(visible = errorMsg != null) {
                    errorMsg?.let { err ->
                        Card(
                            colors = CardDefaults.cardColors(
                                containerColor = MaterialTheme.colorScheme.errorContainer
                            ), shape = RoundedCornerShape(12.dp)
                        ) {
                            Text(err, modifier = Modifier.padding(12.dp),
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onErrorContainer)
                        }
                    }
                }

                when (mode) {
                    AuthMode.CHOOSE -> {
                        // Google sign-in (Credential Manager)
                        Button(
                            onClick  = {
                                val activity = context as? Activity ?: return@Button
                                viewModel.signInWithGoogle(activity)
                            },
                            enabled  = !isLoading,
                            modifier = Modifier
                                .fillMaxWidth()
                                .semantics { contentDescription = "Sign in with Google" }
                        ) {
                            if (isLoading) {
                                CircularProgressIndicator(modifier = Modifier.size(20.dp),
                                    strokeWidth = 2.dp,
                                    color = MaterialTheme.colorScheme.onPrimary)
                            } else {
                                Icon(Icons.Default.AccountCircle, contentDescription = null)
                                Spacer(Modifier.width(8.dp))
                                Text("Continue with Google")
                            }
                        }

                        OutlinedButton(
                            onClick  = { mode = AuthMode.SIGN_IN },
                            modifier = Modifier.fillMaxWidth().semantics {
                                contentDescription = "Sign in with email and password"
                            }
                        ) {
                            Icon(Icons.Default.Email, contentDescription = null)
                            Spacer(Modifier.width(8.dp))
                            Text("Sign in with Email")
                        }

                        TextButton(
                            onClick  = { mode = AuthMode.SIGN_UP },
                            modifier = Modifier.semantics { contentDescription = "Create new account" }
                        ) { Text("New here? Create an account") }

                        HorizontalDivider()

                        TextButton(
                            onClick  = { viewModel.continueAsGuest() },
                            enabled  = !isLoading,
                            modifier = Modifier.semantics { contentDescription = "Continue as guest without signing in" }
                        ) { Text("Continue as Guest (limited features)") }
                    }

                    AuthMode.SIGN_IN -> {
                        OutlinedTextField(
                            value = email, onValueChange = { email = it },
                            label = { Text("Email") },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                            singleLine = true,
                            modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Email input" }
                        )
                        OutlinedTextField(
                            value = password, onValueChange = { password = it },
                            label = { Text("Password") },
                            visualTransformation = if (showPassword) VisualTransformation.None
                                                   else PasswordVisualTransformation(),
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
                            trailingIcon = {
                                IconButton(onClick = { showPassword = !showPassword },
                                    modifier = Modifier.semantics {
                                        contentDescription = if (showPassword) "Hide password" else "Show password"
                                    }) {
                                    Icon(
                                        if (showPassword) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                        contentDescription = null
                                    )
                                }
                            },
                            singleLine = true,
                            modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Password input" }
                        )
                        Button(
                            onClick  = { viewModel.signInWithEmail(email, password) },
                            enabled  = !isLoading,
                            modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Sign in with email" }
                        ) {
                            if (isLoading) CircularProgressIndicator(modifier = Modifier.size(20.dp),
                                strokeWidth = 2.dp, color = MaterialTheme.colorScheme.onPrimary)
                            else Text("Sign In")
                        }
                        TextButton(onClick = { mode = AuthMode.CHOOSE }) { Text("← Back") }
                    }

                    AuthMode.SIGN_UP -> {
                        OutlinedTextField(
                            value = name, onValueChange = { name = it },
                            label = { Text("Your Name") }, singleLine = true,
                            modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Full name input" }
                        )
                        OutlinedTextField(
                            value = email, onValueChange = { email = it },
                            label = { Text("Email") },
                            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email),
                            singleLine = true,
                            modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Email input" }
                        )
                        OutlinedTextField(
                            value = password, onValueChange = { password = it },
                            label = { Text("Password (min 6 characters)") },
                            visualTransformation = if (showPassword) VisualTransformation.None
                                                   else PasswordVisualTransformation(),
                            trailingIcon = {
                                IconButton(onClick = { showPassword = !showPassword },
                                    modifier = Modifier.semantics {
                                        contentDescription = if (showPassword) "Hide password" else "Show password"
                                    }) {
                                    Icon(if (showPassword) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                        contentDescription = null)
                                }
                            },
                            singleLine = true,
                            modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Password input" }
                        )
                        Button(
                            onClick  = { viewModel.signUpWithEmail(email, password, name) },
                            enabled  = !isLoading,
                            modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Create account" }
                        ) {
                            if (isLoading) CircularProgressIndicator(modifier = Modifier.size(20.dp),
                                strokeWidth = 2.dp, color = MaterialTheme.colorScheme.onPrimary)
                            else Text("Create Account")
                        }
                        TextButton(onClick = { mode = AuthMode.CHOOSE }) { Text("← Back") }
                    }
                }

                Spacer(Modifier.height(8.dp))
            }
        }
    }
}

private enum class AuthMode { CHOOSE, SIGN_IN, SIGN_UP }
