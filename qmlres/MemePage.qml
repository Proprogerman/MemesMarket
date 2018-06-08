import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtCharts 2.2

import KlimeSoft.SingletonUser 1.0

import "qrc:/qml/elements"

Page{
    id: memePage

    objectName: "memePage"
    background: backgroundItem

    property alias img: image.source
    property alias name: memeNameLabel.text
    property string category

    property var memePopValues:[]
    property int memeStartPopValue: 0

    property int userCreativity: User.creativity
    property int userShekels: User.shekels

    property int memeCreativity: 0
    property double memeFeedbackRate: 0

    onMemeFeedbackRateChanged: {
        console.log("memeFeedbackRate: ", memeFeedbackRate)
    }

    property color mainColor: "#507299"
    property color backColor: "#edeef0"
    property int itemSpacing: 0//pageHeader.height * 1/4

    property int timePeriod: 10

    property int minValue: 0
    property int maxValue: 0
    property int currentValue: 0

    property bool axisCondition: true


    function updateMemePopGraph(){
        popGraphLineSeries.clear()
        minValue = memePopValues[0]
        maxValue = memePopValues[0]
        if(state == "mine")
            setStartPopValueAxis()
        currentValue = memePopValues[memePopValues.length - 1]
        for(var i = 0; i < memePopValues.length; i++){
            if(memePopValues[i] < minValue)
                minValue = memePopValues[i]
            if(memePopValues[i] > maxValue)
                maxValue = memePopValues[i]
            popGraphLineSeries.insert(i, i * timePeriod, Math.ceil(memePopValues[i] * (1 + parseFloat(memeCreativity / 100))))
        }
        setYAxis()
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

    function showLikesIncrement(shekels){
        if(shekels !== 0){
            likesIncrement.clear()
            var popCount = popGraphLineSeries.count - 1
//            var pop = shekels * (1 + memeCreativity / 100)
            var pop = shekels + memeCreativity
            likesIncrement.append(popGraphLineSeries.at(popCount).x, popGraphLineSeries.at(popCount).y)
            likesIncrement.append((popCount + 1) * timePeriod, popGraphLineSeries.at(popCount).y + pop)
            likesIncrement.visible = true
        }
        else
            likesIncrement.visible = false
    }

    function showCreativityEffect(creativity){
        if(creativity !== 0){
            creativityEffect.clear()
            for(var i = 0; i < popGraphLineSeries.count; i++){
                var creativityFactor = parseFloat(creativity / 100)
                creativityEffect.append(popGraphLineSeries.at(i).x, popGraphLineSeries.at(i).y * (1 + creativityFactor))
                creativityEffect.visible = true
            }
        }
        else
            creativityEffect.visible = false
    }

    function setYAxis(){
        var diff
        var minElement
        var maxElement

        if(memePage.state == "mine"){
            minElement = minValue < memeStartPopValue ? minValue : memeStartPopValue
            maxElement = maxValue > memeStartPopValue ? maxValue : memeStartPopValue
        }
        else{
            minElement = minValue
            maxElement = maxValue
        }
        diff = maxElement !== minElement ? (maxElement - minElement) : 100

        if(radioButtons.value == 0){
            if(axisCondition){
                yAxis.max = Math.ceil(maxElement + diff / 2)
                yAxis.min = Math.ceil(minElement - diff / 2)
                axisCondition = false
            }
            else if(maxElement > yAxis.max){
                yAxis.max += Math.ceil((maxElement - yAxis.max) * 1.25)
                yAxis.min += Math.ceil((maxElement - yAxis.max) * 1.25)
            }
            else if(minElement < yAxis.min){
                yAxis.min -= Math.ceil((yAxis.min - minElement) * 1.25)
                yAxis.max -= Math.ceil((yAxis.min - minElement) * 1.25)
            }
        }
        else if(memePage.state == "mine" && radioButtons.value != 0){
            yAxis.max = Math.ceil(maxElement + userShekels * 1.25)
            yAxis.min = Math.ceil(minElement - diff / 2)
            axisCondition = true
        }
        else if(memePage.state == "general" && radioButtons.value != 0){
            yAxis.max = Math.ceil(maxElement * (1 + userCreativity / 100 * 1.25))
            yAxis.min = Math.ceil(minElement - diff / 2)
            axisCondition = true
        }
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
        if(state == "mine")
            showLikesIncrement(radioButtons.value)
        else
            showCreativityEffect(radioButtons.value)
    }

    onMemeStartPopValueChanged: {
        setStartPopValueAxis()
        console.log("MEME START POP VALUE", memeStartPopValue)
    }

    Connections{
        target: User
        onMemePopValuesForUserUpdated:{
            console.log("UPDATING MEME WITH NAME: ", memeName)
            if(memeName == memeNameLabel.text){
                console.log("qqqqqqqqqqqqqqqqqqqqqqqq")
                memePopValues = popValues
                memeStartPopValue = startPopValue
                setYAxis()
            }
        }
        onMemePopValuesUpdated:{
            console.log("UPDATING MEME WITH NAME: ", memeName)
            if(memeName == memeNameLabel.text){
                console.log("pppppppppppppppppppppppp")
                memePopValues = popValues
                setYAxis()
            }
        }
        onCreativityChanged:{
            userCreativity = User.creativity
            if(memePage.state == "general"){
                setRadioButtonsItems(userCreativity)
            }
            setYAxis()
        }
        onShekelsChanged:{
            userShekels = User.shekels
            if(memePage.state == "mine"){
                setRadioButtonsItems(userShekels)
            }
            setYAxis()
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
        id: backgroundItem
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
        id: headerShadow
        anchors.fill: pageHeader
        //verticalOffset: staticLine.height * 1/5
        radius: Math.floor(pageHeader.height / 10)
        samples: radius * 2 + 1
        color:"#000000"
        source: pageHeader
        opacity: 0.5
        z: 3
    }
    Rectangle{
        id: imageItem
        width: parent.width
        height: Math.ceil(width / 2)
        anchors.top: pageHeader.bottom
        //anchors.topMargin:
        color: backColor//"white"
    }
    Item{
        height: imageItem.height
        width: height
        anchors.centerIn: imageItem
        Image {
            id: image
            anchors.fill: parent
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
                    memeCreativity = 0
                    memeStartPopValue = 0
                    updateMemePopGraph()
                }
            }
        }
    }

    Rectangle{
        id: popGraphItem
        width: parent.width
        height: parent.height * 3/8
        anchors.top: imageItem.bottom
//        anchors.bottom: manipItem.top
        color: backColor

        clip: true

        ChartView{
            id: popGraph
            //title: "Популярность мема:"
            anchors.fill: parent
            antialiasing: true
            legend.visible: false
            margins{ top: 0; bottom: 0; left: 0; right: 0 }
            backgroundRoundness: 0.0

//            animationOptions: ChartView.AllAnimations
            animationOptions: ChartView.NoAnimation
            ValueAxis{
                id: xAxis
                min: 0.0
                max: 13.0 * timePeriod
                labelsVisible: false
                gridVisible: false
                visible: false
            }

            LineSeries{
                id: popGraphLineSeries
                axisX: xAxis
                axisY: yAxis
                pointsVisible: false
            }

            LineSeries{
                id: startPopValueLine
                XYPoint{ id: xy1; x: xAxis.min; y: memeStartPopValue }
                XYPoint{ id: xy2; x: xAxis.max; y: memeStartPopValue }
                color: "blue"
            }

            LineSeries{
                id: likesIncrement
                color: "#fdd835"
                visible: false
            }

            LineSeries{
                id: creativityEffect
                color: "#00BCD4"
                visible: false
                pointsVisible: true
            }

            ValueAxis{
                id: yAxis
                min: 0
                max: 0
                labelsVisible: false
                gridVisible: false
                visible: false
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
        height: pageHeader.height * 2
        anchors{ top: popGraphItem.bottom; bottom: parent.bottom;
            left: parent.left; right: parent.right }
        color: backColor

        RadioButtons{
            id: radioButtons
            width: parent.width;
//            height: memeActionButton.height
            anchors.top: parent.top
            anchors.bottom: memeActionButton.top
            anchors.horizontalCenter: parent.horizontalCenter
            itemUncheckedColor: "#ECEFF1"
            itemCheckedColor: "#607D8B"
            backgroundColor: backColor
            spacing: width/70

            onCheckedItemChanged:{
                if(memePage.state == "mine"){
                    memeActionButton.clickable = radioButtons.checkedItem != 0 ? true : false
                }
                else{
                    memeActionButton.clickable = true
                }
            }
            onValueChanged: {
                if(memePage.state == "mine"){
                    showLikesIncrement(value)
                    creativityEffect.visible = false
                }
                else{
                    showCreativityEffect(value)
                    likesIncrement.visible = false
                }
                setYAxis()
            }
        }

        MaterialButton{
            id: memeActionButton
            width: parent.width
            height: pageHeader.height
            anchors{
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
    //        color: "#F48FB1"
            radius: height / 20
            labelSize: height / 4
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

//    Loader{
//        id: likeActLoader
//        sourceComponent: LikeAct{
//            anchors.fill: parent
//            buttonStartSize: parent.width/5
//            maxTap: 10
//            relaxInterval: 400
//            increase: 0.1
//        }

//        anchors{ top: pageHeader.bottom; bottom: background.bottom;
//            left: parent.left; right: parent.right }
//        active: false
//        z: 5
//    }

    states:[
        State{
            name: "general"
            PropertyChanges{ target: memeActionButton; label: "ЗАФОРСИТЬ" }
            PropertyChanges{ target: memeActionButton; clickable: true }
            PropertyChanges{ target: radioButtons; itemCheckedColor: "#00bcd4"; itemUncheckedColor: "#62efff"}
            PropertyChanges{ target: radioButtons; activeButton: 0 }
            PropertyChanges{ target: unforceButton; visible: false }
            PropertyChanges{ target: startPopValueLine; visible: false }
            PropertyChanges{ target: memePage; memeStartPopValue: 0 }
//            PropertyChanges{
//                target: yAxis
//                max: minValue != maxValue ?
//                         maxValue * (1 + userCreativity / 100 * 1.25):
//                         maxValue * 2
//                min: minValue != maxValue ? minValue - (maxValue - minValue) * 0.25 : minValue / 2

//            }
            StateChangeScript{ script: setYAxis() }
            StateChangeScript{ script: setRadioButtonsItems(userCreativity)}
        },
        State{
            name: "mine"
            PropertyChanges{ target: memeActionButton; label: "НАКРУТИТЬ ЛАЙКИ" }
            PropertyChanges{ target: radioButtons; itemCheckedColor: "#fdd835"; itemUncheckedColor: "#ffff6b"}
            PropertyChanges{ target: radioButtons; activeButton: 1 }
            PropertyChanges{ target: unforceButton; visible: true }
            PropertyChanges{ target: startPopValueLine; visible: true }
//            PropertyChanges{ target: memePage; memeStartPopValue: memePopValues[memePopValues.length - 1] }
            StateChangeScript{ script: setRadioButtonsItems(userShekels)}
//            PropertyChanges{
//                target: yAxis
//                max: currentValue + userShekels * 1.25
//                min: memeStartPopValue - max
//            }
            StateChangeScript{ script: setYAxis() }
            StateChangeScript{ script: setStartPopValueAxis() }
        },
        State{
            name: "hidden"
            PropertyChanges{ target: pageHeader; visible: false }
            PropertyChanges{ target: popGraphItem; visible: false }
            PropertyChanges{ target: manipItem; visible: false }
            PropertyChanges{ target: backgroundItem; visible: false }
            PropertyChanges{ target: headerShadow; visible: false }
            PropertyChanges{ target: imageItem; visible: false }
            PropertyChanges{ target: hamburger; visible: false }
        },
        State{
            name: "normal"
            PropertyChanges{ target: pageHeader; visible: true }
            PropertyChanges{ target: popGraphItem; visible: true }
            PropertyChanges{ target: manipItem; visible: true }
            PropertyChanges{ target: backgroundItem; visible: true }
            PropertyChanges{ target: headerShadow; visible: true }
            PropertyChanges{ target: imageItem; visible: true }
            PropertyChanges{ target: hamburger; visible: true }
        }
    ]
    state: "mine"

    Connections{
        target: memeActionButton.buttArea
        onClicked: {
            //likeActLoader.active = true
            if(state == "general"){
                memeCreativity = radioButtons.value
                memeStartPopValue = memePopValues[memePopValues.length - 1]
                User.forceMeme(name, memeCreativity, memeStartPopValue, category)
                updateMemePopGraph()
                state = "mine"
            }
            else if(state == "mine"){
                User.increaseLikesQuantity(name, radioButtons.value)
            }
            setYAxis()
        }
    }
}
