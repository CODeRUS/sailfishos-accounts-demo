import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

AccountSettingsAgent {
    id: root

    initialPage: Page {
        onPageContainerChanged: {
            if (pageContainer == null) {
                root.delayDeletion = true
                settingsDisplay.saveAccount()
            }
        }

        Component.onDestruction: {
            if (status == PageStatus.Active && !credentialsUpdater.running) {
                settingsDisplay.saveAccount(true)
            }
        }

        SilicaFlickable {
            anchors.fill: parent
            contentHeight: settingsColumn.height + Theme.paddingLarge

            StandardAccountSettingsPullDownMenu {
                allowCredentialsUpdate: true
                allowSync: false

                onCredentialsUpdateRequested: {
                    credentialsUpdater.replaceWithCredentialsUpdatePage(root.accountId)
                }

                onAccountDeletionRequested: {
                    root.accountDeletionRequested()
                    pageStack.pop()
                }
            }

            Column {
                id: settingsColumn
                width: parent.width

                PageHeader {
                    id: header
                    title: root.accountsHeaderText
                }

                DemoSettingsDisplay {
                    id: settingsDisplay
                    accountProvider: root.accountProvider
                    accountId: root.accountId

                    onAccountSaveCompleted: {
                        root.delayDeletion = false
                    }
                }
            }

            VerticalScrollDecorator {}
        }

        AccountCredentialsUpdater {
            id: credentialsUpdater
        }
    }
}
