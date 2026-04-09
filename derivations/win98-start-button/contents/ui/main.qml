import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.ksvg as KSvg
import org.kde.plasma.components as PC3
import org.kde.kirigami as Kirigami
import org.kde.plasma.private.kicker as Kicker
import org.kde.plasma.plasma5support as P5Support

PlasmoidItem {
    id: root

    preferredRepresentation: compactRepresentation

    Kicker.RootModel {
        id: rootModel
        autoPopulate: true
        appletInterface: root
        flat: false
        sorted: true
        showSeparators: false
        showAllApps: true
        showTopLevelItems: true
        showRecentDocs: false
        showRecentApps: false
    }

    // Flat "All Applications" model
    Kicker.RootModel {
        id: allAppsModel
        autoPopulate: true
        appletInterface: root
        flat: true
        sorted: true
        showSeparators: false
        showAllApps: true
        showAllAppsCategorized: false
        showTopLevelItems: false
        showRecentDocs: false
        showRecentApps: false
    }

    Kicker.RunnerModel {
        id: runnerModel
        appletInterface: root
        mergeResults: true
        runners: ["krunner_services", "krunner_systemsettings", "krunner_sessions"]
    }

    Kicker.ProcessRunner {
        id: processRunner
    }

    function runCommand(cmd) {
        executable.exec(cmd)
        root.expanded = false
    }

    P5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: (sourceName, data) => {
            disconnectSource(sourceName)
        }
        function exec(cmd) {
            connectSource(cmd)
        }
    }

    property string username: ""

    P5Support.DataSource {
        id: userReader
        engine: "executable"
        connectedSources: ["whoami"]
        onNewData: (sourceName, data) => {
            root.username = (data["stdout"] || "").trim()
            disconnectSource(sourceName)
        }
    }

    compactRepresentation: Item {
        id: compactRoot
        focus: false
        activeFocusOnTab: false

        Layout.preferredWidth: row.implicitWidth + 18
        Layout.minimumWidth: row.implicitWidth + 18
        Layout.fillHeight: true

        KSvg.FrameSvgItem {
            id: buttonFrame
            anchors.fill: parent
            anchors.topMargin: -parent.anchors.topMargin - 5
            anchors.bottomMargin: -parent.anchors.bottomMargin - 5
            imagePath: "widgets/tasks"
            prefix: (mouseArea.pressed || root.expanded) ? "focus" :
                    mouseArea.containsMouse ? "hover" : "normal"
        }

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                source: "xfsm-chooser-icon"
            }

            PC3.Label {
                text: "Start"
                font.family: "MS Sans Serif"
                font.bold: true
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.expanded = !root.expanded
        }
    }

    fullRepresentation: Item {
        id: menuRoot

        implicitWidth: 240
        implicitHeight: mainCol.implicitHeight + 6

        Layout.minimumWidth: implicitWidth
        Layout.minimumHeight: implicitHeight
        Layout.maximumWidth: implicitWidth
        Layout.maximumHeight: implicitHeight
        Layout.preferredWidth: implicitWidth
        Layout.preferredHeight: implicitHeight

        focus: true
        Keys.onPressed: (event) => {
            // Route printable-character keypresses to krunner
            if (event.text.length > 0 && event.text.charCodeAt(0) >= 32) {
                const escaped = event.text.replace(/'/g, "'\\''")
                executable.exec("qdbus org.kde.krunner /App org.kde.krunner.App.query '" + escaped + "'")
                root.expanded = false
                event.accepted = true
            }
        }

        property var activeSubMenu: null
        property int activeChildRow: -1

        function closeChild() {
            if (activeSubMenu) {
                activeSubMenu.closeAll()
                activeSubMenu.destroy()
                activeSubMenu = null
                activeChildRow = -1
            }
        }


        // Vertical side banner (Windows 98 navy)
        Rectangle {
            id: sideBanner
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 2
            anchors.topMargin: 2
            anchors.bottomMargin: 2
            width: 26
            color: "#000080"

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.horizontalCenterOffset: 2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 6
                width: bannerLabel.height
                height: bannerLabel.width

                PC3.Label {
                    id: bannerLabel
                    text: "<b>Nix</b>OS"
                    textFormat: Text.StyledText
                    font.family: "MS Sans Serif"
                    font.pixelSize: 18
                    color: "#ffffff"
                    rotation: -90
                    transformOrigin: Item.Center
                    anchors.centerIn: parent
                }
            }
        }

        ColumnLayout {
            anchors.left: sideBanner.right
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.leftMargin: 2
            anchors.rightMargin: 3
            anchors.topMargin: 3
            anchors.bottomMargin: 3
            spacing: 2

            // Classic Windows 98 main menu items
            Column {
                id: mainCol
                Layout.fillWidth: true
                spacing: 0

                ListModel {
                    id: mainModel
                    ListElement { label: "Programs"; iconName: "applications-other"; hasMenu: true; menuType: "programs"; action: "" }
                    ListElement { label: "Documents"; iconName: "folder-documents"; hasMenu: true; menuType: "documents"; action: "" }
                    ListElement { label: "Settings"; iconName: "kcontrol"; hasMenu: false; menuType: ""; action: "settings" }
                    ListElement { label: "Find"; iconName: "edit-find"; hasMenu: false; menuType: ""; action: "find" }
                    ListElement { label: "Help"; iconName: "help-contents"; hasMenu: false; menuType: ""; action: "help" }
                    ListElement { label: "SEPARATOR"; iconName: ""; hasMenu: false; menuType: ""; action: "" }
                    ListElement { label: "LOGOFF"; iconName: "system-log-out"; hasMenu: false; menuType: ""; action: "logoff" }
                    ListElement { label: "Shut Down..."; iconName: "system-shutdown"; hasMenu: false; menuType: ""; action: "shutdown" }
                }

                Repeater {
                    model: mainModel

                    delegate: Item {
                        id: topDelegate
                        width: mainCol.width
                        height: model.label === "SEPARATOR" ? 10 : 40

                    // Separator
                    Rectangle {
                        visible: model.label === "SEPARATOR"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        height: 1
                        color: "#808080"
                    }
                    Rectangle {
                        visible: model.label === "SEPARATOR"
                        anchors.top: parent.top
                        anchors.topMargin: (parent.height / 2) + 1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.leftMargin: 4
                        anchors.rightMargin: 4
                        height: 1
                        color: "#ffffff"
                    }

                    // Regular item
                    Rectangle {
                        visible: model.label !== "SEPARATOR"
                        anchors.fill: parent
                        color: (topHover.containsMouse || menuRoot.activeChildRow === index) ? "#000080" : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 4
                            anchors.rightMargin: 4
                            spacing: 13

                            Kirigami.Icon {
                                Layout.preferredWidth: 32
                                Layout.preferredHeight: 32
                                source: model.iconName
                            }

                            PC3.Label {
                                Layout.fillWidth: true
                                text: model.label === "LOGOFF" ? ("Log Off " + root.username + "...") : model.label
                                font.family: "MS Sans Serif"
                                font.pixelSize: 13
                                color: (topHover.containsMouse || menuRoot.activeChildRow === index) ? "#ffffff" : "#000000"
                                elide: Text.ElideRight
                                verticalAlignment: Text.AlignVCenter
                            }

                            PC3.Label {
                                visible: model.hasMenu
                                text: "▶"
                                font.pixelSize: 10
                                color: (topHover.containsMouse || menuRoot.activeChildRow === index) ? "#ffffff" : "#000000"
                            }
                        }

                        MouseArea {
                            id: topHover
                            anchors.fill: parent
                            hoverEnabled: true

                            onEntered: {
                                if (menuRoot.activeChildRow === index) {
                                    return
                                }
                                menuRoot.closeChild()
                                if (model.hasMenu) {
                                    openSubTimer.targetRow = index
                                    openSubTimer.targetItem = topDelegate
                                    openSubTimer.targetMenuType = model.menuType
                                    openSubTimer.restart()
                                } else {
                                    openSubTimer.stop()
                                }
                            }

                            onClicked: {
                                if (model.hasMenu) {
                                    return
                                }
                                switch (model.action) {
                                case "settings":
                                    executable.exec("systemsettings")
                                    root.expanded = false
                                    break
                                case "help":
                                    executable.exec("khelpcenter")
                                    root.expanded = false
                                    break
                                case "find":
                                    executable.exec("qdbus org.kde.krunner /App org.kde.krunner.App.display")
                                    root.expanded = false
                                    break
                                case "logoff":
                                    executable.exec("qdbus org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt.promptLogout")
                                    root.expanded = false
                                    break
                                case "shutdown":
                                    executable.exec("qdbus org.kde.LogoutPrompt /LogoutPrompt org.kde.LogoutPrompt.promptShutDown")
                                    root.expanded = false
                                    break
                                }
                            }
                        }
                    }
                    }
                }
            }
        }

        Timer {
            id: openSubTimer
            interval: 250
            property int targetRow: -1
            property var targetItem: null
            property string targetMenuType: ""

            function rootDone() {
                root.expanded = false
            }

            onTriggered: {
                if (targetRow < 0 || menuRoot.activeChildRow === targetRow) return

                let componentFile = ""
                let props = {
                    rootCallback: rootDone,
                    parentMenu: null
                }

                switch (targetMenuType) {
                case "programs":
                    componentFile = "SubMenu.qml"
                    props.subModel = allAppsModel
                    break
                case "documents":
                    componentFile = "DocumentsMenu.qml"
                    props.folderUrl = "file:///home/vaughancodes/Documents"
                    break
                default:
                    return
                }

                const comp = Qt.createComponent(componentFile)
                if (comp.status === Component.Ready) {
                    const sm = comp.createObject(null, props)
                    menuRoot.activeSubMenu = sm
                    menuRoot.activeChildRow = targetRow
                    sm.openNextTo(targetItem)
                } else if (comp.status === Component.Error) {
                    console.log("Menu component error: " + comp.errorString())
                }
            }
        }
    }

    onExpandedChanged: {
        if (!expanded && fullRepresentationItem) {
            fullRepresentationItem.activeChildRow = -1
            if (fullRepresentationItem.activeSubMenu) {
                fullRepresentationItem.activeSubMenu.closeAll()
                fullRepresentationItem.activeSubMenu.destroy()
                fullRepresentationItem.activeSubMenu = null
            }
        }
    }

    Component.onCompleted: {
        Plasmoid.activationTogglesExpanded = true
        Plasmoid.backgroundHints = PlasmaCore.Types.NoBackground
    }
}
