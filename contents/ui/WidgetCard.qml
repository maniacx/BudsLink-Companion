import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.platform as Kirigami
import Qt5Compat.GraphicalEffects

Item {
    id: root

    property alias content: contentItem.data
    property int cardWidth
    property real radius: 12

    property color borderColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, Kirigami.Theme.frameContrast * 0.15)
    property color backgroundColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, Kirigami.Theme.frameContrast * 0.1)

    property color shadowColor: "#00000025"
    property int shadowRadius: 6
    property int shadowOffsetY: 1
    property int shadowSamples: 16

    width: cardWidth
    implicitHeight: contentItem.implicitHeight

    Behavior on implicitHeight {
        NumberAnimation {
            duration: 120
            easing.type: Easing.InOutQuad
        }
    }

    Rectangle {
        id: background
        anchors.fill: parent
        radius: root.radius
        color: root.backgroundColor
        border.width: 1
        border.color: root.borderColor
    }

    DropShadow {
        anchors.fill: background
        source: background
        verticalOffset: root.shadowOffsetY
        horizontalOffset: 0
        radius: root.shadowRadius
        samples: root.shadowSamples
        color: root.shadowColor
    }

    ColumnLayout {
        id: contentItem
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing
    }
}
