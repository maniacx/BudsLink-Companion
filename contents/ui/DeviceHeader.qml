pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var device
    property int contentWidth: Kirigami.Units.gridUnit * 9

    implicitWidth: contentWidth
    implicitHeight: row.implicitHeight
    Layout.topMargin: Kirigami.Units.smallSpacing * 2

    RowLayout {
        id: row
        width: root.contentWidth - Kirigami.Units.smallSpacing * 2
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Heading {
            text: root.device.alias
            Layout.fillWidth: true
            elide: Text.ElideRight
            level: 1
            Layout.alignment: Qt.AlignBottom
        }

        PlasmaComponents3.Button {
            id: settingsButton
            icon.source: Qt.resolvedUrl("../icons/bbm-settings-symbolic.svg")
            implicitWidth: Kirigami.Units.smallSpacing * 6
            implicitHeight: Kirigami.Units.smallSpacing * 6
            ToolTip.visible: hovered
            ToolTip.text: i18n("Device settings")

            onClicked: {
                if (root.device)
                    root.device.callUiAction("settingsButtonClicked", 0);
            }
        }
    }
}
