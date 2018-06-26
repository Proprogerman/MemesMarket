import QtQuick 2.11
import QtGraphicalEffects 1.0

Item {
    id: control

    property alias color: button.color
    property alias rippleColor: ripple.color
    property alias label: buttonLabel.text
    property alias labelSize: buttonLabel.font.pixelSize
    property alias labelVisible: buttonLabel.visible
    property alias radius: button.radius
    property alias buttArea: buttonArea
    property bool clickable: true

    property color clickableColor
    property color unclickableColor

    signal clicked()

    Rectangle{
        id: button
        anchors.fill: parent
    }

    Text{
        id: buttonLabel
        anchors.centerIn: button
        width: button.width
        height: button.height
        fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    MouseArea{
        id: buttonArea
        anchors.fill: button
        onClicked: control.clicked()
    }

    PaperRipple{
        id: ripple
        anchors.fill: button
        mouseArea: buttonArea
        radius: button.radius
        color: Qt.lighter(button.color)
    }

    DropShadow{
        anchors.fill: button
        source: button
        color: "#80000000"
        z: button.z - 1
        radius: 8.0
        samples: radius * 2 + 1
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
    onClickableChanged: clickableCheck()
    onClickableColorChanged: clickableCheck()
    onUnclickableColorChanged: clickableCheck()
}
