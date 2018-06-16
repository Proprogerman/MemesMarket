import QtQuick 2.11

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
                topMargin: (pageHeader.height - font.pixelSize) / 2 }
            font.family: "Roboto"
            font.pixelSize: parent.height / 2
            height: parent.height
            width: parent.width * 5 / 8
            fontSizeMode: Text.HorizontalFit
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
