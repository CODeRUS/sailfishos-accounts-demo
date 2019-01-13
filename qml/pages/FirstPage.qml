import QtQuick 2.0
import Sailfish.Silica 1.0
import org.coderus.test 1.0

Page {
    id: page

    DemoAccount {
        id: demoAccount
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column

            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("DEMO Account")
            }

            Label {
                text: "Username: %1".arg(demoAccount.username)
            }

            Label {
                text: "Password: %1".arg(demoAccount.password)
            }
        }
    }
}
