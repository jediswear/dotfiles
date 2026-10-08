import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Item {
  id: root

  property string backgroundPath: ""
  property int backgroundVersion: 0
  property bool fingerprintConfigured: false
  property bool authenticatingPassword: false
  property string failureMessage: ""
  property int failedAttempts: 0
  property bool inputEnabled: true
  property bool loadBackground: true
  property string passwordText: ""
  property bool syncingPasswordText: false
  property string weatherIcon: ""
  property string weatherTemp: ""
  property string weatherPlace: ""

  readonly property string placeholderText: "Password…"
  readonly property string fontFamily: "Segoe UI Variable"
  // Vertical anchors as fractions of the screen so the group keeps its place at any resolution.
  readonly property int clockTop: Math.round(height * 0.089)
  readonly property int loginTop: height - Math.round(height * 0.261)
  readonly property string userName: Quickshell.env("USER") || ""
  property date lockedSince: new Date()
  readonly property string greeting: {
    var hour = clock.date.getHours()
    var part = hour >= 5 && hour < 12 ? "Good morning" : (hour >= 12 && hour < 18 ? "Good afternoon" : (hour >= 18 && hour < 23 ? "Good evening" : "Good night"))
    return userName.length > 0 ? part + ", " + userName : part
  }
  readonly property string lockedForText: {
    var minutes = Math.max(0, Math.floor((clock.date.getTime() - lockedSince.getTime()) / 60000))
    if (minutes < 1) return "Locked just now"
    if (minutes < 60) return "Locked for " + minutes + " min"
    return "Locked for " + Math.floor(minutes / 60) + " h " + (minutes % 60) + " min"
  }
  readonly property string facePath: Quickshell.env("HOME") + "/.face"
  readonly property int fieldWidth: 240
  readonly property int fieldHeight: 38
  readonly property int outlineThickness: 2
  readonly property int fieldFontSize: 14
  readonly property int passwordDotFontSize: 10
  readonly property int passwordDotLetterSpacing: 2
  readonly property color labelColor: "#fefefe"
  readonly property string fieldFontFamily: fontFamily
  readonly property int fieldRadius: 19
  readonly property color fieldColor: Qt.rgba(0x1c / 255, 0x1c / 255, 0x1a / 255, 0.4)
  readonly property color fieldTextColor: Color.menu.text
  readonly property color fieldPlaceholderColor: Util.alpha(Color.menu.text, 0.58)
  readonly property color dateColor: "#d9fefefe"
  // Space to keep clear on each side of the field for the fingerprint icon
  // (icon width plus a gap) so the centered dots never run under it.
  readonly property real fingerprintReserve: fingerprintConfigured ? Math.round(fingerprintIcon.implicitWidth + 12) : 0
  // Shrink the dots to fit once the password outgrows the field, so every
  // keystroke stays visible — otherwise long passwords clip with no feedback.
  readonly property real passwordDotScale: dotMetrics.advanceWidth > 0
    ? Math.min(1, (passwordInput.width - 4) / dotMetrics.advanceWidth)
    : 1
  readonly property bool showPasswordCursor: inputEnabled && !authenticatingPassword && failureMessage.length === 0
  readonly property bool errorState: failureMessage.length > 0

  signal submitPassword(string password)
  signal passwordTextEdited(string password)
  signal clearFailureRequested()
  signal wakeRequested()

  // Cache-busts the lock background by appending `?v=`. Adding a query
  // string keeps Image's loader happy while forcing it to reload when the
  // user picks a new background mid-session.
  function fileUrl(path) {
    if (!path) return ""
    var encoded = String(path).split("/").map(encodeURIComponent).join("/")
    return "file://" + encoded + "?v=" + backgroundVersion
  }

  function forcePasswordFocus() {
    passwordInput.forceActiveFocus()
  }

  function clearPassword() {
    passwordTextEdited("")
  }

  function syncPasswordText() {
    if (passwordInput.text === passwordText) return
    syncingPasswordText = true
    passwordInput.text = passwordText
    syncingPasswordText = false
  }

  onPasswordTextChanged: syncPasswordText()
  onLoadBackgroundChanged: if (loadBackground) lockedSince = new Date()
  onInputEnabledChanged: {
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }
  Component.onCompleted: {
    syncPasswordText()
    if (inputEnabled) Qt.callLater(forcePasswordFocus)
  }

  // Measures the masked password at full size; passwordDotScale compares this
  // against the field width to decide how far the dots must shrink to fit.
  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  // Icon, temperature and place as "icon|temp|place"; an empty temp keeps the row hidden.
  Process {
    id: weatherProc
    command: ["bash", "-c", "place=$(omarchy-weather-location 2>/dev/null); [[ -n $place ]] || exit 0; "
      + "q=$(jq -rn --arg p \"$place\" '$p | @uri'); "
      + "temp=$(curl -fsS --max-time 4 \"https://wttr.in/$q?format=%t\" 2>/dev/null | tr -d '+ CF\\n'); "
      + "icon=$(omarchy-weather-icon 2>/dev/null); "
      + "printf '%s|%s|%s' \"$icon\" \"$temp\" \"$place\""]
    stdout: StdioCollector {
      onStreamFinished: {
        var parts = text.replace(/\n/g, "").split("|")
        if (parts.length < 3 || parts[1].length === 0) return
        root.weatherIcon = parts[0]
        root.weatherTemp = parts[1]
        root.weatherPlace = parts[2]
      }
    }
  }

  Timer {
    interval: 15 * 60 * 1000
    repeat: true
    running: root.loadBackground
    triggeredOnStart: true
    onTriggered: if (!weatherProc.running) weatherProc.running = true
  }

  TextMetrics {
    id: dotMetrics
    font.family: root.fieldFontFamily
    font.pixelSize: root.passwordDotFontSize
    font.letterSpacing: root.passwordDotLetterSpacing
    text: "●".repeat(passwordInput.text.length)
  }

  Rectangle {
    anchors.fill: parent
    color: Color.background

    Image {
      id: wallpaper
      anchors.fill: parent
      source: root.loadBackground ? root.fileUrl(root.backgroundPath) : ""
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      sourceSize.width: width
      sourceSize.height: height
    }

    MultiEffect {
      anchors.fill: wallpaper
      source: wallpaper
      autoPaddingEnabled: false
      blurEnabled: root.loadBackground && wallpaper.status === Image.Ready
      blur: 1.0
      blurMax: 64
      blurMultiplier: 1
      contrast: 0.16
      brightness: 0.04
      saturation: 0.4
      colorization: 0.3
      colorizationColor: "#a9b8d0"
    }

    MouseArea {
      anchors.fill: parent
      hoverEnabled: true
      onClicked: { root.wakeRequested(); root.forcePasswordFocus() }
      onPositionChanged: root.wakeRequested()
    }

    Text {
      textFormat: Text.PlainText
      anchors.top: parent.top
      anchors.topMargin: root.clockTop + 12
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatDateTime(clock.date, "HH:mm")
      color: root.labelColor
      font.family: root.fontFamily
      font.weight: Font.DemiBold
      font.pixelSize: 130
      font.letterSpacing: -2
      renderType: Text.NativeRendering
    }

    Text {
      textFormat: Text.PlainText
      anchors.top: parent.top
      anchors.topMargin: root.clockTop
      anchors.horizontalCenter: parent.horizontalCenter
      text: Qt.formatDateTime(clock.date, "dddd, dd MMMM")
      color: root.dateColor
      font.family: root.fontFamily
      font.weight: Font.Medium
      font.pixelSize: 29
      renderType: Text.NativeRendering
    }

    Row {
      anchors.top: parent.top
      anchors.topMargin: root.clockTop + 172
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 14
      visible: root.weatherTemp.length > 0

      Text {
        textFormat: Text.PlainText
        anchors.verticalCenter: parent.verticalCenter
        visible: text.length > 0
        text: root.weatherIcon
        color: root.dateColor
        font.family: Style.font.family
        font.pixelSize: 19
      }

      Text {
        textFormat: Text.PlainText
        anchors.verticalCenter: parent.verticalCenter
        text: root.weatherTemp
        color: root.dateColor
        font.family: root.fontFamily
        font.pixelSize: 17
        renderType: Text.NativeRendering
      }

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 1
        height: 22
        color: root.dateColor
        opacity: 0.6
      }

      Text {
        textFormat: Text.PlainText
        anchors.verticalCenter: parent.verticalCenter
        text: root.weatherPlace
        color: root.dateColor
        font.family: root.fontFamily
        font.pixelSize: 17
        renderType: Text.NativeRendering
      }
    }

    Rectangle {
      width: 80
      height: 80
      radius: 40
      anchors.top: parent.top
      anchors.topMargin: root.loginTop
      anchors.horizontalCenter: parent.horizontalCenter
      color: root.fieldColor
      border.width: 1
      border.color: "#33ffffff"
      antialiasing: true

      Image {
        id: faceImage
        anchors.fill: parent
        source: "file://" + root.facePath
        fillMode: Image.PreserveAspectCrop
        sourceSize.width: width * 2
        sourceSize.height: height * 2
        visible: false
      }

      Rectangle {
        id: faceMask
        anchors.fill: parent
        radius: width / 2
        visible: false
        antialiasing: true
        layer.enabled: true
        layer.smooth: true
        layer.samples: 4
      }

      MultiEffect {
        anchors.fill: parent
        source: faceImage
        maskEnabled: true
        maskSource: faceMask
        maskThresholdMin: 0.5
        maskSpreadAtMin: 1.0
        visible: faceImage.status === Image.Ready
      }

      // Initial as a fallback when there is no face image.
      Text {
        visible: faceImage.status !== Image.Ready
        textFormat: Text.PlainText
        anchors.centerIn: parent
        text: root.userName.charAt(0).toUpperCase()
        color: root.labelColor
        font.family: root.fontFamily
        font.weight: Font.DemiBold
        font.pixelSize: 32
        renderType: Text.NativeRendering
      }
    }

    Text {
      textFormat: Text.PlainText
      anchors.top: parent.top
      anchors.topMargin: root.loginTop + 94
      anchors.horizontalCenter: parent.horizontalCenter
      text: root.greeting
      color: root.labelColor
      font.family: root.fontFamily
      font.weight: Font.DemiBold
      font.pixelSize: 20
      renderType: Text.NativeRendering
    }

    Text {
      textFormat: Text.PlainText
      anchors.top: parent.top
      anchors.topMargin: root.loginTop + 123
      anchors.horizontalCenter: parent.horizontalCenter
      visible: text.length > 0
      text: root.lockedForText
      color: root.dateColor
      opacity: 0.75
      font.family: root.fontFamily
      font.pixelSize: 14
      renderType: Text.NativeRendering
    }

    Rectangle {
      id: inputField
      width: root.fieldWidth
      height: root.fieldHeight
      anchors.top: parent.top
      anchors.topMargin: root.loginTop + 170
      anchors.horizontalCenter: parent.horizontalCenter
      color: root.fieldColor
      border.width: root.errorState ? root.outlineThickness : 0
      border.color: Color.lock.borderError
      radius: root.fieldRadius
      antialiasing: true

      TextInput {
        id: passwordInput
        anchors.fill: parent
        anchors.topMargin: root.outlineThickness
        // Reserve the fingerprint icon's width on both sides so the centered
        // dots stay symmetric and never slide under the icon as they grow.
        anchors.rightMargin: root.outlineThickness + 18 + root.fingerprintReserve
        anchors.bottomMargin: root.outlineThickness
        anchors.leftMargin: root.outlineThickness + 18 + root.fingerprintReserve
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: TextInput.AlignHCenter
        activeFocusOnPress: true
        clip: true
        enabled: root.inputEnabled && !root.authenticatingPassword
        readOnly: root.authenticatingPassword
        echoMode: TextInput.Password
        passwordCharacter: "\u25CF"
        passwordMaskDelay: 0
        color: root.fieldTextColor
        selectionColor: Color.lock.selection
        selectedTextColor: root.fieldTextColor
        font.family: root.fieldFontFamily
        font.pixelSize: text.length > 0 ? Math.max(1, Math.floor(root.passwordDotFontSize * root.passwordDotScale)) : root.fieldFontSize
        font.letterSpacing: text.length > 0 ? root.passwordDotLetterSpacing * root.passwordDotScale : 0
        cursorVisible: activeFocus && root.showPasswordCursor && text.length > 0
        cursorDelegate: Rectangle {
          width: 2
          color: root.fieldTextColor
          visible: passwordInput.cursorVisible
        }

        onTextChanged: {
          if (!root.syncingPasswordText) root.passwordTextEdited(text)
          if (text.length > 0) {
            root.wakeRequested()
          }
          if (text.length > 0 && root.failureMessage.length > 0) root.clearFailureRequested()
        }

        onAccepted: {
          var submitted = root.passwordText
          root.passwordTextEdited("")
          if (submitted.length > 0) root.submitPassword(submitted)
        }

        Keys.onPressed: function(event) {
          root.wakeRequested()
          if (event.key === Qt.Key_Escape || (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U)) {
            root.passwordTextEdited("")
            event.accepted = true
          }
        }
      }

      Text {
        textFormat: Text.PlainText
        anchors.fill: passwordInput
        text: root.authenticatingPassword ? "Checking…" : (root.failureMessage.length > 0 ? root.failureMessage : root.placeholderText)
        visible: passwordInput.text.length === 0
        color: root.authenticatingPassword ? root.fieldTextColor : (root.failureMessage.length > 0 ? Color.lock.textError : root.fieldPlaceholderColor)
        font.family: root.fieldFontFamily
        font.pixelSize: root.fieldFontSize
        font.italic: !root.authenticatingPassword && root.failureMessage.length > 0
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
      }

      // Fingerprint hint pinned inside the field's right edge when a sensor is
      // enrolled, so the user knows they can touch to unlock instead of typing.
      // Matches hyprlock, which draws its fingerprint icon in the same spot.
      Text {
        id: fingerprintIcon
        objectName: "fingerprintIndicator"
        anchors.right: parent.right
        anchors.rightMargin: root.outlineThickness + 18
        anchors.verticalCenter: parent.verticalCenter
        visible: root.fingerprintConfigured
        text: "󰈷"
        color: root.fieldPlaceholderColor
        font.family: Style.font.family
        font.pixelSize: Math.round(root.fieldFontSize * 1.1)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
      }
    }
  }
}
