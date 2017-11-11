import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    property alias buttonColor: button.color
    //property alias buttonText:
    signal buttonClicked()

    Rectangle{
        id: button
        anchors.fill: parent
    }

    Text{
        anchors.centerIn: button

    }

    DropShadow{
        anchors.fill: button
        source: button
        color: "#000000"
    }

    MouseArea{
        id: buttonArea
        anchors.fill: button
    }

    PaperRipple{
        id: paperRipple
        anchors.fill: button
        mouseArea: buttonArea
        //radius: Math.max(button.width, button.height)
        radius: 0
        //color: "#deffffff"
        color: Qt.lighter(button.color, 1.5)
    }


    Component.onCompleted:{
        buttonArea.clicked.connect(buttonClicked)
    }
}
