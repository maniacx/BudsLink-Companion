pragma ComponentBehavior: Bound

import QtQuick 2.15
import org.kde.kirigami as Kirigami

Item {
    id: root

    property string iconName: ""
    property int percentage: 0
    property string status: "disconnected"
    property int size: Kirigami.Units.iconSizes.small
    property int lineWidth: 5
    property bool showBackground: true

    width: size * 2.1
    height: size * 2.1

    Canvas {
        id: canvas
        anchors.fill: parent
        rotation: 0

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.clearRect(0, 0, width, height);

            var cx = width / 2;
            var cy = height / 2;
            var r = (width - root.lineWidth) / 2;
            var lw = root.lineWidth;

            if (root.showBackground) {
                var gradBg = ctx.createRadialGradient(cx, cy, r - lw / 2, cx, cy, r + lw / 2);
                gradBg.addColorStop(0.0, "rgba(128,128,128,0)");
                gradBg.addColorStop(0.25, "rgba(128,128,128,0.4)");
                gradBg.addColorStop(0.75, "rgba(128,128,128,0.4)");
                gradBg.addColorStop(1.0, "rgba(128,128,128,0)");

                ctx.beginPath();
                ctx.arc(cx, cy, r, 0, 2 * Math.PI);
                ctx.lineWidth = lw;
                ctx.strokeStyle = gradBg;
                ctx.stroke();
            }

            var end = (-Math.PI / 2) + (root.percentage / 100) * 2 * Math.PI;

            var gradArc = ctx.createRadialGradient(cx, cy, r - lw / 2, cx, cy, r + lw / 2);
            gradArc.addColorStop(0.0, "rgba(76,175,80,0)");
            gradArc.addColorStop(0.25, "rgba(76,175,80,1)");
            gradArc.addColorStop(0.75, "rgba(76,175,80,1)");
            gradArc.addColorStop(1.0, "rgba(76,175,80,0)");

            ctx.beginPath();
            ctx.arc(cx, cy, r, -Math.PI / 2, end, false);
            ctx.lineWidth = lw;
            ctx.strokeStyle = gradArc;
            ctx.stroke();
        }
    }

    Kirigami.Icon {
        anchors.centerIn: parent
        width: root.size * 0.95
        height: root.size * 0.95
        source: Qt.resolvedUrl("../icons/bbm-" + root.iconName + "-symbolic.svg")
    }

    Kirigami.Icon {
        id: chargingStatus
        anchors.centerIn: parent
        width: root.width
        height: root.height

        visible: root.status !== "discharging"

        source: {
            if (root.status === "charging")
                return Qt.resolvedUrl("../icons/bbm-charging-symbolic.svg");
            if (root.status === "disconnected")
                return Qt.resolvedUrl("../icons/bbm-disconnected-symbolic.svg");
            return "";
        }

        color: {
            if (root.status === "disconnected")
                return Kirigami.Theme.negativeTextColor;
            return Kirigami.Theme.textColor;
        }
    }

    onPercentageChanged: canvas.requestPaint()
}
