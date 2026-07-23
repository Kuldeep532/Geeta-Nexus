package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
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
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.domain.models.ReadingPlan
import com.nexuswavetech.geetanexus.ui.viewmodel.ReadingPlanViewModel
import org.koin.androidx.compose.koinViewModel
import kotlin.math.roundToInt

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ReadingPlanScreen(
    navController: NavController,
    viewModel: ReadingPlanViewModel = koinViewModel()
) {
    val activePlan by viewModel.activePlan.collectAsState()
    val isLoading  by viewModel.isLoading.collectAsState()
    val message    by viewModel.message.collectAsState()

    message?.let { msg ->
        LaunchedEffect(msg) {
            // Show snackbar via snackbar host
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Reading Plan 📖", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "Go back" }
                    ) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        },
        snackbarHost = {
            message?.let { msg ->
                Snackbar(
                    action = {
                        TextButton(onClick = viewModel::dismissMessage) { Text("OK") }
                    }
                ) { Text(msg) }
            }
        }
    ) { padding ->
        LazyColumn(
            modifier = Modifier.fillMaxSize().padding(padding),
            contentPadding = PaddingValues(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // Active plan section
            activePlan?.let { plan ->
                item {
                    Text("Your Active Plan", style = MaterialTheme.typography.titleMedium,
                        fontWeight = FontWeight.SemiBold)
                }
                item { ActivePlanCard(plan = plan, onMarkComplete = viewModel::markDayComplete) }
                item { HorizontalDivider() }
            }

            // Templates
            item {
                Text(
                    if (activePlan == null) "Choose a Reading Plan" else "Other Plans",
                    style = MaterialTheme.typography.titleMedium, fontWeight = FontWeight.SemiBold
                )
            }

            items(viewModel.templates, key = { it.id }) { template ->
                ReadingPlanTemplateCard(
                    plan      = template,
                    isActive  = activePlan?.id == template.id,
                    onStart   = { viewModel.startPlan(it) }
                )
            }

            item { Spacer(Modifier.height(16.dp)) }
        }
    }
}

@Composable
private fun ActivePlanCard(plan: ReadingPlan, onMarkComplete: () -> Unit) {
    val pct = (plan.progressPercent * 100).roundToInt()

    Box(
        modifier = Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(24.dp))
            .background(
                Brush.linearGradient(listOf(Color(0xFF1565C0), Color(0xFF0D47A1)))
            )
            .padding(20.dp)
            .semantics { contentDescription = "Active reading plan: ${plan.title}, $pct percent complete" }
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(plan.title,
                    style = MaterialTheme.typography.titleLarge,
                    fontWeight = FontWeight.Bold, color = Color.White)
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = Color.White.copy(alpha = 0.2f)
                ) {
                    Text("Day ${plan.completedDays + 1} / ${plan.totalDays}",
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelMedium, color = Color.White)
                }
            }

            Text(plan.description, style = MaterialTheme.typography.bodySmall,
                color = Color.White.copy(alpha = 0.85f))

            // Progress bar
            Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Progress", style = MaterialTheme.typography.labelSmall, color = Color.White)
                    Text("$pct%", style = MaterialTheme.typography.labelSmall, color = Color.White)
                }
                LinearProgressIndicator(
                    progress     = { plan.progressPercent },
                    modifier     = Modifier.fillMaxWidth(),
                    color        = Color.White,
                    trackColor   = Color.White.copy(alpha = 0.3f)
                )
            }

            Button(
                onClick  = onMarkComplete,
                enabled  = !plan.isCompleted,
                colors   = ButtonDefaults.buttonColors(containerColor = Color.White),
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { contentDescription = "Mark today's reading as complete" }
            ) {
                Icon(Icons.Default.CheckCircle, contentDescription = null,
                    tint = Color(0xFF1565C0))
                Spacer(Modifier.width(8.dp))
                Text("Mark Today Complete", color = Color(0xFF1565C0), fontWeight = FontWeight.SemiBold)
            }
        }
    }
}

@Composable
private fun ReadingPlanTemplateCard(
    plan: ReadingPlan,
    isActive: Boolean,
    onStart: (ReadingPlan) -> Unit
) {
    ElevatedCard(
        shape    = RoundedCornerShape(20.dp),
        modifier = Modifier
            .fillMaxWidth()
            .semantics { contentDescription = "${plan.title}: ${plan.description}" }
    ) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(plan.title, style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.SemiBold)
                if (isActive) {
                    Surface(
                        shape = RoundedCornerShape(8.dp),
                        color = MaterialTheme.colorScheme.primaryContainer
                    ) {
                        Text("Active",
                            modifier = Modifier.padding(horizontal = 8.dp, vertical = 2.dp),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onPrimaryContainer)
                    }
                }
            }
            Text(plan.description, style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant)
            Row(
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                Icon(Icons.Default.CalendarToday, contentDescription = null,
                    tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(16.dp))
                Text("${plan.totalDays} days",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.primary)
            }
            if (!isActive) {
                Button(
                    onClick  = { onStart(plan) },
                    modifier = Modifier
                        .fillMaxWidth()
                        .semantics { contentDescription = "Start ${plan.title} reading plan" }
                ) {
                    Text("Start This Plan")
                }
            }
        }
    }
}
