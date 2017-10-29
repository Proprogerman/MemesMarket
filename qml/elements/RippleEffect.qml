import QtQuick 2.0

Item {
//    var object

    Rectangle{
        id: background
        anchors.fill: parent
        color:"blue"
    }


//    Loader{
//        id: rippleLoader
//        sourceComponent: rippleElement
//    }

    MouseArea{
        id: rippleArea
        anchors.fill: background
        onClicked:{
            rippleElement.centerIn(mouseX, mouseY)
            rippleElement.visible = true
            rippleAnimation.restart()
        }
    }
    ParallelAnimation{
        id: rippleAnimation
        NumberAnimation{
            target: rippleElement
            property: "scale"
            from: 0.1
            to: 10
            duration: 250
            //easing: Easing.InQuad
        }
        NumberAnimation{
            target: rippleElement
            property: "opacity"
            from: 1
            to: 0
            duration: 250
            //easing: Easing.InQuad
        }
    }
    Rectangle{
        id: rippleElement
        height: background.height/10
        width: background.width/10
        radius: width/2
        color: "#ffffff"
        visible: false
        //opacity: 0
        function centerIn(x,y){
            rippleElement.x = x - rippleElement.width/2
            rippleElement.y = y - rippleElement.height/2
        }
    }
}
