import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtCharts 2.2

import KlimeSoft.SingletonUser 1.0

import "qrc:/qml/elements"

Page{

    objectName: "memePage"

    property alias img: image.source
    property alias name: memeNameLabel.text

    property var memePopValues:[]
    property int memeStartPopValue

    property color mainColor: "#507299"
    //property color backColor: "#78909C"
    property color backColor: "#edeef0"
    property int itemSpacing: 0//pageHeader.height * 1/4

    property int timePeriod: 10


    Component.onCompleted:{
        User.getMemeDataForUser(name.toString())
        getMemeDataTimer.start()
    }

    Timer{
        id: getMemeDataTimer
        interval: 10000
        repeat: true
        onTriggered:{
            console.log(stackView.currentItem.objectName)
            //console.log("stackView.currentItem: ", stackView.currentItem, " ------- memePage: ", memePage)
            if(stackView.currentItem.objectName == "memePage"){
                console.log("GET MEME DATA TIMER")
                User.getMemeDataForUser(name.toString())
            }
        }
    }

    onMemePopValuesChanged: {

        popGraphLineSeries.clear()

        for(var i = 0; i < memePopValues.length; i++){
            //popGraphLineSeries.append(i * timePeriod, memePopValues[i])
            console.log("point of LINE SERIES: ", popGraphLineSeries.at(i),
                " ---- ", "point of MEME VALUES: ", memePopValues[i])
            if(popGraphLineSeries.at(i).y !== memePopValues[i])
                popGraphLineSeries.insert(i, i * timePeriod, memePopValues[i])
        }

        console.log("POPVALUES CHANGED ...........................JJJJJJJJLJL")
    }

    Connections{
        target: User
        onMemePopValuesForUserUpdated:{
            console.log("UPDATING MEME WITH NAME: ", memeName)
            if(memeName == memeNameLabel.text){
                console.log("qqqqqqqqqqqqqqqqqqqqqqqq")
                memePopValues = popValues
            }
        }
    }

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
            id: memeNameLabel
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.top;
                topMargin: height/4 }
            text: "Meme's name"//ServerConnection.user_name
            font.pixelSize: parent.height/2
        }

        MouseArea{
            anchors.fill: parent
            onClicked:{
                stackView.pop()
            }
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
            //source: "qrc:/memePhoto/respectMeme.jpg"
        }
    }

    Rectangle{
        id: popGraphItem
        width: parent.width
        height: parent.height * 3/8
        anchors.top: imageItem.bottom
        color: backColor


        property var popValues: []
        clip: true

        ChartView{
            id: popGraph
            //title: "Популярность мема:"
            anchors.fill: parent
            antialiasing: true
            legend.visible: false
            margins{ top: 0; bottom: 0; left: 0; right: 0 }
            backgroundRoundness: 0.0

            //animationOptions: ChartView.AllAnimations
            ValueAxis{
                id: xAxis
                min: 0.0
                max: 5.0 * timePeriod
                labelsVisible: false
                gridVisible: false
                visible: false
            }
            ValueAxis{
                id: yAxis
                min: -200.0
                max: 200.0
                labelsVisible: false
                gridVisible: false
                visible: false
            }

            LineSeries{
                id: popGraphLineSeries
                axisX: xAxis
                axisY: yAxis
                pointsVisible: true
            }
            LineSeries{
                id: startPopValueLine
                XYPoint{ x: xAxis.min; y: memeStartPopValue }
                XYPoint{ x: xAxis.max; y: memeStartPopValue }
                color: "red"
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
            label: "Накрутить лайки"

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
