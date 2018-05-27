import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: control

    property color checkedColor
    property color uncheckedColor
    property bool uncheckWithTap: true
    property bool checked: false
    property alias buttArea: buttonArea
    property alias label: buttonLabel.text

    Rectangle{
        id: mask
        anchors.fill: parent
        radius: button.radius
        visible: false
    }

    Rectangle{
        id: button
        anchors.fill: parent
        visible: false
        color: uncheckedColor
    }

    Text{
        id: buttonLabel
        anchors.centerIn: parent
        font.pixelSize: parent.height/4
        horizontalAlignment: Text.alignCenter
        color: "#000000"
        z: 5
    }

    Component{
        id: waveComponent
        Rectangle{
            id: wave
            color: checkedColor
            x: startX - radius
            y: startY - radius
            width: radius * 2
            height: radius * 2

            property int startX
            property int startY
            property int maxRadius: furthestDistance(startX, startY)

            Connections{
                target: buttonArea
                onPressed:{
                    wave.startX = target.mouseX
                    wave.startY = target.mouseY
                    if(uncheckWithTap)
                        checked = checked ? false : true
                    else
                        checked = true
                }
            }

            states:[
                State{
                    when: !checked
                    name: "unchecked"
                    PropertyChanges{ target: wave; radius: 0 }
                },
                State{
                    when: checked
                    name: "checked"
                    PropertyChanges{ target: wave; radius: maxRadius }
                }
            ]


            Behavior on radius{
                NumberAnimation{ duration: 550; easing.type: Easing.OutCubic }
            }
        }
    }

    OpacityMask{
        anchors.fill: button
        source: button
        maskSource: mask
    }

    MouseArea{
        id: buttonArea
        anchors.fill: parent
    }

    Component.onCompleted:{
        var waveObj = waveComponent.createObject(button)
    }

    function distance(x1, y1, x2, y2) {
        return Math.sqrt(Math.pow(x1 - x2, 2) + Math.pow(y1 - y2, 2))
    }

    function furthestDistance(x, y) {
        return Math.max(distance(x, y, 0, 0), distance(x, y, width, height),
                        distance(x, y, 0, height), distance(x, y, width, 0))
    }

}
