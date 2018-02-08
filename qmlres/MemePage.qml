import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtCharts 2.2

import KlimeSoft.SingletonUser 1.0

import "qrc:/qml/elements"

Page{

    Component.onCompleted:{
        User.getMeme(name.toString())
    }

    property alias img: image.source
    property alias name: memeName.text

    property color mainColor: "#507299"
    //property color backColor: "#78909C"
    property color backColor: "#edeef0"
    property int itemSpacing: 0//pageHeader.height * 1/4

    //backgroundColor: backColor
    Rectangle{
        id: background
        anchors.fill: parent
        color: backColor
    }

    Rectangle{
        id: pageHeader
        width: parent.width
        height: parent.height * 1/10
        anchors.top: parent.top
        color: mainColor
        z: 4

        Text{
            id: memeName
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.top;
                topMargin: height/4 }
            text: "Meme's name"//ServerConnection.user_name
            font.pixelSize: parent.height/2
        }
    }


    DropShadow{
        anchors.fill: pageHeader
        //verticalOffset: staticLine.height * 1/5
        radius: 13
        samples: 17
        color:"#000000"
        source: pageHeader
        opacity: 0.5
        z: 3
    }
    Rectangle{
        id: imageItem
        width: parent.width
        height: parent.width * 1/2
        anchors.top: pageHeader.bottom
        //anchors.topMargin:
        color: backColor//"white"
        Image {
            id: image
            width: parent.height
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            source: "qrc:/memePhoto/respectMeme.jpg"
        }
    }

    Rectangle{
        id: popGraphItem
        width: parent.width
        height: parent.height * 3/8
        anchors.top: imageItem.bottom
        color: backColor

        ChartView{
            //title: "Популярность мема:"
            anchors.fill: parent
            antialiasing: true
            legend.visible: false

            LineSeries{
                XYPoint { x: 0; y: 0 }
                XYPoint { x: 1.1; y: 2.1 }
                XYPoint { x: 1.9; y: 3.3 }
                XYPoint { x: 2.1; y: 2.1 }
                XYPoint { x: 2.9; y: 4.9 }
                XYPoint { x: 3.4; y: 3.0 }
                XYPoint { x: 4.1; y: 3.3 }
            }
        }
    }
    //Pop
    Rectangle{
        id: popManipItem
        anchors{ top: popGraphItem.bottom; bottom: parent.bottom;
            left: parent.left; right: parent.right }
        color: backColor

        RadioButtons{
            id: radioButton
            width: parent.width;
            height: 100;
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            uncheckedColor: "#ECEFF1"
            checkedColor: "#607D8B"
            backgroundColor: backColor
            spacing: width/70

            Component.onCompleted:{
                button.clickable = radioButton.checkedItem != 0 ? true : false
                radioButton.buttItems.item1 = 100
                radioButton.buttItems.item2 = 200
                radioButton.buttItems.item3 = 300
                radioButton.buttItems.item4 = 400
            }
            onCheckedItemChanged:{
                button.clickable = radioButton.checkedItem != 0 ? true : false
            }
        }

        MaterialButton{
            id: button
            width: 200
            height: 100
            anchors{
                top:radioButton.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
    //        color: "#F48FB1"
            clickable: true
            radius: height/ 20
            rippleColor: "#F8BBD0"
            unclickableColor: "#F48FB1"
            clickableColor: "#EC407A"
            label: "Click"

            Connections{
                target: button.buttArea
                onClicked: { likeActLoader.active = true }
            }
        }
    }

    Loader{
        id: likeActLoader
        sourceComponent: LikeAct{
            anchors.fill: parent
            buttonStartSize: parent.width/5
            maxTap: 10
            relaxInterval: 400
            increase: 0.1
        }

        anchors{ top: pageHeader.bottom; bottom: background.bottom;
            left: parent.left; right: parent.right }
        active: false
        z: 5
    }

    DropShadow{
        anchors.fill: popManipItem
        source: popManipItem
        color: "#80000000"
    }
}
