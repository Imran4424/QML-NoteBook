// Note.js - Utility functions for note objects
.pragma library

// Creates a new note object with all required fields
function createNote(title, body) {
    return {
        id: Date.now(), // Simple ID generation using timestamp
        title: title || "",
        body: body || "",
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString()
    }
}

// Updates an existing note's content and timestamp
function updateNote(note, title, body) {
    note.title = title
    note.body = body
    note.updatedAt = new Date().toISOString()
    return note
}

// Validates that a note object has all required properties
function validateNote(note) {
    return note &&
            typeof note.id !== 'undefined' &&
            typeof note.title === 'string' &&
            typeof note.body === 'string'
}

// Formats a date string for display in the UI
function formatDate(dateString) {
    const date = new Date(dateString)
    const now = new Date()
    const diffInHours = (now - date) / (1000 * 60 * 60)

    if (diffInHours < 24) {
        // Less than a day ago - show time
        return date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'})
    } else if (diffInHours < 24 * 7) {
        // Less than a week ago - show day
        return date.toLocaleDateString([], {weekday: 'short'})
    } else {
        // Older - show date
        return date.toLocaleDateString([], {month: 'short', day: 'numeric'})
    }
}

// Gets a preview of the note body (first line, truncated)
function getPreview(body, maxLength) {
    if (!body) return "No content"

    maxLength = maxLength || 50
    const firstLine = body.split('\n')[0]

    if (firstLine.length <= maxLength) {
        return firstLine
    }

    return firstLine.substring(0, maxLength - 3) + "..."
}
