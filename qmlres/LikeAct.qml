import QtQuick 2.0
import QtGraphicalEffects 1.0


Item {
    property alias buttonStartSize: likeButton.height
    property alias relaxInterval: relaxTimer.interval

    property double increase
    property int maxTap

    onButtonStartSizeChanged: {
        likeButton.buttonMaxSize = likeButton.height * (maxTap * increase + 1)
        console.log("buttonMaxSize = ", likeButton.buttonMaxSize)
    }

    Rectangle{
        id:background
        color: "#4FC3F7"
        anchors.fill: parent
    }

    Rectangle{
        id: likeButton
        width: height
        radius: height/2

        x: background.width/2 - width/2
        y: background.height/2 - height/2

        property int buttonMaxSize
        property int currentTap: 0

        Rectangle{
            id: buttonMask
            anchors.fill: likeButton
            radius: likeButton.radius
            color: "#F06292"
            opacity: 0
        }

        Image{
            id: heart
            width: likeButton.width * 2/3
            height: width
            source: "qrc:/photo/heart.png"
            anchors.centerIn: parent
        }

//        Behavior on scale{
//            NumberAnimation{
//                target: buttonMask; property: "opacity"
//                to: likeButton.scale - 1
//                //easing: Easing.Linear
//                //duration: 1000

//            }
//        }

        function replace(){
            likeButton.x = Math.random() * (background.width - buttonMaxSize - buttonMaxSize/2) +
                buttonMaxSize/2
            likeButton.y = Math.random() * (background.height - buttonMaxSize - buttonMaxSize/2) +
                buttonMaxSize/2
//            console.log("likeButton.visible: ", likeButton.visible, "likeButton.coord(x,y): ", likeButton.x,",",
//                likeButton.y)
        }
    }

    PaperRipple{
        id: paperRipple
        anchors.fill: likeButton
        mouseArea: buttonArea
        radius: likeButton.radius
        //color: "#deffffff"
        color: "#F06292"
        scale: likeButton.scale
    }

    Text{
        id: tapLabel
        height: likeButton.height/2
        font.pointSize: height/2
        anchors.top: likeButton.top
        anchors.topMargin: height/2
        anchors.horizontalCenter: likeButton.horizontalCenter
        text: likeButton.currentTap
        scale: likeButton.scale
    }

    ParallelAnimation{
        id: tapAnimation
        NumberAnimation{ id: tapScaleAnim; target: likeButton; property: "scale";
            to: likeButton.scale + increase;
            easing.type: Easing.OutQuint; }
        NumberAnimation{ target: buttonMask; property: "opacity"; to: likeButton.currentTap/ maxTap }
    }


    ParallelAnimation{
        id: relaxAnimation
        NumberAnimation{ id: relaxScaleAnim; target: likeButton; property: "scale"; to: 1;
            easing.type: Easing.OutElastic; easing.amplitude: 2.0; easing.period: 2.0 }
        NumberAnimation{ target: buttonMask; property: "opacity"; to: likeButton.currentTap/ maxTap }
    }


    MouseArea{
        id: buttonArea
        anchors.fill: likeButton
        scale: likeButton.scale
        onClicked:{
            relaxTimer.restart()
            if(likeButton.currentTap < maxTap - 1){
                ++likeButton.currentTap
                tapAnimation.restart()
            }
            else{
                relaxTimer.stop()
                likeButton.currentTap = 0
                relaxAnimation.start()
                likeButton.replace()
            }
            //console.log("currentTap: ", likeButton.currentTap, " opacity: ", buttonMask.opacity)

            //увеличение размера кнопки, пока не будет достигнуто максимальное количестао нажатий
        }
    }

    Timer{
        id: relaxTimer
        interval: 1000
        onTriggered:{
            //уменьшение до исходного размера
            likeButton.currentTap = 0
            relaxAnimation.start()
        }
    }

}
