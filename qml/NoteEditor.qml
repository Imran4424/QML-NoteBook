import QtQuick
import QtQuick.Controls
import QtQuick.LocalStorage
import QtQuick.Layouts
import "../js/NotesDatabase.js" as Database

Item {
    id: noteEditor

    property var currentNote: null
    property bool isEditing: false
    property bool hasUnsavedChanges: false

    signal saveComplete()
    signal noteChanged()

    Component.onCompleted: {
        if (currentNote) {
            titleField.text = currentNote.title
            bodyField.text = currentNote.body
        }
        titleField.forceActiveFocus()
    }

    function checkForChanges() {
        if (!currentNote) {
            hasUnsavedChanges = titleField.text.trim() !== "" || bodyField.text.trim() !== ""
        } else {
            hasUnsavedChanges = titleField.text !== currentNote.title ||
                    bodyField.text !== currentNote.body
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        // Header with navigation and save
        RowLayout {
            width: parent.width
            height: 40

            Button {
                text: "← Back"
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle {
                    color: parent.pressed ? "#f8f9fa" : "transparent"
                    radius: 6
                }

                contentItem: RowLayout {
                    spacing: 5
                    anchors.centerIn: parent

                    Text {
                        text: "←"
                        color: "#495057"
                        font.pixelSize: 16
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: "Back"
                        color: "#495057"
                        font.pixelSize: 14
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    if (hasUnsavedChanges) {
                        // Auto-save before going back
                        save()
                    } else {
                        saveComplete()
                    }
                }
            }

            // Row Layout Spacer
            Item { Layout.fillWidth: true; Layout.fillHeight: true } // height fill optional

            Button {
                text: "Save"
                enabled: titleField.text.trim().length > 0
                highlighted: true
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle {
                    color: parent.enabled ?
                               (parent.pressed ? "#1976D2" : "#2196F3") : "#e9ecef"
                    radius: 6

                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                contentItem: Text {
                    text: parent.text
                    color: parent.enabled ? "white" : "#6c757d"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: save()
            }
        }

        // Title field
        TextField {
            id: titleField
            width: parent.width
            placeholderText: "Note title..."
            font.pixelSize: 22
            font.bold: true

            background: Rectangle {
                color: "transparent"
                border.color: titleField.activeFocus ? "#2196F3" : "#dee2e6"
                border.width: titleField.activeFocus ? 2 : 1
                radius: 8
            }

            leftPadding: 15
            rightPadding: 15
            topPadding: 12
            bottomPadding: 12

            onTextChanged: {
                checkForChanges()
                autoSaveTimer.restart()
            }

            Keys.onPressed: {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    bodyField.forceActiveFocus()
                    event.accepted = true
                }
            }
        }

        // Body field
        ScrollView {
            width: parent.width
            height: parent.height - 140

            TextArea {
                id: bodyField
                width: parent.width
                placeholderText: "Start writing your note here..."
                wrapMode: TextArea.Wrap
                selectByMouse: true
                font.pixelSize: 16

                background: Rectangle {
                    color: "transparent"
                    border.color: bodyField.activeFocus ? "#2196F3" : "#dee2e6"
                    border.width: bodyField.activeFocus ? 2 : 1
                    radius: 8
                }

                leftPadding: 15
                rightPadding: 15
                topPadding: 15
                bottomPadding: 15

                onTextChanged: {
                    checkForChanges()
                    autoSaveTimer.restart()
                }
            }
        }

        // Status bar
        RowLayout {
            width: parent.width
            height: 20
            spacing: 20

            Text {
                text: "Words: " + getWordCount()
                color: "#6c757d"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                text: "Characters: " + bodyField.text.length
                color: "#6c757d"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }

            // Row Layout Spacer
            Item { Layout.fillWidth: true; Layout.fillHeight: true } // height fill optional

            Text {
                text: hasUnsavedChanges ? "● Unsaved changes" : "Saved"
                color: hasUnsavedChanges ? "#ffc107" : "#28a745"
                font.pixelSize: 12
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    function getWordCount() {
        var words = bodyField.text.trim().split(/\s+/)
        return bodyField.text.trim() === "" ? 0 : words.length
    }

    function save() {
        var title = titleField.text.trim()
        var body = bodyField.text.trim()

        if (title.length === 0) {
            console.log("Cannot save: title is required")
            return false
        }

        var success = false

        if (isEditing && currentNote) {
            success = Database.updateNote(currentNote.id, title, body)
            console.log("Updated note:", currentNote.id, success ? "SUCCESS" : "FAILED")
        } else {
            var newNote = Database.createNote(title, body)
            success = newNote !== null
            console.log("Created note:", newNote ? newNote.id : "FAILED")
        }

        if (success) {
            hasUnsavedChanges = false
            noteChanged()
            saveComplete()
        } else {
            console.log("Failed to save note")
        }

        return success
    }

    // Auto-save timer
    Timer {
        id: autoSaveTimer
        interval: 3000 // 3 seconds
        repeat: false
        onTriggered: {
            if (hasUnsavedChanges && isEditing && currentNote && titleField.text.trim().length > 0) {
                console.log("Auto-saving...")
                if (Database.updateNote(currentNote.id, titleField.text.trim(), bodyField.text.trim())) {
                    hasUnsavedChanges = false
                    noteChanged()
                }
            }
        }
    }

    // Handle back button or window close
    Keys.onPressed: {
        if (event.key === Qt.Key_Back || event.key === Qt.Key_Escape) {
            if (hasUnsavedChanges) {
                save()
            } else {
                saveComplete()
            }
            event.accepted = true
        }
    }
}
