import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.LocalStorage
import "../js/NotesDatabase.js" as Database
import "../js/Note.js" as Note

Item {
    id: dashboard
    anchors.fill: parent

    property var notes: []

    signal editNote(var note)
    signal addNote()

    Component.onCompleted: {
        refreshNotes()
    }

    function refreshNotes() {
        notes = Database.getAllNotes()
        console.log("Dashboard loaded", notes.length, "notes")
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 15

        // Header
        RowLayout {
            width: parent.width
            height: 50

            ColumnLayout {
                Text {
                    text: "My Notes"
                    font.pixelSize: 24
                    font.bold: true
                    color: "#333"
                }

                Text {
                    text: notes.length === 1 ? "1 note" : notes.length + " notes"
                    color: "#666"
                    font.pixelSize: 14
                }
            }

            // Row Layout Spacer
            Item { Layout.fillWidth: true; Layout.fillHeight: true } // height fill optional

            Button {
                text: "Add Note"
                highlighted: true
                anchors.verticalCenter: parent.verticalCenter

                background: Rectangle {
                    color: parent.pressed ? "#1976D2" : "#2196F3"
                    radius: 6
                }

                contentItem: Text {
                    text: parent.text
                    color: "white"
                    font.bold: true
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }

                onClicked: addNote()
            }
        }

        // Notes List
        Rectangle {
            width: parent.width
            height: parent.height - 80
            color: "transparent"

            ListView {
                id: notesListView

                width: parent.width
                height: parent.height - 80
                model: notes
                spacing: 12

                delegate: Rectangle {
                    width: notesListView.width
                    height: 100
                    color: mouseArea.containsMouse ? "#f8f9fa" : "white"
                    border.color: "#e0e0e0"
                    border.width: 1
                    radius: 8

                    // Drop shadow effect
                    Rectangle {
                        anchors.fill: parent
                        anchors.topMargin: 2
                        color: "transparent"
                        border.color: "#00000010"
                        radius: parent.radius
                        z: -1
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        anchors.rightMargin: 60
                        onClicked: editNote(modelData)

                        hoverEnabled: true
                        onEntered: parent.color = "#F5F5F5"
                        onExited: parent.color = "white"

                        cursorShape: Qt.PointingHandCursor
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 15
                        spacing: 15

                        // Note content
                        ColumnLayout {
                            anchors.left: parent.left
                            anchors.margins: 15
                            anchors.verticalCenter: parent.verticalCenter
                            width: parent.width - 45
                            spacing: 6

                            Text {
                                text: modelData.title || "Untitled"
                                font.bold: true
                                font.pixelSize: 16
                                width: parent.width
                                elide: Text.ElideRight
                                color: "#212529"
                            }

                            Text {
                                text: Note.getPreview(modelData.body, 60)
                                color: "#6c757d"
                                width: parent.width
                                elide: Text.ElideRight
                                font.pixelSize: 14
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                text: Note.formatDate(modelData.updatedAt)
                                color: "#adb5bd"
                                font.pixelSize: 10
                            }
                        }

                        // Delete Button
                        Button {
                            width: 36
                            height: 36
                            anchors.verticalCenter: parent.verticalCenter

                            background: Rectangle {
                                color: parent.hovered ? "#dc3545" : "transparent"
                                radius: 18

                                Behavior on color {
                                    ColorAnimation { duration: 200 }
                                }
                            }

                            contentItem: Text {
                                text: "×"
                                color: parent.hovered ? "white" : "#adb5bd"
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.pixelSize: 18
                                font.bold: true
                            }

                            onClicked: {
                                if (Database.deleteNote(modelData.id)) {
                                    refreshNotes()
                                }
                            }

                            ToolTip.visible: hovered
                            ToolTip.text: "Delete note"
                        }
                    }

                    // Subtle hover animation
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }

                // Empty State
                Item {
                    anchors.centerIn: parent
                    width: 250
                    height: 200
                    visible: notes.length === 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 20

                        Text {
                            text: "📝"
                            font.pixelSize: 64
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        ColumnLayout {
                            spacing: 8
                            anchors.horizontalCenter: parent.horizontalCenter

                            Text {
                                text: "No notes yet"
                                font.pixelSize: 20
                                font.bold: true
                                color: "#495057"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }

                            Text {
                                text: "Tap 'Add Note' to create your first note"
                                font.pixelSize: 14
                                color: "#6c757d"
                                anchors.horizontalCenter: parent.horizontalCenter
                            }
                        }
                    }
                } // Item End
            }
        }
    }
}
