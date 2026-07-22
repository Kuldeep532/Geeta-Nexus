package com.nexuswavetech.geetanexus.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

// ── Brand Palette ────────────────────────────────────────────────────────────
// Saffron-gold spiritual theme; adapts to dynamic colour on Android 12+

private val Saffron     = Color(0xFFFF9800)
private val SaffronDark = Color(0xFFE65100)
private val NavyDeep    = Color(0xFF001A4D)
private val NavyMid     = Color(0xFF002266)
private val Gold        = Color(0xFFFFD700)
private val CreamWhite  = Color(0xFFFFF8F0)
private val SurfaceDark = Color(0xFF12182B)

private val DarkColorScheme = darkColorScheme(
    primary          = Saffron,
    onPrimary        = Color.Black,
    primaryContainer = SaffronDark,
    secondary        = Gold,
    onSecondary      = Color.Black,
    tertiary         = Color(0xFF7E57C2),
    background       = Color(0xFF0D1117),
    surface          = SurfaceDark,
    surfaceVariant   = Color(0xFF1E2A45),
    onBackground     = CreamWhite,
    onSurface        = CreamWhite,
    error            = Color(0xFFCF6679)
)

private val LightColorScheme = lightColorScheme(
    primary          = SaffronDark,
    onPrimary        = Color.White,
    primaryContainer = Color(0xFFFFDDB3),
    secondary        = NavyDeep,
    onSecondary      = Color.White,
    tertiary         = Color(0xFF6750A4),
    background       = CreamWhite,
    surface          = Color.White,
    surfaceVariant   = Color(0xFFF3EFE9),
    onBackground     = NavyDeep,
    onSurface        = Color(0xFF1A1A2E),
    error            = Color(0xFFB3261E)
)

@Composable
fun GeetaNexusTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,        // Material You on Android 12+
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val ctx = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(ctx) else dynamicLightColorScheme(ctx)
        }
        darkTheme -> DarkColorScheme
        else      -> LightColorScheme
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = Color.Transparent.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography  = GeetaNexusTypography,
        content     = content
    )
}
