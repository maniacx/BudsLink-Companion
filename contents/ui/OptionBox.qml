pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    property var device

    Layout.fillWidth: true
    implicitHeight: visibleIndex === 0 ? 0 : loader.implicitHeight + Kirigami.Units.smallSpacing * 2

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 120
            easing.type: Easing.InOutQuad
        }
    }

    readonly property var state: device.state
    readonly property int visibleIndex: state.optionsBoxVisible

    Loader {
        id: loader
        anchors.left: parent.left
        anchors.right: parent.right

        onItemChanged: {
            if (item) {
                item.opacity = 0;
                fadeIn.target = item;
                fadeIn.running = true;
            }
        }

        NumberAnimation {
            id: fadeIn
            property: "opacity"
            from: 0
            to: 1
            duration: 160
            easing.type: Easing.InOutQuad
            running: false
        }

        sourceComponent: {
            if (root.visibleIndex === 1)
                return page1;
            if (root.visibleIndex === 2)
                return page2;
            if (root.visibleIndex === 3)
                return page3;
            if (root.visibleIndex === 4)
                return page4;
            return null;
        }
    }

    Component {
        id: page1
        OptionPage {
            device: root.device
            boxId: 1
        }
    }

    Component {
        id: page2
        OptionPage {
            device: root.device
            boxId: 2
        }
    }

    Component {
        id: page3
        OptionPage {
            device: root.device
            boxId: 3
        }
    }

    Component {
        id: page4
        OptionPage {
            device: root.device
            boxId: 4
        }
    }
}
