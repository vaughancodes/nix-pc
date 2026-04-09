import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Qt.labs.folderlistmodel
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Window {
    id: docMenu

    property string folderUrl: ""
    property var rootCallback: null
    property var parentMenu: null
    property var childMenu: null
    property int activeChildRow: -1

    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    width: 260
    height: Math.min(docListView.contentHeight + 6, 500)

    function openNextTo(item) {
        if (item) {
            const pos = item.mapToGlobal(item.width, 0)
            x = pos.x
            y = pos.y
            visible = true
        }
    }

    function closeAll() {
        if (childMenu) {
            childMenu.closeAll()
            childMenu.destroy()
            childMenu = null
            activeChildRow = -1
        }
        visible = false
    }

    function closeChild() {
        if (childMenu) {
            childMenu.closeAll()
            childMenu.destroy()
            childMenu = null
            activeChildRow = -1
        }
    }

    FolderListModel {
        id: folderModel
        folder: docMenu.folderUrl
        showDirs: true
        showDirsFirst: true
        showDotAndDotDot: false
        showHidden: false
        sortField: FolderListModel.Name
    }

    Item {
        anchors.fill: parent

        Rectangle { anchors.fill: parent; color: "#c0c0c0" }
        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#ffffff" }
        Rectangle { anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left; width: 1; color: "#ffffff" }
        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#404040" }
        Rectangle { anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right; width: 1; color: "#404040" }

        ListView {
            id: docListView
            anchors.fill: parent
            anchors.margins: 2
            clip: true
            interactive: contentHeight > height
            model: folderModel

            delegate: Rectangle {
                id: docDelegate
                required property int index
                required property string fileName
                required property url fileUrl
                required property bool fileIsDir

                width: ListView.view.width
                height: 26
                color: "transparent"
                border.color: (docHover.containsMouse || docMenu.activeChildRow === index) ? "#000000" : "transparent"
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    spacing: 10

                    Kirigami.Icon {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        source: docDelegate.fileIsDir ? "folder" : "text-x-generic"
                    }

                    PC3.Label {
                        Layout.fillWidth: true
                        text: docDelegate.fileName
                        font.family: "MS Sans Serif"
                        font.pixelSize: 12
                        color: "#000000"
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    PC3.Label {
                        visible: docDelegate.fileIsDir
                        text: "▶"
                        font.pixelSize: 9
                        color: "#000000"
                    }
                }

                MouseArea {
                    id: docHover
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        if (docMenu.activeChildRow === docDelegate.index) return
                        docMenu.closeChild()
                        if (docDelegate.fileIsDir) {
                            subOpenTimer.targetRow = docDelegate.index
                            subOpenTimer.targetItem = docDelegate
                            subOpenTimer.targetFolder = docDelegate.fileUrl
                            subOpenTimer.restart()
                        } else {
                            subOpenTimer.stop()
                        }
                    }

                    onClicked: {
                        if (docDelegate.fileIsDir) return
                        Qt.openUrlExternally(docDelegate.fileUrl)
                        if (docMenu.rootCallback) docMenu.rootCallback()
                    }
                }
            }
        }

        Timer {
            id: subOpenTimer
            interval: 250
            property int targetRow: -1
            property var targetItem: null
            property var targetFolder: ""
            onTriggered: {
                if (targetRow < 0 || docMenu.activeChildRow === targetRow) return
                const comp = Qt.createComponent("DocumentsMenu.qml")
                if (comp.status === Component.Ready) {
                    const sm = comp.createObject(null, {
                        folderUrl: targetFolder,
                        rootCallback: docMenu.rootCallback,
                        parentMenu: docMenu
                    })
                    docMenu.childMenu = sm
                    docMenu.activeChildRow = targetRow
                    sm.openNextTo(targetItem)
                }
            }
        }
    }
}
