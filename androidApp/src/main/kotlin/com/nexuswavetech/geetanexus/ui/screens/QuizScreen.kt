package com.nexuswavetech.geetanexus.ui.screens

import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
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
import com.nexuswavetech.geetanexus.domain.models.*
import com.nexuswavetech.geetanexus.ui.viewmodel.QuizViewModel
import org.koin.androidx.compose.koinViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuizScreen(
    navController: NavController,
    viewModel: QuizViewModel = koinViewModel()
) {
    val session   by viewModel.session.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Spiritual Quiz 🧠", fontWeight = FontWeight.Bold) },
                navigationIcon = {
                    IconButton(
                        onClick = { navController.popBackStack() },
                        modifier = Modifier.semantics { contentDescription = "Go back" }
                    ) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { padding ->
        Box(modifier = Modifier.fillMaxSize().padding(padding)) {
            when {
                isLoading -> {
                    CircularProgressIndicator(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .semantics { contentDescription = "Loading quiz questions" }
                    )
                }
                session == null -> QuizCategorySelector(viewModel = viewModel)
                session!!.isComplete -> QuizResultScreen(
                    session   = session!!,
                    onRestart = viewModel::resetQuiz
                )
                else -> QuizQuestionScreen(
                    session  = session!!,
                    onAnswer = viewModel::answerQuestion
                )
            }
        }
    }
}

@Composable
private fun QuizCategorySelector(viewModel: QuizViewModel) {
    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text("Choose a Category",
            style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        Text("Test your spiritual knowledge across different topics.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant)

        // "All Categories" button
        ElevatedCard(
            onClick = { viewModel.startQuiz(null, 10) },
            modifier = Modifier
                .fillMaxWidth()
                .semantics { contentDescription = "Start quiz with all categories, 10 questions" }
        ) {
            Row(
                modifier = Modifier.padding(20.dp),
                verticalAlignment = Alignment.CenterVertically,
                horizontalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Text("📚", fontSize = 32.sp)
                Column(modifier = Modifier.weight(1f)) {
                    Text("All Topics", fontWeight = FontWeight.Bold,
                        style = MaterialTheme.typography.titleMedium)
                    Text("10 mixed questions", style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                Icon(Icons.Default.ChevronRight, contentDescription = null)
            }
        }

        Text("By Category", style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(top = 4.dp))

        LazyVerticalGrid(
            columns = GridCells.Fixed(2),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(viewModel.categories) { category ->
                ElevatedCard(
                    onClick = { viewModel.startQuiz(category, 5) },
                    modifier = Modifier.semantics {
                        contentDescription = "${category.displayName} quiz, 5 questions"
                    }
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(category.emoji, fontSize = 28.sp)
                        Text(category.displayName,
                            style = MaterialTheme.typography.labelMedium,
                            fontWeight = FontWeight.SemiBold,
                            textAlign = TextAlign.Center)
                        Text("5 Questions", style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }
    }
}

@Composable
private fun QuizQuestionScreen(
    session: QuizSession,
    onAnswer: (String, Int) -> Unit
) {
    val question = session.questions.getOrNull(session.currentIndex) ?: return
    val answered = session.answers[question.id]

    Column(
        modifier = Modifier.fillMaxSize().padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        // Progress
        val progress = (session.currentIndex + 1).toFloat() / session.totalQuestions
        Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text("Question ${session.currentIndex + 1} of ${session.totalQuestions}",
                    style = MaterialTheme.typography.labelMedium)
                Text("${(progress * 100).toInt()}%",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.primary)
            }
            LinearProgressIndicator(
                progress = { progress },
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics { contentDescription = "Quiz progress: ${(progress * 100).toInt()} percent" }
            )
        }

        // Question card
        ElevatedCard(shape = RoundedCornerShape(20.dp)) {
            Column(modifier = Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                question.verseRef?.let { ref ->
                    Surface(
                        shape  = RoundedCornerShape(8.dp),
                        color  = MaterialTheme.colorScheme.primaryContainer
                    ) {
                        Text(ref,
                            modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp),
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onPrimaryContainer)
                    }
                }
                Text(question.question,
                    style = MaterialTheme.typography.bodyLarge, fontWeight = FontWeight.Medium,
                    lineHeight = 24.sp)
            }
        }

        // Options
        question.options.forEachIndexed { index, option ->
            val isSelected  = answered == index
            val isCorrect   = question.correctIndex == index
            val showResult  = answered != null

            val containerColor = when {
                showResult && isCorrect  -> Color(0xFF4CAF50).copy(alpha = 0.15f)
                showResult && isSelected -> MaterialTheme.colorScheme.errorContainer
                isSelected               -> MaterialTheme.colorScheme.primaryContainer
                else                     -> MaterialTheme.colorScheme.surface
            }

            Card(
                onClick = { if (answered == null) onAnswer(question.id, index) },
                enabled = answered == null,
                colors  = CardDefaults.cardColors(containerColor = containerColor),
                border  = if (isSelected || (showResult && isCorrect))
                    CardDefaults.outlinedCardBorder() else null,
                modifier = Modifier
                    .fillMaxWidth()
                    .semantics {
                        contentDescription = "Option ${index + 1}: $option" +
                            if (showResult && isCorrect) ", correct answer" else ""
                    }
            ) {
                Row(
                    modifier = Modifier.padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    Surface(
                        shape = androidx.compose.foundation.shape.CircleShape,
                        color = if (showResult && isCorrect) Color(0xFF4CAF50)
                                else if (showResult && isSelected) MaterialTheme.colorScheme.error
                                else MaterialTheme.colorScheme.primaryContainer,
                        modifier = Modifier.size(32.dp)
                    ) {
                        Box(contentAlignment = Alignment.Center) {
                            Text(
                                text = if (showResult && isCorrect) "✓"
                                       else if (showResult && isSelected) "✗"
                                       else ('A' + index).toString(),
                                style = MaterialTheme.typography.labelMedium,
                                fontWeight = FontWeight.Bold,
                                color = if (showResult && (isCorrect || isSelected)) Color.White
                                        else MaterialTheme.colorScheme.onPrimaryContainer
                            )
                        }
                    }
                    Text(option, style = MaterialTheme.typography.bodyMedium,
                        modifier = Modifier.weight(1f))
                }
            }
        }

        // Explanation (after answer)
        if (answered != null) {
            Card(
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.secondaryContainer
                ),
                shape = RoundedCornerShape(16.dp)
            ) {
                Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Text("💡 Explanation", style = MaterialTheme.typography.labelLarge,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.onSecondaryContainer)
                    Text(question.explanation,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSecondaryContainer)
                }
            }
        }
    }
}

@Composable
private fun QuizResultScreen(session: QuizSession, onRestart: () -> Unit) {
    val pct = (session.scorePercent * 100).toInt()
    val emoji = when {
        pct >= 90 -> "🏆"
        pct >= 70 -> "⭐"
        pct >= 50 -> "👍"
        else      -> "📚"
    }
    val message = when {
        pct >= 90 -> "Outstanding! You are a true Gita scholar!"
        pct >= 70 -> "Well done! Your spiritual knowledge is strong."
        pct >= 50 -> "Good effort! Keep reading and practicing."
        else      -> "Keep studying! Every question is a learning opportunity. 🙏"
    }

    Column(
        modifier = Modifier.fillMaxSize().padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(emoji, fontSize = 72.sp,
            modifier = Modifier.semantics { contentDescription = "Result icon" })
        Spacer(Modifier.height(16.dp))
        Text("Quiz Complete!", style = MaterialTheme.typography.headlineMedium,
            fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(8.dp))
        Text("${session.score} / ${session.totalQuestions}",
            style = MaterialTheme.typography.displayMedium,
            fontWeight = FontWeight.Bold,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.semantics {
                contentDescription = "Score: ${session.score} out of ${session.totalQuestions}"
            })
        Text("$pct% correct", style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(16.dp))
        Card(
            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer),
            shape = RoundedCornerShape(16.dp)
        ) {
            Text(message, modifier = Modifier.padding(16.dp),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer,
                textAlign = TextAlign.Center)
        }
        Spacer(Modifier.height(32.dp))
        Button(
            onClick = onRestart,
            modifier = Modifier
                .fillMaxWidth()
                .semantics { contentDescription = "Play quiz again" }
        ) {
            Icon(Icons.Default.Refresh, contentDescription = null)
            Spacer(Modifier.width(8.dp))
            Text("Play Again")
        }
    }
}
