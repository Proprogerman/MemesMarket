import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    property int amount: 0
    property alias running: waveAnimation.running
    property alias itemColor: colorOverlay.color

    Rectangle{
        id: waveFrame
        height: parent.height
        width: parent.width
        color: "#999999"
        visible: false
        anchors.centerIn: parent

        Image{
            id: wave
            source: "qrc:/uiIcons/wave.svg"
            height: parent.height * 2
            width: parent.width * 2
            y: parent.y + parent.height * ( 1 - amount / 100 ) - height / 10
            x: parent.x + parent.width - width
            visible: false

            Behavior on y {
                PropertyAnimation{ duration: 500; easing.type: Easing.OutCirc }
            }
        }
        ColorOverlay{
            id: colorOverlay
            anchors.fill: wave
            source: wave
        }
    }

    OpacityMask{
        id: opacityMask
        anchors.fill: waveFrame
        source: waveFrame
        maskSource: Rectangle{
            id: mask
            height: opacityMask.height
            width: opacityMask.width
            radius: width / 2
            color: "white"
            visible: false
        }
    }

    PropertyAnimation{
        id: waveAnimation
        target: wave
        property: "x"
        from: waveFrame.x + waveFrame.width - wave.width
        to: waveFrame.x + waveFrame.width - wave.width / 2
        loops: Animation.Infinite
        duration: 650
        running: false
    }
}
