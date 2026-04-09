import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Window
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami

Window {
    id: subMenu

    property var subModel: null
    property Item anchorItem: null
    property var rootCallback: null
    property var parentMenu: null
    property SubMenu childMenu: null
    property int activeChildRow: -1

    flags: Qt.ToolTip | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint
    color: "transparent"

    width: 240
    height: Math.min(subListView.contentHeight + 6, 500)

    function openNextTo(item) {
        anchorItem = item
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

    Item {
        anchors.fill: parent

        Rectangle {
            anchors.fill: parent
            color: "#c0c0c0"
        }
        // Win98 raised bevel edges
        Rectangle { anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#ffffff" }
        Rectangle { anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.left: parent.left; width: 1; color: "#ffffff" }
        Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1; color: "#404040" }
        Rectangle { anchors.top: parent.top; anchors.bottom: parent.bottom; anchors.right: parent.right; width: 1; color: "#404040" }

        ListView {
            id: subListView
            anchors.fill: parent
            anchors.margins: 2
            clip: true
            interactive: contentHeight > height
            model: subMenu.subModel

            delegate: Rectangle {
                id: subDelegate
                required property int index
                required property var model
                readonly property bool itemHasChildren: !!model.hasChildren

                width: ListView.view.width
                height: 26
                color: "transparent"
                border.color: (delegateHover.containsMouse || subMenu.activeChildRow === subDelegate.index) ? "#000000" : "transparent"
                border.width: 2

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 4
                    anchors.rightMargin: 4
                    spacing: 10

                    Kirigami.Icon {
                        Layout.preferredWidth: 16
                        Layout.preferredHeight: 16
                        source: subDelegate.model.decoration || ""
                    }

                    PC3.Label {
                        Layout.fillWidth: true
                        text: subDelegate.model.display || ""
                        font.family: "MS Sans Serif"
                        font.pixelSize: 12
                        color: "#000000"
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    PC3.Label {
                        visible: subDelegate.itemHasChildren
                        text: "▶"
                        font.pixelSize: 9
                        color: "#000000"
                    }
                }

                MouseArea {
                    id: delegateHover
                    anchors.fill: parent
                    hoverEnabled: true

                    onEntered: {
                        if (subMenu.activeChildRow === subDelegate.index) {
                            return
                        }
                        subMenu.closeChild()
                        if (subDelegate.itemHasChildren) {
                            hoverOpenTimer.targetRow = subDelegate.index
                            hoverOpenTimer.targetItem = subDelegate
                            hoverOpenTimer.restart()
                        } else {
                            hoverOpenTimer.stop()
                        }
                    }

                    onClicked: {
                        if (!subDelegate.itemHasChildren) {
                            if (subMenu.subModel.trigger(subDelegate.index, "", null)) {
                                if (subMenu.rootCallback) {
                                    subMenu.rootCallback()
                                }
                            }
                        }
                    }
                }
            }
        }

        Timer {
            id: hoverOpenTimer
            interval: 250
            property int targetRow: -1
            property var targetItem: null
            onTriggered: {
                if (targetRow >= 0 && subMenu.subModel && subMenu.activeChildRow !== targetRow) {
                    const childModel = subMenu.subModel.modelForRow(targetRow)
                    const comp = Qt.createComponent("SubMenu.qml")
                    if (comp.status === Component.Ready) {
                        const sm = comp.createObject(null, {
                            subModel: childModel,
                            rootCallback: subMenu.rootCallback,
                            parentMenu: subMenu
                        })
                        subMenu.childMenu = sm
                        subMenu.activeChildRow = targetRow
                        sm.openNextTo(targetItem)
                    } else if (comp.status === Component.Error) {
                        console.log("SubMenu error: " + comp.errorString())
                    }
                }
            }
        }
    }
}
