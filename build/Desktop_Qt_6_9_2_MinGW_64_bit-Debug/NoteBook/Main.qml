import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

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
