package com.nexuswavetech.geetanexus.ui.screens

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
import androidx.compose.ui.semantics.*
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.navigation.NavController
import com.nexuswavetech.geetanexus.domain.models.Mood
import com.nexuswavetech.geetanexus.domain.models.VerseNote
import com.nexuswavetech.geetanexus.ui.viewmodel.NotesViewModel
import org.koin.androidx.compose.koinViewModel
import java.text.SimpleDateFormat
import java.util.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun NotesScreen(
    navController: NavController,
    viewModel: NotesViewModel = koinViewModel()
) {
    val notes      by viewModel.notes.collectAsState()
    val isLoading  by viewModel.isLoading.collectAsState()
    var showDialog by remember { mutableStateOf(false) }
    var editNote   by remember { mutableStateOf<VerseNote?>(null) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("My Notes 📝", fontWeight = FontWeight.Bold) },
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
        floatingActionButton = {
            FloatingActionButton(
                onClick = { editNote = null; showDialog = true },
                modifier = Modifier.semantics { contentDescription = "Add new note" }
            ) {
                Icon(Icons.Default.Add, contentDescription = "Add note")
            }
        }
    ) { padding ->
        if (notes.isEmpty() && !isLoading) {
            EmptyNotesState(
                modifier = Modifier.fillMaxSize().padding(padding),
                onAddNote = { showDialog = true }
            )
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxSize().padding(padding),
                contentPadding = PaddingValues(16.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                items(notes, key = { it.id }) { note ->
                    NoteCard(
                        note    = note,
                        onEdit  = { editNote = note; showDialog = true },
                        onDelete= { viewModel.deleteNote(note.id) }
                    )
                }
            }
        }
    }

    if (showDialog) {
        NoteEditorDialog(
            existingNote = editNote,
            onDismiss    = { showDialog = false; editNote = null },
            onSave       = { verseId, verseTitle, content, mood ->
                viewModel.saveNote(
                    verseId    = verseId,
                    verseTitle = verseTitle,
                    content    = content,
                    mood       = mood,
                    existingId = editNote?.id
                )
                showDialog = false
                editNote   = null
            }
        )
    }
}

@Composable
private fun NoteCard(note: VerseNote, onEdit: () -> Unit, onDelete: () -> Unit) {
    var showDelete by remember { mutableStateOf(false) }
    val dateStr = remember(note.updatedAt) {
        SimpleDateFormat("dd MMM yyyy", Locale.getDefault()).format(Date(note.updatedAt))
    }

    ElevatedCard(
        shape = RoundedCornerShape(16.dp),
        modifier = Modifier
            .fillMaxWidth()
            .semantics { contentDescription = "Note for ${note.verseTitle}: ${note.content}" }
    ) {
        Column(modifier = Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Text(note.mood.emoji, fontSize = 18.sp)
                    Text(note.verseTitle.ifBlank { "Personal note" },
                        style = MaterialTheme.typography.labelLarge,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.primary)
                }
                Row {
                    IconButton(
                        onClick = onEdit,
                        modifier = Modifier.semantics { contentDescription = "Edit note" }
                    ) {
                        Icon(Icons.Default.Edit, contentDescription = "Edit",
                            modifier = Modifier.size(18.dp))
                    }
                    IconButton(
                        onClick = { showDelete = true },
                        modifier = Modifier.semantics { contentDescription = "Delete note" }
                    ) {
                        Icon(Icons.Default.Delete, contentDescription = "Delete",
                            tint = MaterialTheme.colorScheme.error,
                            modifier = Modifier.size(18.dp))
                    }
                }
            }

            Text(note.content,
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 4,
                overflow = TextOverflow.Ellipsis)

            Text(dateStr, style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant)
        }
    }

    if (showDelete) {
        AlertDialog(
            onDismissRequest = { showDelete = false },
            title = { Text("Delete Note") },
            text  = { Text("Are you sure you want to delete this note? This cannot be undone.") },
            confirmButton = {
                TextButton(
                    onClick = { onDelete(); showDelete = false },
                    modifier = Modifier.semantics { contentDescription = "Confirm delete note" }
                ) {
                    Text("Delete", color = MaterialTheme.colorScheme.error)
                }
            },
            dismissButton = {
                TextButton(onClick = { showDelete = false }) { Text("Cancel") }
            }
        )
    }
}

@Composable
private fun EmptyNotesState(modifier: Modifier = Modifier, onAddNote: () -> Unit) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text("📝", fontSize = 60.sp,
            modifier = Modifier.semantics { contentDescription = "No notes icon" })
        Spacer(Modifier.height(16.dp))
        Text("No Notes Yet", style = MaterialTheme.typography.headlineSmall, fontWeight = FontWeight.Bold)
        Spacer(Modifier.height(8.dp))
        Text("Write reflections on verses that touched your heart.",
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant)
        Spacer(Modifier.height(24.dp))
        Button(
            onClick = onAddNote,
            modifier = Modifier.semantics { contentDescription = "Add your first note" }
        ) {
            Icon(Icons.Default.Add, contentDescription = null)
            Spacer(Modifier.width(8.dp))
            Text("Add First Note")
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun NoteEditorDialog(
    existingNote: VerseNote?,
    onDismiss: () -> Unit,
    onSave: (String, String, String, Mood) -> Unit
) {
    var verseId    by remember { mutableStateOf(existingNote?.verseId ?: "") }
    var verseTitle by remember { mutableStateOf(existingNote?.verseTitle ?: "") }
    var content    by remember { mutableStateOf(existingNote?.content ?: "") }
    var mood       by remember { mutableStateOf(existingNote?.mood ?: Mood.CONTEMPLATIVE) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(if (existingNote == null) "New Note" else "Edit Note") },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                OutlinedTextField(
                    value         = verseTitle,
                    onValueChange = { verseTitle = it; verseId = it.replace(" ", ".").lowercase() },
                    label         = { Text("Verse Reference (e.g. BG 2.47)") },
                    modifier      = Modifier.fillMaxWidth().semantics {
                        contentDescription = "Verse reference input"
                    }
                )
                OutlinedTextField(
                    value         = content,
                    onValueChange = { content = it },
                    label         = { Text("Your reflection") },
                    minLines      = 4,
                    maxLines      = 8,
                    modifier      = Modifier.fillMaxWidth().semantics {
                        contentDescription = "Note content input"
                    }
                )
                Text("Mood:", style = MaterialTheme.typography.labelMedium)
                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    Mood.entries.forEach { m ->
                        FilterChip(
                            selected = mood == m,
                            onClick  = { mood = m },
                            label    = { Text(m.emoji) },
                            modifier = Modifier.semantics { contentDescription = "${m.label} mood" }
                        )
                    }
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (content.isNotBlank()) {
                        onSave(
                            verseId.ifBlank { "general" },
                            verseTitle.ifBlank { "Personal Note" },
                            content,
                            mood
                        )
                    }
                },
                enabled = content.isNotBlank(),
                modifier = Modifier.semantics { contentDescription = "Save note" }
            ) { Text("Save") }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) { Text("Cancel") }
        }
    )
}
