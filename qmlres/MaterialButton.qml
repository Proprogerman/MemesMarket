import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: control

    property alias color: button.color
    property alias rippleColor: ripple.color
    property alias label: buttonLabel.text
    property alias radius: button.radius
    property alias buttArea: buttonArea
    property bool clickable

    property color clickableColor
    property color unclickableColor

    Rectangle{
        id: button
        anchors.fill: parent
    }

    Text{
        id: buttonLabel
        anchors.centerIn: button
        font.pointSize: button.height/4
        horizontalAlignment: Text.AlignHCenter
    }

    MouseArea{
        id: buttonArea
        anchors.fill: button
    }

    PaperRipple{
        id: ripple
        anchors.fill: button
        mouseArea: buttonArea
        radius: button.radius
    }

    DropShadow{
        anchors.fill: button
        source: button
        color: "#80000000"
        //color: "#000000"
        z: button.z - 1
        radius: 8.0
        samples: 17
    }

    function clickableCheck(){
        if(clickable){
            buttonArea.enabled = true
            button.color = clickableColor
        }
        else{
            buttonArea.enabled = false
            button.color = unclickableColor
        }
    }

    Component.onCompleted:{ clickableCheck() }
    onClickableChanged:{ clickableCheck() }
}
