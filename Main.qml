import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.LocalStorage
import "js/NotesDatabase.js" as Database
import "js/Note.js" as Note

ApplicationWindow {
    // each element should have unique id
    id: rootWindow
    minimumWidth: 360
    minimumHeight: 560
    visible: true
    title: "Note Book"

    Material.theme: Material.System
    Material.accent: Material.Blue



}
