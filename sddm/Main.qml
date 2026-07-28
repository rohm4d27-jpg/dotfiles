import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 640
    height: 480
    color: "#0c0c0e"

    property string currentUser: userModel.lastUser
    property bool loginFailed: false
    property int sessionIndex: {
        for (var i = 0; i < sessionModel.rowCount(); i++) {
            var name = (sessionModel.data(sessionModel.index(i, 0), Qt.DisplayRole) || "").toString()
            if (name.indexOf("uwsm") !== -1)
                return i
        }
        return sessionModel.lastIndex
    }

    Connections {
        target: sddm
        function onLoginFailed() {
            root.loginFailed = true
            shakeAnim.start()
            passwordField.text = ""
            passwordField.focus = true
            clearFail.start()
        }
        function onLoginSucceeded() {
            root.loginFailed = false
        }
    }

    Timer {
        id: clearFail
        interval: 1200
        onTriggered: root.loginFailed = false
    }

    Column {
        anchors.centerIn: parent
        spacing: 54

        // ── OMARCHY logo ──────────────────────────────────────
        Image {
            id: logo
            source: "logo.png"
            width: Math.min(sourceSize.width, root.width * 0.72)
            height: sourceSize.width > 0
                ? Math.round(width * sourceSize.height / sourceSize.width)
                : 0
            fillMode: Image.PreserveAspectFit
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0

            NumberAnimation on opacity {
                running: true
                from: 0; to: 1
                duration: 650
                easing.type: Easing.OutQuart
            }
        }

        // ── Password pill ──────────────────────────────────────
        Item {
            id: pill
            width: 360
            height: 52
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0
            scale: 0.92

            // Translate target for shake — avoids fighting anchors
            transform: Translate { id: shakeOffset; x: 0 }

            // Fade + scale entry (delayed 180ms after logo starts)
            SequentialAnimation {
                running: true
                PauseAnimation { duration: 180 }
                ParallelAnimation {
                    NumberAnimation {
                        target: pill; property: "opacity"
                        from: 0; to: 1; duration: 480
                        easing.type: Easing.OutQuart
                    }
                    NumberAnimation {
                        target: pill; property: "scale"
                        from: 0.92; to: 1; duration: 480
                        easing.type: Easing.OutQuart
                    }
                }
            }

            // Error shake
            SequentialAnimation {
                id: shakeAnim
                NumberAnimation { target: shakeOffset; property: "x"; from: 0; to: -12; duration: 55 }
                NumberAnimation { target: shakeOffset; property: "x"; to:  12; duration: 70 }
                NumberAnimation { target: shakeOffset; property: "x"; to:  -9; duration: 60 }
                NumberAnimation { target: shakeOffset; property: "x"; to:   9; duration: 60 }
                NumberAnimation { target: shakeOffset; property: "x"; to:  -5; duration: 50 }
                NumberAnimation { target: shakeOffset; property: "x"; to:   0; duration: 45 }
            }

            // Outer glow ring — fades in on focus, pulses while typing
            Rectangle {
                id: glowRing
                anchors.centerIn: parent
                width: parent.width + 18
                height: parent.height + 18
                radius: height / 2
                color: "transparent"
                border.width: 9
                border.color: root.loginFailed ? "#cc3333" : "#ffffff"
                opacity: passwordField.activeFocus ? 0.13 : 0

                Behavior on opacity     { NumberAnimation { duration: 380 } }
                Behavior on border.color { ColorAnimation { duration: 260 } }

                // Subtle pulse while the field has focus
                SequentialAnimation {
                    loops: Animation.Infinite
                    running: passwordField.activeFocus
                    NumberAnimation { target: glowRing; property: "opacity"; to: 0.20; duration: 950; easing.type: Easing.InOutSine }
                    NumberAnimation { target: glowRing; property: "opacity"; to: 0.07; duration: 950; easing.type: Easing.InOutSine }
                }
            }

            // Pill body
            Rectangle {
                anchors.fill: parent
                radius: height / 2
                color: "#14141a"
                border.width: 1
                border.color: root.loginFailed ? "#aa3333"
                            : passwordField.activeFocus ? "#6e6e88"
                            : "#2a2a34"

                Behavior on border.color { ColorAnimation { duration: 260 } }
            }

            // Lock icon
            Text {
                id: lockIcon
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                font.family: "JetBrainsMono Nerd Font"
                font.pixelSize: 15
                text: ""
                color: root.loginFailed ? "#aa3333" : "#50505f"

                Behavior on color { ColorAnimation { duration: 220 } }
            }

            // Character dots — pop in as keys are pressed
            Row {
                anchors.left: lockIcon.right
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 9

                Repeater {
                    model: Math.min(passwordField.text.length, 20)
                    Rectangle {
                        width: 7; height: 7
                        radius: 4
                        color: root.loginFailed ? "#aa3333" : "#c8c8d8"
                        scale: 0

                        Behavior on color { ColorAnimation { duration: 180 } }

                        NumberAnimation on scale {
                            running: true
                            from: 0; to: 1; duration: 140
                            easing.type: Easing.OutBack
                            easing.overshoot: 1.5
                        }
                    }
                }
            }

            // Placeholder — visible when field is empty
            Text {
                anchors.left: lockIcon.right
                anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                text: "Enter Password"
                font.family: "Inter"
                font.pixelSize: 15
                font.italic: true
                color: "#35353f"
                visible: passwordField.text.length === 0
            }

            // Invisible TextInput — captures all keystrokes
            TextInput {
                id: passwordField
                anchors.fill: parent
                anchors.leftMargin: 54
                anchors.rightMargin: 18
                verticalAlignment: TextInput.AlignVCenter
                echoMode: TextInput.Password
                passwordCharacter: "•"
                color: "transparent"
                selectionColor: "transparent"
                selectedTextColor: "transparent"
                cursorDelegate: Item {}
                font.pixelSize: 16
                focus: true

                onTextChanged: root.loginFailed = false

                Keys.onPressed: {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        sddm.login(root.currentUser, passwordField.text, root.sessionIndex)
                        event.accepted = true
                    }
                }
            }
        }
    }

    Component.onCompleted: passwordField.forceActiveFocus()
}
