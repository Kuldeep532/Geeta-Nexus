package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.gestures.detectDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material3.*
import androidx.compose.runtime.*
import kotlinx.coroutines.isActive
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.BuildConfig
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.postgrest.Postgrest
import io.github.sceneview.SceneView
import io.github.sceneview.rememberEngine
import io.github.sceneview.rememberModelLoader
import io.github.sceneview.rememberCameraManipulator
import io.github.sceneview.createModelNode
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.delay
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import java.time.LocalTime
import java.time.ZoneId

private val mandirSupabase by lazy {
    createSupabaseClient(
        supabaseUrl = BuildConfig.SUPABASE_URL,
        supabaseKey = BuildConfig.SUPABASE_PUBLISHABLE_KEY
    ) { install(Postgrest) }
}

@Serializable
private data class AartiSchedule(
    val id: String,
    val title: String,
    val description: String? = null,
    val start_time: String,
    val duration_minutes: Int = 30,
    val enabled: Boolean = true
)

private data class DarshanActivity(val text: String)

private data class ThaliState(
    val diya: Boolean = true,
    val flowers: Boolean = true,
    val rice: Boolean = true,
    val kumkum: Boolean = true,
    val incense: Boolean = false
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MandirScreen(navController: NavController) {
    var activeTab by remember { mutableIntStateOf(0) }
    var showCustomThali by remember { mutableStateOf(false) }
    var thaliState by remember { mutableStateOf(ThaliState()) }
    var showPurityNotice by remember { mutableStateOf(true) }
    if (showPurityNotice) {
        AlertDialog(
            onDismissRequest = { },
            title = { Text("A Note Before Entering the Mandir", fontWeight = FontWeight.Bold) },
            text = {
                Text(
                    "This digital mandir is intended to be approached with the same reverence as a physical place of worship. Please use this feature after bathing and when you are clean and prepared for prayer."
                )
            },
            confirmButton = {
                Button(
                    onClick = { showPurityNotice = false },
                    modifier = Modifier.semantics {
                        contentDescription = "I understand and wish to enter the mandir"
                    }
                ) {
                    Text("I Understand")
                }
            },
            dismissButton = {
                TextButton(
                    onClick = { navController.popBackStack() },
                    modifier = Modifier.semantics {
                        contentDescription = "Leave the mandir"
                    }
                ) {
                    Text("Leave")
                }
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("राधा कृष्ण मंदिर", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "वापस जाएँ" }
                    ) { Icon(Icons.Default.ArrowBack, contentDescription = null) }
                },
                actions = {
                    IconButton(
                        onClick = { },
                        modifier = Modifier.semantics { contentDescription = "मंदिर की घंटी बजाएँ" }
                    ) { Icon(Icons.Default.Notifications, contentDescription = null) }
                }
            )
        }
    ) { padding ->
        Column(Modifier.fillMaxSize().padding(padding)) {
            TabRow(selectedTabIndex = activeTab) {
                Tab(selected = activeTab == 0, onClick = { activeTab = 0 }, text = { Text("दर्शन") })
                Tab(selected = activeTab == 1, onClick = { activeTab = 1 }, text = { Text("आरती") })
                Tab(selected = activeTab == 2, onClick = { activeTab = 2 }, text = { Text("पूजा सेवा") })
            }
            when (activeTab) {
                0 -> DarshanTab(Modifier.fillMaxSize())
                1 -> AartiTab(Modifier.fillMaxSize())
                2 -> PujaSevaTab(
                    modifier = Modifier.fillMaxSize(),
                    thaliState = thaliState,
                    onCustomizeThali = { showCustomThali = true }
                )
            }
        }
    }
}

@Composable
private fun DarshanTab(modifier: Modifier) {
    val engine = rememberEngine()
    val modelLoader = rememberModelLoader(engine)
    val cameraManipulator = rememberCameraManipulator()
    val activity = remember {
        listOf(
            DarshanActivity("आज के दर्शन"),
            DarshanActivity("आज की पूजा और अर्पण की जानकारी"),
            DarshanActivity("मंदिर की आज की प्रमुख गतिविधियाँ")
        )
    }

    Column(modifier) {
        Box(Modifier.fillMaxWidth().weight(1f)) {
            SceneView(
                modifier = Modifier.fillMaxSize(),
                engine = engine,
                modelLoader = modelLoader,
                cameraManipulator = cameraManipulator
            ) {
                createModelNode(
                    modelLoader = modelLoader,
                    glbFileLocation = "models/radha_krishna_mandir.glb"
                )?.let { addChildNode(it) }
            }
        }
        Text(
            "आज की मंदिर गतिविधियाँ",
            style = MaterialTheme.typography.titleLarge,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 10.dp)
        )
        LazyColumn(
            modifier = Modifier.fillMaxWidth().heightIn(max = 220.dp),
            contentPadding = PaddingValues(horizontal = 16.dp, vertical = 4.dp),
            verticalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            items(activity) { item ->
                ElevatedCard(Modifier.fillMaxWidth()) {
                    Text(item.text, Modifier.padding(14.dp), style = MaterialTheme.typography.bodyLarge)
                }
            }
        }
    }
}

