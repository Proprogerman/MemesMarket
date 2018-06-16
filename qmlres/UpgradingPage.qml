import QtQuick 2.0
import QtQuick.Controls 2.2

Page {
    id: upgradingPage

    objectName: "upgradingPage"

    background: backgroundItem

    Rectangle{
        id: backgroundItem
        anchors.fill: parent
        z: -2
        color: backColor
    }

    PageHeader{
        id: pageHeader
        width: parent.width
        height: parent.height / 10
        headerText: "улучшения"
        z: 7
    }



}
