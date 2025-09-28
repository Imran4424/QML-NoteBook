// NotesDatabase.js - LocalStorage database operations
.pragma library

Qt.include("Note.js")

// Database configuration
var DATABASE_NAME = "NotesAppDB"
var DATABASE_VERSION = "1.0"
var DATABASE_DESCRIPTION = "Notes Application Database"
var DATABASE_SIZE = 1000000 * 100 // 100MB

// Get or create the database connection
function getDatabase() {
    return LocalStorage.openDatabaseSync(
                DATABASE_NAME,
                DATABASE_VERSION,
                DATABASE_DESCRIPTION,
                DATABASE_SIZE
                )
}

// Initialize the database and create tables
function initializeDatabase() {
    console.log("Initializing Notes Database...")

    var db = getDatabase()

    db.transaction(function(tx) {
        // Create notes table if it doesn't exist
        tx.executeSql(
                    'CREATE TABLE IF NOT EXISTS notes (' +
                    'id INTEGER PRIMARY KEY, ' +
                    'title TEXT NOT NULL, ' +
                    'body TEXT, ' +
                    'created_at TEXT, ' +
                    'updated_at TEXT)'
                    )
        console.log("Notes table created/verified")
    })
}

// Get all notes, ordered by most recently updated
function getAllNotes() {
    var notes = []
    var db = getDatabase()

    try {
        db.readTransaction(function(tx) {
            var result = tx.executeSql(
                        'SELECT * FROM notes ORDER BY updated_at DESC'
                        )

            console.log("Found", result.rows.length, "notes")

            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i)
                notes.push({
                               id: row.id,
                               title: row.title,
                               body: row.body,
                               createdAt: row.created_at,
                               updatedAt: row.updated_at
                           })
            }
        })
    } catch (error) {
        console.log("Error loading notes:", error.message)
    }

    return notes
}

// Create a new note
function createNote(title, body) {
    if (!title || title.trim().length === 0) {
        console.log("Cannot create note: title is required")
        return null
    }

    var note = Note.createNote(title.trim(), body.trim())
    var db = getDatabase()
    var success = false

    try {
        db.transaction(function(tx) {
            tx.executeSql(
                        'INSERT INTO notes (id, title, body, created_at, updated_at) VALUES (?, ?, ?, ?, ?)',
                        [note.id, note.title, note.body, note.createdAt, note.updatedAt]
                        )
            success = true
            console.log("Created note with ID:", note.id)
        })
    } catch (error) {
        console.log("Error creating note:", error.message)
        return null
    }

    return success ? note : null
}

// Update an existing note
function updateNote(id, title, body) {
    if (!title || title.trim().length === 0) {
        console.log("Cannot update note: title is required")
        return false
    }

    var db = getDatabase()
    var success = false
    var updatedAt = new Date().toISOString()

    try {
        db.transaction(function(tx) {
            var result = tx.executeSql(
                        'UPDATE notes SET title = ?, body = ?, updated_at = ? WHERE id = ?',
                        [title.trim(), body.trim(), updatedAt, id]
                        )
            success = result.rowsAffected > 0

            if (success) {
                console.log("Updated note ID:", id)
            } else {
                console.log("Note not found for update:", id)
            }
        })
    } catch (error) {
        console.log("Error updating note:", error.message)
    }

    return success
}

// Delete a note
function deleteNote(id) {
    var db = getDatabase()
    var success = false

    try {
        db.transaction(function(tx) {
            var result = tx.executeSql(
                        'DELETE FROM notes WHERE id = ?',
                        [id]
                        )
            success = result.rowsAffected > 0

            if (success) {
                console.log("Deleted note ID:", id)
            } else {
                console.log("Note not found for deletion:", id)
            }
        })
    } catch (error) {
        console.log("Error deleting note:", error.message)
    }

    return success
}

// Get a specific note by ID
function getNoteById(id) {
    var note = null
    var db = getDatabase()

    try {
        db.readTransaction(function(tx) {
            var result = tx.executeSql(
                        'SELECT * FROM notes WHERE id = ?',
                        [id]
                        )

            if (result.rows.length > 0) {
                var row = result.rows.item(0)
                note = {
                    id: row.id,
                    title: row.title,
                    body: row.body,
                    createdAt: row.created_at,
                    updatedAt: row.updated_at
                }
                console.log("Found note:", note.title)
            }
        })
    } catch (error) {
        console.log("Error finding note:", error.message)
    }

    return note
}

// Search notes by title or body content
function searchNotes(searchTerm) {
    var notes = []
    var db = getDatabase()

    if (!searchTerm || searchTerm.trim().length === 0) {
        return getAllNotes()
    }

    try {
        db.readTransaction(function(tx) {
            var result = tx.executeSql(
                        'SELECT * FROM notes WHERE title LIKE ? OR body LIKE ? ORDER BY updated_at DESC',
                        ['%' + searchTerm + '%', '%' + searchTerm + '%']
                        )

            console.log("Search found", result.rows.length, "notes for:", searchTerm)

            for (var i = 0; i < result.rows.length; i++) {
                var row = result.rows.item(i)
                notes.push({
                               id: row.id,
                               title: row.title,
                               body: row.body,
                               createdAt: row.created_at,
                               updatedAt: row.updated_at
                           })
            }
        })
    } catch (error) {
        console.log("Error searching notes:", error.message)
    }

    return notes
}

// Get total count of notes
function getNotesCount() {
    var count = 0
    var db = getDatabase()

    try {
        db.readTransaction(function(tx) {
            var result = tx.executeSql('SELECT COUNT(*) as count FROM notes')
            if (result.rows.length > 0) {
                count = result.rows.item(0).count
            }
        })
    } catch (error) {
        console.log("Error getting notes count:", error.message)
    }

    return count
}

// Clear all notes (useful for testing)
function clearAllNotes() {
    var db = getDatabase()
    var success = false

    try {
        db.transaction(function(tx) {
            tx.executeSql('DELETE FROM notes')
            success = true
            console.log("All notes cleared")
        })
    } catch (error) {
        console.log("Error clearing notes:", error.message)
    }

    return success
}
