import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0
import "DemoConstants.js" as DemoConstants

AccountCredentialsAgent {
    id: root

    canCancelUpdate: true

    initialPage: Dialog {
        id: updateDialog

        acceptDestinationAction: PageStackAction.Push
        acceptDestination: AccountBusyPage {
            busyDescription: updatingAccountText
        }

        property bool _updateAccepted
        property bool _checkMandatoryFields
        property bool _passwordEdited
        property string _defaultServiceName: DemoConstants.defaultServiceName()
        property string _oldUsername: account.defaultCredentialsUserName

        function _updateCredentials() {
            var password = ""
            if (_passwordEdited) {
                password = passwordField.text
                _passwordEdited = false
            }

            if (account.hasSignInCredentials(DemoConstants.accApplicationName(), DemoConstants.accCredentialsName())) {
                account.updateSignInCredentials(
                            DemoConstants.accApplicationName(),
                            DemoConstants.accCredentialsName(),
                            account.signInParameters(_defaultServiceName, usernameField.text, passwordField.text),
                            DemoConstants.accSymmetricKey())
            } else {
                var configValues = { "": account.configurationValues("") }
                var serviceNames = account.supportedServiceNames
                for (var si in serviceNames) {
                    configValues[serviceNames[si]] = account.configurationValues(serviceNames[si])
                }
                accountFactory.recreateAccountCredentials(
                            account.identifier,                 // accountId
                            _defaultServiceName,                // serviceName
                            usernameField.text,                 // username
                            passwordField.text,                 // password
                            account.signInParameters(_defaultServiceName, usernameField.text, passwordField.text), // params
                            DemoConstants.accApplicationName(), // applicationName
                            DemoConstants.accSymmetricKey(),    // symmetricKey
                            DemoConstants.accCredentialsName(), // credentialsName
                            configValues)                       // config
            }
        }

        canAccept: passwordField.text.length > 0 && usernameField.text.length > 0

        onAcceptPendingChanged: {
            if (acceptPending === true) {
                _checkMandatoryFields = true
            }
        }

        onStatusChanged: {
            if (status == PageStatus.Inactive && result == DialogResult.Accepted) {
                _updateCredentials()
            }
        }

        onRejected: {
            if(account.status === Account.SigningIn) {
                account.cancelSignInOperation()
            }
        }

        DialogHeader {
            id: pageHeader
        }

        Column {
            anchors.top: pageHeader.bottom
            spacing: Theme.paddingLarge
            width: parent.width

            Label {
                text: qsTrId("accounts-me-update_credentials")
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraLarge
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                color: Theme.highlightColor
            }

            TextField {
                id: usernameField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                errorHighlight: !text && updateDialog._checkMandatoryFields

                //: Placeholder text for username
                //% "Enter username"
                placeholderText: qsTr("Demo username")
                //: username
                //% "Username"
                label: qsTr("Username")
                text: updateDialog._oldUsername
                onTextChanged: {
                    if (focus) {
                        if (!updateDialog._passwordEdited)
                            passwordField.text = ""
                    }
                }
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: passwordField.focus = true
            }


            PasswordField {
                id: passwordField
                errorHighlight: !text && updateDialog._checkMandatoryFields
                text: "default"
                onTextChanged: {
                    if (focus) {
                        updateDialog._passwordEdited = true
                    }
                }
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
            }
        }
    }

    Account {
        id: account
        identifier: root.accountId

        onSignInCredentialsUpdated: {
            console.log("Demo-update: account sign in credentials updated: accId: " + identifier)
            root.credentialsUpdated(identifier)
            root.goToEndDestination()
        }

        onSignInError: {
            console.log("Account sign in error:", errorMessage)
            root.credentialsUpdateError(errorMessage)
            var busyPage = updateDialog.acceptDestination
            busyPage.state = 'info'
            busyPage.infoHeading = busyPage.errorHeadingText
            busyPage.infoDescription = busyPage.accountUpdateErrorText
        }
    }
}
