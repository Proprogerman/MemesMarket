import QtQuick 2.0

Item {

    property alias headerText: headerLabel.text

    property color backColor: "#edeef0"
    property color mainColor: "#507299"

    Rectangle{
        id: pageHeader
        anchors.fill: parent
        color: mainColor
        z: 4

        Text{
            id: headerLabel
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.top;
                topMargin: height/4 }
            font.pixelSize: parent.height/2
        }
    }
}
