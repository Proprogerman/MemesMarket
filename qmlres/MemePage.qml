import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtCharts 2.2

import KlimeSoft.SingletonUser 1.0

import "qrc:/qml/elements"

Page{
    id: memePage

    objectName: "memePage"

    property alias img: image.source
    property alias name: memeNameLabel.text
    property string category

    property var memePopValues:[]
    property int memeStartPopValue: state == "mine" ? memePopValues[memePopValues.length - 1] : 0

    property int userCreativity: User.creativity
    property int userShekels: User.shekels

    property color mainColor: "#507299"
    property color backColor: "#edeef0"
    property int itemSpacing: 0//pageHeader.height * 1/4

    property int timePeriod: 10

    function updateMemePopGraph(){
        popGraphLineSeries.clear()
        for(var i = 0; i < memePopValues.length; i++){
            popGraphLineSeries.insert(i, i * timePeriod, memePopValues[i])
        }
    }


    function setRadioButtonsItems(source){
        radioButtons.button1Label = Math.floor(source / 4)
        radioButtons.button2Label = Math.floor(source / 3)
        radioButtons.button3Label = Math.floor(source / 2)
        radioButtons.button4Label = source
    }

    function setStartPopValueAxis(){
        startPopValueLine.clear()
        startPopValueLine.append(xAxis.min, memeStartPopValue)
        startPopValueLine.append(xAxis.max, memeStartPopValue)
    }

    Component.onCompleted:{
        if(state == "mine")
            User.getMemeDataForUser(name.toString())
        else if(state == "general")
            User.getMemeData(name.toString())
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
                if(memePage.state == "mine")
                    User.getMemeDataForUser(name.toString())
                else if(memePage.state == "general")
                    User.getMemeData(name.toString())
            }
        }
    }

    onMemePopValuesChanged: {
        updateMemePopGraph()
        console.log("POPVALUES CHANGED ...........................JJJJJJJJLJL")
    }

    onMemeStartPopValueChanged: {
        setStartPopValueAxis()
    }

    Connections{
        target: User
        onMemePopValuesForUserUpdated:{
            console.log("UPDATING MEME WITH NAME: ", memeName)
            if(memeName == memeNameLabel.text){
                console.log("qqqqqqqqqqqqqqqqqqqqqqqq")
                memePopValues = popValues
                memeStartPopValue = startPopValue
            }
        }
        onMemePopValuesUpdated:{
            console.log("UPDATING MEME WITH NAME: ", memeName)
            if(memeName == memeNameLabel.text){
                console.log("pppppppppppppppppppppppp")
                memePopValues = popValues
            }
        }
        onCreativityChanged:{
            userCreativity = User.creativity
            if(memePage.state == "general")
                setRadioButtonsItems(userCreativity)
        }
        onShekelsChanged:{
            userShekels = User.shekels
            if(memePage.state == "mine")
                setRadioButtonsItems(userShekels)
        }
    }

    Hamburger{
        id: hamburger
        height: pageHeader.height / 4
        width: height * 3 / 2
        y: pageHeader.y + Math.floor(pageHeader.height / 2) - height
        anchors{ left: pageHeader.left; leftMargin: width; /*verticalCenter: pageHeader.verticalCenter*/ }
        z: pageHeader.z + 1
        dynamic: false
        onBackAction: stackView.pop()
    }

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

//        MouseArea{
//            anchors.fill: parent
//            onClicked:{
//                stackView.pop()
//            }
//        }
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
        Rectangle{
            id: unforceButton
            width: image.width
            height: image.height
            anchors{ left: image.left; bottom: image.bottom }
            opacity: 0.5
            radius: width
            color: "#000000"
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    User.unforceMeme(name)
                    memePage.state = "general"
                }
            }
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
            animationOptions: ChartView.NoAnimation
            ValueAxis{
                id: xAxis
                min: 0.0
                max: 13.0 * timePeriod
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
                id: zeroPopValueLine
                XYPoint{ x: xAxis.min; y: 0 }
                XYPoint{ x: xAxis.max; y: 0 }
                color: "red"
            }
            LineSeries{
                id: startPopValueLine
                XYPoint{ id: xy1; x: xAxis.min; y: 50/*memeStartPopValue*/ }
                XYPoint{ id: xy2; x: xAxis.max; y: 50/*memeStartPopValue*/ }
                color: "blue"
            }
//            LineSeries{
//                id: startPopValueLine
//                axisY: CategoryAxis{
//                    min: - 200
//                    max: 200
//                    labelsVisible: false
//                    gridVisible: false
//                    gridLineColor: "red"
//                    minorGridLineColor: "blue"
//                    titleVisible: false
//                    CategoryRange{
//                        id: startPopValueRange
//                        endValue: memeStartPopValue
//                    }
//                }
//            }
        }
    }

    Rectangle{
        id: manipItem
        anchors{ top: popGraphItem.bottom; bottom: parent.bottom;
            left: parent.left; right: parent.right }
        color: backColor

        RadioButtons{
            id: radioButtons
            width: parent.width;
            height: 100;
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            uncheckedColor: "#ECEFF1"
            checkedColor: "#607D8B"
            backgroundColor: backColor
            spacing: width/70

            Component.onCompleted:{
                if(memePage.state == "general"){
                    setRadioButtonsItems(userCreativity)
                }
                else if(memePage.state == "mine"){
                    setRadioButtonsItems(userShekels)
                }
                memeActionButton.clickable = true
            }
            onCheckedItemChanged:{
                if(memePage.state == "mine")
                    memeActionButton.clickable = radioButtons.checkedItem != 0 ? true : false
            }
        }

        MaterialButton{
            id: memeActionButton
            width: 200
            height: 100
            anchors{
                top: radioButtons.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
    //        color: "#F48FB1"
            radius: height/ 20
            rippleColor: "#F8BBD0"
            unclickableColor: "#F48FB1"
            clickableColor: "#EC407A"
        }
    }

    DropShadow{
        anchors.fill: manipItem
        source: manipItem
        color: "#80000000"
        visible: manipItem.visible
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

    states:[
        State{
            name: "general"
            PropertyChanges{ target: memeActionButton; label: "ЗАФОРСИТЬ" }
            PropertyChanges{ target: radioButtons; activeButton: 0 }
            PropertyChanges{ target: unforceButton; visible: false }
            PropertyChanges{ target: startPopValueLine; visible: false }
            PropertyChanges{ target: memePage; memeStartPopValue: 0 }
        },
        State{
            name: "mine"
            PropertyChanges{ target: memeActionButton; label: "НАКРУТИТЬ ЛАЙКИ" }
            PropertyChanges{ target: radioButtons; activeButton: 1 }
            PropertyChanges{ target: unforceButton; visible: true }
            PropertyChanges{ target: startPopValueLine; visible: true }
            PropertyChanges{ target: memePage; memeStartPopValue: memePopValues[memePopValues.length - 1] }
            StateChangeScript{ script: setStartPopValueAxis() }
        }
    ]
    state: "mine"

    Connections{
        target: memeActionButton.buttArea
        onClicked: {
            //likeActLoader.active = true
            if(state == "general"){
                User.forceMeme(name, radioButtons.value, memePopValues[memePopValues.length - 1],
                               category)
                state = "mine"
            }
            else if(state == "mine"){
                User.increaseLikesQuantity(name, radioButtons.value)
            }
        }
    }
}
