import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    property bool editMode
    property bool usernameEdited
    property bool passwordEdited
    property bool acceptAttempted
    property alias username: usernameField.text
    property alias password: passwordField.text
    property bool acceptableInput: (username != "") && (password != "")

    width: parent.width

    TextField {
        id: usernameField
        visible: !editMode
        // readOnly: editMode
        width: parent.width
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        errorHighlight: !text && acceptAttempted
        placeholderText: qsTr("Enter username")
        label: qsTr("Username")
        onTextChanged: {
            if (focus) {
                usernameEdited = true
                if (!passwordEdited) {
                    passwordField.text = ""
                }
            }
        }
        EnterKey.iconSource: "image://theme/icon-m-enter-next"
        EnterKey.onClicked: passwordField.focus = true
    }

    TextField {
        id: passwordField
        visible: !editMode
        width: parent.width
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        echoMode: TextInput.Password
        errorHighlight: !text && acceptAttempted
        placeholderText: qsTr("Enter password")
        label: qsTrId("Password")
        onTextChanged: {
            if (focus && !passwordEdited) {
                passwordEdited = true
            }
        }
        EnterKey.iconSource: "image://theme/icon-m-enter-next"
        EnterKey.onClicked: focus = true
    }
}