@Composable
private fun PujaSevaTab(
    modifier: Modifier,
    thaliState: ThaliState,
    onCustomizeThali: () -> Unit
) {
    Column(
        modifier.padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        Text(
            "पूजा सेवा",
            style = MaterialTheme.typography.headlineSmall,
            fontWeight = FontWeight.Bold
        )
        Text(
            "यहाँ अपनी पूजा थाल को देखिए, घुमाइए और सामग्री चुनिए।",
            style = MaterialTheme.typography.bodyLarge
        )
        RotatingThali3D(
            state = thaliState,
            modifier = Modifier
                .fillMaxWidth()
                .weight(1f)
        )
        Button(
            onClick = onCustomizeThali,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("कस्टम थाल")
        }
    }
}

@Composable
private fun RotatingThali3D(
    state: ThaliState,
    modifier: Modifier
) {
    var rotation by remember { mutableFloatStateOf(0f) }
    var autoRotate by remember { mutableStateOf(false) }

    LaunchedEffect(autoRotate) {
        while (autoRotate && isActive) {
            rotation += 1.2f
            delay(16)
        }
    }

    Box(
        modifier = modifier
            .pointerInput(Unit) {
                detectDragGestures { _, dragAmount ->
                    rotation += dragAmount.x * 0.8f
                }
            }
            .pointerInput(Unit) {
                detectTapGestures(
                    onPress = {
                        autoRotate = true
                        tryAwaitRelease()
                    }
                )
            }
            .graphicsLayer {
                rotationY = rotation
                rotationZ = rotation * 0.04f
                cameraDistance = 18f * density
            }
            .semantics {
                contentDescription = "3D पूजा थाल, उंगली रखकर घुमाएँ"
            },
        contentAlignment = Alignment.Center
    ) {
        Surface(
            modifier = Modifier.size(250.dp),
            shape = MaterialTheme.shapes.extraLarge,
            tonalElevation = 10.dp
        ) {
            Column(
                modifier = Modifier.fillMaxSize().padding(20.dp),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                Text("पूजा थाल", style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.Bold)
                Spacer(Modifier.height(10.dp))
                if (state.diya) Text("दीप")
                if (state.flowers) Text("पुष्प")
                if (state.rice) Text("अक्षत")
                if (state.kumkum) Text("कुमकुम")
                if (state.incense) Text("धूप")
            }
        }
    }
}

@Composable
private fun AartiTab(modifier: Modifier) {
    var schedule by remember { mutableStateOf<List<AartiSchedule>>(emptyList()) }
    var loading by remember { mutableStateOf(true) }
    var message by remember { mutableStateOf<String?>(null) }
    var now by remember { mutableStateOf(LocalTime.now(ZoneId.of("Asia/Kolkata"))) }

    LaunchedEffect(Unit) {
        try {
            schedule = withContext(Dispatchers.IO) {
                mandirSupabase.from("mandir_aarti_schedules").select().decodeList<AartiSchedule>()
                    .filter { it.enabled }.sortedBy { it.start_time }
            }
        } catch (_: Exception) {
            message = "आरती का समय अभी उपलब्ध नहीं है। कृपया थोड़ी देर बाद फिर देखें।"
        } finally { loading = false }
    }
    LaunchedEffect(Unit) {
        while (true) { now = LocalTime.now(ZoneId.of("Asia/Kolkata")); delay(30000) }
    }
    Column(modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(12.dp)) {
        Text("आज की आरती", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        when {
            loading -> { LinearProgressIndicator(Modifier.fillMaxWidth()); Text("आरती का समय देखा जा रहा है।") }
            message != null -> Text(message!!, style = MaterialTheme.typography.bodyLarge)
            schedule.isEmpty() -> Text("अभी आरती का समय उपलब्ध नहीं है।", style = MaterialTheme.typography.bodyLarge)
            else -> schedule.forEach { item ->
                val start = runCatching { LocalTime.parse(item.start_time) }.getOrNull()
                val end = start?.plusMinutes(item.duration_minutes.toLong())
                val live = start != null && end != null && now >= start && now < end
                ElevatedCard(Modifier.fillMaxWidth().semantics { contentDescription = if (live) "${item.title}, आरती अभी चल रही है" else "${item.title}, समय ${item.start_time}" }) {
                    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        Text(item.title, style = MaterialTheme.typography.titleLarge, fontWeight = FontWeight.SemiBold)
                        Text(if (live) "अभी आरती चल रही है" else "समय: ${item.start_time}", style = MaterialTheme.typography.bodyLarge)
                        item.description?.let { Text(it, style = MaterialTheme.typography.bodyMedium) }
                    }
                }
            }
        }
    }
}

