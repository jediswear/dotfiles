import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "custom.apps"

  readonly property var window: root.QsWindow.window
  readonly property string screenName: window && window.screen ? String(window.screen.name || "") : ""
  readonly property int iconSize: 14

  // Occupied, non-special workspaces on this bar's monitor, sorted by id.
  function monitorWorkspaces() {
    var values = Hyprland.workspaces.values
    var result = []

    for (var i = 0; i < values.length; i++) {
      var workspace = values[i]
      if (workspace.id <= 0) continue
      if (!workspace.monitor || workspace.monitor.name !== root.screenName) continue
      if (workspace.toplevels.values.length === 0) continue
      result.push(workspace)
    }

    result.sort(function(left, right) { return left.id - right.id })
    return result
  }

  function iconSource(appId) {
    var value = String(appId || "")
    var entry = value.length > 0 ? DesktopEntries.heuristicLookup(value) : null
    var themed = Quickshell.iconPath(entry && entry.icon ? entry.icon : value, true)
    if (themed.length > 0) return themed
    return Quickshell.iconPath("application-x-executable", true)
  }

  visible: screenName !== "" && monitorWorkspaces().length > 0
  readonly property int edgePadding: Style.space(8)

  implicitWidth: visible ? (root.vertical ? root.barSize : grid.implicitWidth + edgePadding * 2) : 0
  implicitHeight: visible ? (root.vertical ? grid.implicitHeight + edgePadding * 2 : root.barSize) : 0

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.leftMargin: root.vertical ? 0 : root.edgePadding
    anchors.rightMargin: root.vertical ? 0 : root.edgePadding
    anchors.topMargin: root.vertical ? root.edgePadding : 0
    anchors.bottomMargin: root.vertical ? root.edgePadding : 0
    flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
    columns: root.vertical ? 1 : -1
    rows: root.vertical ? -1 : 1
    columnSpacing: root.vertical ? 0 : Style.space(14)
    rowSpacing: root.vertical ? Style.space(14) : 0

    Repeater {
      model: root.monitorWorkspaces()

      Rectangle {
        id: group
        required property var modelData
        readonly property color foreground: root.bar ? root.bar.barForeground : Color.foreground

        // Only the active group reserves room for its background along the bar.
        readonly property int mainPadding: modelData.active ? Style.space(8) : 0

        Layout.alignment: Qt.AlignCenter
        implicitWidth: icons.implicitWidth + (root.vertical ? Style.space(4) : mainPadding) * 2
        implicitHeight: icons.implicitHeight + (root.vertical ? mainPadding : Style.space(4)) * 2
        radius: Style.space(6)
        color: Qt.rgba(foreground.r, foreground.g, foreground.b, modelData.active ? 0.1 : 0)

        GridLayout {
          id: icons
          anchors.centerIn: parent
          flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
          columns: root.vertical ? 1 : -1
          rows: root.vertical ? -1 : 1
          columnSpacing: root.vertical ? 0 : Style.space(8)
          rowSpacing: root.vertical ? Style.space(8) : 0

          Repeater {
            model: group.modelData.toplevels

            Image {
              required property var modelData

              Layout.alignment: Qt.AlignCenter
              Layout.preferredWidth: implicitHeight > 0 ? Math.round(root.iconSize * implicitWidth / implicitHeight) : root.iconSize
              Layout.preferredHeight: root.iconSize
              fillMode: Image.PreserveAspectFit
              // Decode at physical pixels — a logical-size decode leaves
              // PNG icons upscaled and blurry on HiDPI displays.
              sourceSize.width: Math.round(root.iconSize * Screen.devicePixelRatio)
              sourceSize.height: Math.round(root.iconSize * Screen.devicePixelRatio)
              source: root.iconSource(modelData.wayland ? modelData.wayland.appId : "")
              asynchronous: true

              Rectangle {
                visible: parent.modelData.activated
                anchors.top: parent.bottom
                anchors.topMargin: (group.height - parent.height) / 2 - height
                anchors.horizontalCenter: parent.horizontalCenter
                width: Style.space(3)
                height: width
                radius: width / 2
                color: Qt.rgba(1, 1, 1, 0.8)
              }
            }
          }
        }
      }
    }
  }
}
