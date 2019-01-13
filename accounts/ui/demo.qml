import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.accounts 1.0
import "DemoConstants.js" as DemoConstants

AccountCreationAgent {
    id: root

    property Item _settingsDialog

    initialPage: Dialog {
        canAccept: settings.acceptableInput
        acceptDestination: busyComponent

        SilicaFlickable {
            anchors.fill: parent
            contentHeight: contentColumn.height + Theme.paddingLarge

            Column {
                id: contentColumn
                width: parent.width

                DialogHeader {
                    dialog: initialPage
                }

                Item {
                    x: Theme.horizontalPageMargin
                    width: parent.width - x*2
                    height: icon.height + Theme.paddingLarge

                    Image {
                        id: icon
                        width: Theme.iconSizeLarge
                        height: width
                        anchors.top: parent.top
                        source: root.accountProvider.iconName
                    }

                    Label {
                        anchors {
                            left: icon.right
                            leftMargin: Theme.paddingLarge
                            right: parent.right
                            verticalCenter: icon.verticalCenter
                        }
                        text: root.accountProvider.displayName
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeLarge
                        truncationMode: TruncationMode.Fade
                    }
                }

                DemoSettingsCommon {
                    id: settings
                }
            }

            VerticalScrollDecorator {}
        }
    }

    Component {
        id: busyComponent
        AccountBusyPage {
            onStatusChanged: {
                if (status == PageStatus.Active) {
                    accountFactory.beginCreation()
                }
            }
        }
    }

    Component {
        id: settingsComponent
        Dialog {
            property alias accountId: settingsDisplay.accountId

            acceptDestination: root.endDestination
            acceptDestinationAction: root.endDestinationAction
            acceptDestinationProperties: root.endDestinationProperties
            acceptDestinationReplaceTarget: root.endDestinationReplaceTarget
            backNavigation: false

            onAccepted: {
                root.delayDeletion = true
                settingsDisplay.saveAccount()
            }

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: settingsColumn.height + Theme.paddingLarge

                Column {
                    id: settingsColumn
                    width: parent.width

                    DialogHeader {
                        id: header
                    }

                    DemoSettingsDisplay {
                        id: settingsDisplay
                        accountProvider: root.accountProvider
                        autoEnableAccount: true

                        onAccountSaveCompleted: {
                            root.delayDeletion = false
                        }
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }

    AccountFactory {
        id: accountFactory

        function beginCreation() {
            var configuration = {}
            createAccount(
                root.accountProvider.name,            // providerName
                root.accountProvider.serviceNames[0], // serviceName
                settings.username,                    // username
                settings.password,                    // password
                "Demo " + settings.username,          // displayName
                {                                     // configuration map
                    "Demo": configuration
                },
                DemoConstants.accApplicationName(),   // applicationName
                DemoConstants.accSymmetricKey(),      // symmetricKey
                DemoConstants.accCredentialsName()    // credentialsName
            );
        }

        onError: {
            console.log("Demo account creation error:", message)
            initialPage.acceptDestinationInstance.state = "info"
            root.accountCreationError(message)
        }

        onSuccess: {
            root._settingsDialog = settingsComponent.createObject(root, {"accountId": newAccountId})
            pageStack.push(root._settingsDialog)
            root.accountCreated(newAccountId)
        }
    }
}