@Composable
private fun ReadyMadeThaliCard(
    state: ThaliState,
    onCustomize: () -> Unit
) {
    var rotation by remember { mutableFloatStateOf(0f) }

    ElevatedCard(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .semantics { contentDescription = "तैयार पूजा थाल" }
    ) {
        Column(
            Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(
                "तैयार पूजा थाल",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            Text(
                "मंदिर में पहले से सजी हुई बेसिक पूजा थाल।",
                style = MaterialTheme.typography.bodyMedium
            )

            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(190.dp)
                    .pointerInput(Unit) {
                        detectDragGestures { _, dragAmount ->
                            rotation += dragAmount.x * 0.7f
                        }
                    }
                    .graphicsLayer {
                        rotationY = rotation
                        rotationZ = rotation * 0.08f
                        cameraDistance = 12f * density
                    }
                    .semantics { contentDescription = "थाल को उंगली से घुमाएँ" },
                contentAlignment = Alignment.Center
            ) {
                Surface(
                    modifier = Modifier.size(160.dp),
                    shape = MaterialTheme.shapes.extraLarge,
                    tonalElevation = 8.dp
                ) {
                    Column(
                        modifier = Modifier.fillMaxSize().padding(14.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.Center
                    ) {
                        Text(
                            "पूजा थाल",
                            style = MaterialTheme.typography.titleMedium,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(Modifier.height(8.dp))
                        if (state.diya) Text("दीप", style = MaterialTheme.typography.bodySmall)
                        if (state.flowers) Text("फूल", style = MaterialTheme.typography.bodySmall)
                        if (state.rice) Text("अक्षत", style = MaterialTheme.typography.bodySmall)
                        if (state.kumkum) Text("कुमकुम", style = MaterialTheme.typography.bodySmall)
                        if (state.incense) Text("धूप", style = MaterialTheme.typography.bodySmall)
                    }
                }
            }

            Text(
                "सामग्री: " + listOfNotNull(
                    if (state.diya) "दीप" else null,
                    if (state.flowers) "फूल" else null,
                    if (state.rice) "अक्षत" else null,
                    if (state.kumkum) "कुमकुम" else null,
                    if (state.incense) "धूप" else null
                ).joinToString(" • ").ifBlank { "कोई सामग्री नहीं चुनी गई" },
                style = MaterialTheme.typography.bodyMedium
            )

            Button(
                onClick = onCustomize,
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("कस्टम थाल")
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun CustomThaliSheet(
    state: ThaliState,
    onStateChanged: (ThaliState) -> Unit,
    onDismiss: () -> Unit
) {
    var draft by remember(state) { mutableStateOf(state) }

    ModalBottomSheet(onDismissRequest = onDismiss) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            Text(
                "कस्टम थाल",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )
            Text("जिस सामग्री से पूजा करना चाहते हैं, उसे चुनें।")

            ThaliOptionRow("दीप", draft.diya) {
                draft = draft.copy(diya = it)
            }
            ThaliOptionRow("पुष्प", draft.flowers) {
                draft = draft.copy(flowers = it)
            }
            ThaliOptionRow("अक्षत", draft.rice) {
                draft = draft.copy(rice = it)
            }
            ThaliOptionRow("कुमकुम", draft.kumkum) {
                draft = draft.copy(kumkum = it)
            }
            ThaliOptionRow("धूप", draft.incense) {
                draft = draft.copy(incense = it)
            }

            Button(
                onClick = {
                    onStateChanged(draft)
                    onDismiss()
                },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text("थाल तैयार करें")
            }
        }
    }
}

@Composable
private fun ThaliOptionRow(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit
) {
    Row(
        Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label)
        Switch(
            checked = checked,
            onCheckedChange = onCheckedChange,
            modifier = Modifier.semantics { contentDescription = label }
        )
    }
}
