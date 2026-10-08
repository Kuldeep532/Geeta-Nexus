package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.TempleHindu
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.graphics.*
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import kotlin.math.min

private data class TempleHotspot(
    val id: String,
    val label: String,
    val description: String
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MandirScreen(navController: NavController) {
    var activeTab by remember { mutableStateOf("दर्शन") }
    var selectedAction by remember { mutableStateOf("दर्शन") }
    var bellCount by remember { mutableIntStateOf(0) }

    val tabs = listOf("दर्शन", "आरती", "थाल", "फल", "सेवा")

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("राधा कृष्ण मंदिर", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "वापस जाएँ" }
                    ) {
                        Icon(Icons.Default.ArrowBack, contentDescription = null)
                    }
                },
                actions = {
                    IconButton(
                        onClick = { bellCount++ },
                        modifier = Modifier.semantics {
                            contentDescription = "मंदिर की घंटी बजाएँ"
                        }
                    ) {
                        Icon(Icons.Default.Notifications, contentDescription = null)
                    }
                    IconButton(
                        onClick = { },
                        modifier = Modifier.semantics { contentDescription = "मंदिर सेटिंग्स" }
                    ) {
                        Icon(Icons.Default.Settings, contentDescription = null)
                    }
                }
            )
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(padding)
                .background(MaterialTheme.colorScheme.background)
        ) {
            ScrollableTabRow(
                selectedTabIndex = tabs.indexOf(activeTab),
                edgePadding = 12.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                tabs.forEach { tab ->
                    Tab(
                        selected = activeTab == tab,
                        onClick = {
                            activeTab = tab
                            selectedAction = tab
                        },
                        text = { Text(tab) }
                    )
                }
            }

            TempleCanvas(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 12.dp, vertical = 10.dp),
                selectedAction = selectedAction,
                onHotspotClick = { hotspot ->
                    when (hotspot.id) {
                        "bell" -> bellCount++
                        else -> selectedAction = hotspot.label
                    }
                }
            )

            Surface(
                tonalElevation = 2.dp,
                shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    Text(
                        selectedAction,
                        style = MaterialTheme.typography.titleLarge,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        when (selectedAction) {
                            "घंटी" -> "मंदिर की घंटी बजाकर अपनी प्रार्थना अर्पित करें। आज की घंटी: $bellCount"
                            "आरती" -> "Stage 2 में आरती के लिए यही प्रवेश बिंदु रहेगा।"
                            "थाल" -> "अपनी थाल चुनें या बाद के stage में custom थाल तैयार करें।"
                            "फल" -> "Stage 2 में फल चढ़ाने का अनुभव यहीं से खुलेगा।"
                            "सेवा" -> "मंदिर की आवश्यक सेवाएँ आगे इसी स्थान पर व्यवस्थित होंगी।"
                            else -> "मंदिर में दर्शन करें और आगे की पूजा गतिविधियों तक सरलता से पहुँचें।"
                        },
                        style = MaterialTheme.typography.bodyMedium
                    )
                    Button(
                        onClick = { },
                        modifier = Modifier
                            .fillMaxWidth()
                            .semantics {
                                contentDescription = when (selectedAction) {
                                    "दर्शन" -> "दर्शन करें"
                                    "घंटी" -> "घंटी बजाएँ"
                                    "आरती" -> "आरती अर्पित करें"
                                    "थाल" -> "थाल खोलें"
                                    "फल" -> "फल अर्पित करें"
                                    else -> "सेवा खोलें"
                                }
                            }
                    ) {
                        Text(
                            when (selectedAction) {
                                "दर्शन" -> "दर्शन करें"
                                "घंटी" -> "घंटी बजाएँ"
                                "आरती" -> "आरती अर्पित करें"
                                "थाल" -> "थाल खोलें"
                                "फल" -> "फल अर्पित करें"
                                else -> "सेवा खोलें"
                            }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun TempleCanvas(
    modifier: Modifier,
    selectedAction: String,
    onHotspotClick: (TempleHotspot) -> Unit
) {
    val scrollState = rememberScrollState()

    Box(
        modifier = modifier
            .clip(RoundedCornerShape(28.dp))
            .background(
                Brush.verticalGradient(
                    listOf(
                        Color(0xFF07111F),
                        Color(0xFF132A43),
                        Color(0xFF5A3A20)
                    )
                )
            )
            .horizontalScroll(scrollState)
    ) {
        Canvas(
            modifier = Modifier
                .width(760.dp)
                .fillMaxHeight()
                .pointerInput(Unit) {
                    detectTapGestures { tap ->
                        val hotspots = templeHotspots()
                        val hit = hotspots.firstOrNull { hs ->
                            hotspotRect(hs.id, size.width, size.height).contains(tap)
                        }
                        if (hit != null) onHotspotClick(hit)
                    }
                }
                .semantics {
                    contentDescription =
                        "राधा कृष्ण मंदिर का interactive दृश्य। यहाँ दर्शन, घंटी, आरती और आगे की पूजा गतिविधियों के स्थान हैं।"
                }
        ) {
            drawTempleScene(selectedAction)
        }
    }
}

private fun templeHotspots(): List<TempleHotspot> = listOf(
    TempleHotspot("deity", "दर्शन", "राधा कृष्ण के दर्शन"),
    TempleHotspot("bell", "घंटी", "मंदिर की घंटी"),
    TempleHotspot("altar", "आरती", "आरती का स्थान"),
    TempleHotspot("thali", "थाल", "पूजा थाल"),
    TempleHotspot("fruit", "फल", "फल अर्पण")
)

private fun hotspotRect(id: String, width: Float, height: Float): Rect {
    return when (id) {
        "deity" -> Rect(width * .36f, height * .27f, width * .64f, height * .60f)
        "bell" -> Rect(width * .77f, height * .10f, width * .93f, height * .34f)
        "altar" -> Rect(width * .34f, height * .58f, width * .66f, height * .82f)
        "thali" -> Rect(width * .08f, height * .70f, width * .30f, height * .92f)
        else -> Rect(width * .70f, height * .68f, width * .93f, height * .92f)
    }
}

private fun DrawScope.drawTempleScene(selectedAction: String) {
    val w = size.width
    val h = size.height
    val scale = min(w / 760f, h / 560f).coerceAtLeast(.6f)

    fun s(v: Float) = v * scale

    // Floor
    drawRect(
        brush = Brush.verticalGradient(
            listOf(Color(0xFF9A673E), Color(0xFF4B2D1D))
        ),
        topLeft = Offset(0f, h * .61f),
        size = Size(w, h * .39f)
    )

    // Temple arch
    val arch = Path().apply {
        moveTo(s(90f), h * .60f)
        lineTo(s(90f), h * .28f)
        quadraticBezierTo(s(380f), h * .02f, s(670f), h * .28f)
        lineTo(s(670f), h * .60f)
        close()
    }
    drawPath(
        arch,
        brush = Brush.verticalGradient(
            listOf(Color(0xFFE7C07B), Color(0xFF8C5A2B))
        )
    )

    // Dome
    drawOval(
        brush = Brush.verticalGradient(
            listOf(Color(0xFFFFD98E), Color(0xFFA36B2C))
        ),
        topLeft = Offset(w * .33f, h * .05f),
        size = Size(w * .34f, h * .27f)
    )

    // Pillars
    listOf(.16f, .29f, .71f, .84f).forEach { x ->
        drawRoundRect(
            brush = Brush.horizontalGradient(
                listOf(Color(0xFFB97838), Color(0xFFE0B56A), Color(0xFF8E5726))
            ),
            topLeft = Offset(w * x, h * .30f),
            size = Size(w * .08f, h * .36f),
            cornerRadius = androidx.compose.ui.geometry.CornerRadius(s(14f))
        )
    }

    // Sanctum inner wall
    drawRoundRect(
        color = Color(0xFF25160F),
        topLeft = Offset(w * .29f, h * .25f),
        size = Size(w * .42f, h * .39f),
        cornerRadius = androidx.compose.ui.geometry.CornerRadius(s(22f))
    )

    // Back glow
    drawCircle(
        brush = Brush.radialGradient(
            listOf(Color(0xFFFFE7A8), Color(0x00FFE7A8))
        ),
        radius = w * .18f,
        center = Offset(w * .50f, h * .43f)
    )

    // Simple Radha-Krishna symbolic figures
    drawCircle(
        color = Color(0xFFF4C38E),
        radius = w * .045f,
        center = Offset(w * .46f, h * .40f)
    )
    drawCircle(
        color = Color(0xFF6D90D9),
        radius = w * .045f,
        center = Offset(w * .54f, h * .40f)
    )

    drawRoundRect(
        color = Color(0xFFE0A03A),
        topLeft = Offset(w * .42f, h * .45f),
        size = Size(w * .16f, h * .13f),
        cornerRadius = androidx.compose.ui.geometry.CornerRadius(s(16f))
    )

    // Bell
    drawCircle(
        color = Color(0xFFFFD369),
        radius = w * .055f,
        center = Offset(w * .85f, h * .22f)
    )
    drawLine(
        color = Color(0xFFD0A23E),
        start = Offset(w * .85f, h * .08f),
        end = Offset(w * .85f, h * .18f),
        strokeWidth = s(7f)
    )
    drawCircle(
        color = Color(0xFFB98222),
        radius = w * .012f,
        center = Offset(w * .85f, h * .25f)
    )

    // Altar / diya area
    drawRoundRect(
        color = Color(0xFF6C3F1D),
        topLeft = Offset(w * .34f, h * .57f),
        size = Size(w * .32f, h * .16f),
        cornerRadius = androidx.compose.ui.geometry.CornerRadius(s(18f))
    )
    repeat(5) { i ->
        val cx = w * (.39f + i * .055f)
        drawCircle(
            color = Color(0xFFFFC857),
            radius = w * .012f,
            center = Offset(cx, h * .62f)
        )
        drawCircle(
            color = Color(0xFFFF8A00),
            radius = w * .006f,
            center = Offset(cx, h * .60f)
        )
    }

    // Puja thali
    drawCircle(
        brush = Brush.radialGradient(listOf(Color(0xFFE8B85C), Color(0xFF88551F))),
        radius = w * .075f,
        center = Offset(w * .19f, h * .79f)
    )

    // Fruit plate
    drawCircle(
        color = Color(0xFFC7842F),
        radius = w * .075f,
        center = Offset(w * .80f, h * .79f)
    )
    listOf(
        Offset(w * .77f, h * .76f),
        Offset(w * .83f, h * .77f),
        Offset(w * .79f, h * .83f)
    ).forEach {
        drawCircle(Color(0xFFDBA629), radius = w * .019f, center = it)
    }

    // Selected-action highlight
    val highlight = when (selectedAction) {
        "घंटी" -> hotspotRect("bell", w, h)
        "आरती" -> hotspotRect("altar", w, h)
        "थाल" -> hotspotRect("thali", w, h)
        "फल" -> hotspotRect("fruit", w, h)
        else -> hotspotRect("deity", w, h)
    }
    drawRoundRect(
        color = Color(0xFFFFD54F).copy(alpha = .28f),
        topLeft = highlight.topLeft,
        size = highlight.size,
        cornerRadius = androidx.compose.ui.geometry.CornerRadius(s(18f)),
        style = Stroke(width = s(4f))
    )
}
