import QtQuick 2.11
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
    property alias name: pageHeader.headerText
    property string category

    property var memePopValues:[]
    property int memeStartPopValue: 0

    property int userCreativity: User.creativity
    property int userShekels: User.shekels

    property int memeCreativity: 0
    property double memeFeedbackRate: 0

    property color mainColor: "#507299"
    property color backColor: "#edeef0"
    property color goldenColor: "#f9a602"
    property color fadedGoldenColor: "#ffd74a"

    property int itemSpacing: 0

    property int timePeriod: 10

    property int minValue: 0
    property int maxValue: 0
    property int currentValue: 0

    property bool axisCondition: true

    property alias memeImageX: imageItem.x
    property alias memeImageY: imageItem.y
    property alias memeImageScale: imageItem.scale
    property int imageBackY: imageBack.y


    onUserShekelsChanged: {
        if(userShekels === 0)
            memeActionButton.clickable = false
    }

    function updateMemePopGraph(){
        popGraphLineSeries.clear()
        minValue = memePopValues[0] * (1 + memeCreativity / 100)
        maxValue = memePopValues[0] * (1 + memeCreativity / 100)
        if(state == "mine")
            setStartPopValueAxis()
        currentValue = Math.ceil(memePopValues[memePopValues.length - 1] * (1 + memeCreativity / 100))
        for(var i = 0; i < memePopValues.length; i++){
            if(memePopValues[i] * (1 + memeCreativity / 100) < minValue)
                minValue = Math.ceil(memePopValues[i] * (1 + memeCreativity / 100))
            if(memePopValues[i] * (1 + memeCreativity / 100) > maxValue)
                maxValue = Math.ceil(memePopValues[i] * (1 + memeCreativity / 100))
            popGraphLineSeries.insert(i, i * timePeriod, Math.ceil(memePopValues[i] * (1 + memeCreativity / 100)))
        }
        setYAxis()
    }

    function setRadioButtonsItems(source){
        radioButtons.button1Label = Math.floor(source / 4)
        radioButtons.button2Label = Math.floor(source / 3)
        radioButtons.button3Label = Math.floor(source / 2)
        radioButtons.button4Label = source
    }

    function setManipItemColor(){
        if(state === "mine" || User.findMeme(memePage.name)){
            memeActionButton.clickableColor = radioButtons.itemCheckedColor = goldenColor
            memeActionButton.unclickableColor = radioButtons.itemUncheckedColor = fadedGoldenColor
        }
        else {
            memeActionButton.clickableColor = radioButtons.itemCheckedColor = "#00bcd4"
            memeActionButton.unclickableColor = radioButtons.itemUncheckedColor = "#62efff"
        }
    }

    function setStartPopValueAxis(){
        startPopValueLine.clear()
        startPopValueLine.append(xAxis.min, memeStartPopValue)
        startPopValueLine.append(xAxis.max, memeStartPopValue)
    }

    function showPopIncrement(shekels){
        if(shekels !== 0){
            likesIncrement.clear()
            var popCount = popGraphLineSeries.count - 1
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
            diff = maxElement !== minElement ? (maxElement - minElement) : (userShekels != 0 ? userShekels : 100)
        }
        else{
            minElement = minValue
            maxElement = maxValue
            diff = maxElement !== minElement ? (maxElement - minElement) : 100
        }
        if(radioButtons.value == 0){
            if(axisCondition){
                yAxis.max = maxElement + Math.ceil(diff / 2)
                yAxis.min = minElement - Math.ceil(diff / 2)
                axisCondition = false
            }
            else if(maxElement > yAxis.max){
                var maxDiff = Math.ceil((maxElement - yAxis.max) * 1.25)
                yAxis.max += maxDiff
                yAxis.min += maxDiff
            }
            else if(minElement < yAxis.min){
                var minDiff = Math.ceil((yAxis.min - minElement) * 1.25)
                yAxis.min -= minDiff
                yAxis.max -= minDiff
            }
        }
        else if(memePage.state == "mine"){
            var shekelsIncr = Math.ceil(radioButtons.value * 1.25)
            if(yAxis.max <= (currentValue + radioButtons.value)){
                yAxis.max = maxElement + Math.ceil(diff / 2) + shekelsIncr
                yAxis.min = minElement - Math.ceil(diff / 2) + shekelsIncr
            }
            if(yAxis.min >= maxElement){
                yAxis.max = maxElement + Math.ceil(diff / 2) + shekelsIncr
                yAxis.min = minElement - Math.ceil(diff / 2)
            }
            axisCondition = true
        }
        else if(memePage.state == "general"){
            var creativityIncr = Math.ceil(maxElement * radioButtons.value / 100 * 1.25)
            if(yAxis.max <= (maxElement + creativityIncr)){
                yAxis.max = maxElement + Math.ceil(diff / 2) + creativityIncr
                yAxis.min = minElement - Math.ceil(diff / 2) + creativityIncr
            }
            if(yAxis.min >= currentValue){
                yAxis.max = maxElement + Math.ceil(diff / 2) + creativityIncr
                yAxis.min = minElement - Math.ceil(diff / 2)
            }
            axisCondition = true
        }
    }

    function checkShekelsButton(){
        if(state === "mine" && (userShekels === 0 || radioButtons.value === 0))
            memeActionButton.clickable = false
    }

    Component.onCompleted:{
        User.getMemeData(name.toString())
        getMemeDataTimer.start()
    }

    Timer{
        id: getMemeDataTimer
        interval: 10000
        repeat: true
        onTriggered:{
            if(stackView.currentItem.objectName == "memePage"){
                User.getMemeData(name.toString())
            }
        }
    }

    onMemePopValuesChanged: {
        updateMemePopGraph()
        if(state == "mine")
            showPopIncrement(radioButtons.value)
        else
            showCreativityEffect(radioButtons.value)
    }

    onMemeStartPopValueChanged: {
        console.log("meme start pop value", memeStartPopValue)
        setStartPopValueAxis()
    }

    Connections{
        target: User
        onMemeReceived:{
            if(memeName === pageHeader.headerText){
                memePopValues = popValues
                if(memePage.state === "mine" && startPopValue != 0)
                    memeStartPopValue = startPopValue
                updateMemePopGraph()
            }
        }
        onCreativityChanged:{
            userCreativity = User.creativity
            if(memePage.state == "general"){
                setRadioButtonsItems(userCreativity)
            }
            updateMemePopGraph()
        }
        onShekelsChanged:{
            userShekels = User.shekels
            if(memePage.state == "mine"){
                setRadioButtonsItems(userShekels)
            }
            updateMemePopGraph()
        }
    }

    Connections{
        target: stackView
        onCurrentItemChanged: {
            if(stackView.currentItem !== null)
                if(stackView.currentItem.objectName == "memePage")
                    User.localUpdateMeme(name)
        }
    }

    Hamburger{
        id: hamburger
        height: pageHeader.height / 4
        width: height * 3 / 2
        y: pageHeader.y + Math.floor(pageHeader.height / 2) - height
        anchors{ left: pageHeader.left; leftMargin: width }
        z: pageHeader.z + 1
        dynamic: false
        onBackAction: {
            if(stackView.__currentItem.objectName === "memePage"){
                stackView.pop()
                visible = false
            }
        }
    }

    Rectangle{
        id: backgroundItem
        anchors.fill: parent
        color: backColor
    }

    PageHeader{
        id: pageHeader
        width: parent.width
        height: parent.height / 10
        headerText: User.user_name
        z: 7
    }

    DropShadow{
        id: headerShadow
        anchors.fill: pageHeader
        radius: Math.floor(pageHeader.height / 10)
        samples: radius * 2 + 1
        color: "#000000"
        source: pageHeader
        opacity: 0.5
        z: 3
    }
    Rectangle{
        id: imageBack
        width: parent.width
        height: width / 2
        anchors.top: pageHeader.bottom
        //anchors.topMargin:
        color: backColor//"white"
    }
    Item{
        id: imageItem
        height: imageBack.height
        width: height
        x: imageBack.x + imageItem.width / 2
        y: imageBack.y
        transformOrigin: Item.TopLeft
        z: 100
        Image {
            id: image
            anchors.fill: parent
        }
        Rectangle{
            id: unforceButton
            width: image.width
            height: image.height / 2
            anchors{ left: image.left; bottom: image.bottom }
            opacity: 0.7
            color: "#000000"
            layer.enabled: true
            visible: false
            Image{
                source: "qrc:/uiIcons/deleteIcon.svg"
                height: parent.height
                width: height
                anchors.centerIn: parent
            }
            MouseArea{
                anchors.fill: parent
                onClicked:{
                    axisCondition = true
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
        anchors.top: imageBack.bottom
        color: backColor

        clip: true

        ChartView{
            id: popGraph
            anchors.fill: parent
            antialiasing: true
            legend.visible: false
            margins{ top: 0; bottom: 0; left: 0; right: 0 }
            backgroundRoundness: 0.0

            animationOptions: ChartView.NoAnimation

            ValueAxis{
                id: xAxis
                min: 0.0
                max: 13.0 * timePeriod
                labelsVisible: false
//                gridVisible: true
                visible: false
            }
            ValueAxis{
                id: yAxis
                min: 0
                max: 0
                labelsVisible: false
//                gridVisible: true
                visible: false
            }
            AreaSeries{
                id: redZone
                color: "#40ff0000"
                axisX: xAxis
                axisY: yAxis
                upperSeries: startPopValueLine
                visible: false
            }
            LineSeries{
                id: popGraphLineSeries
                axisX: xAxis
                axisY: yAxis
                color: mainColor//"blue"
                width: popGraph.height / 100
            }
            LineSeries{
                id: startPopValueLine
                XYPoint{ id: xy1; x: xAxis.min; y: memeStartPopValue }
                XYPoint{ id: xy2; x: xAxis.max; y: memeStartPopValue }
                color: "green"
            }
            LineSeries{
                id: likesIncrement
                color: goldenColor//"#fdd835"
                visible: false
                width: popGraphLineSeries.width
            }
            LineSeries{
                id: creativityEffect
                color: "#00BCD4"
                visible: false
                pointsVisible: false
                width: popGraphLineSeries.width
            }
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
            width: parent.width
            anchors.top: parent.top
            anchors.bottom: memeActionButton.top
            anchors.horizontalCenter: parent.horizontalCenter
            backgroundColor: backColor
            spacing: width / 70

            onValueChanged: {
                if(memePage.state == "mine"){
                    memeActionButton.clickable = radioButtons.value != 0 ? true : false
                    showPopIncrement(value)
                    creativityEffect.visible = false
                }
                else{
                    memeActionButton.clickable = true
                    showCreativityEffect(value)
                    likesIncrement.visible = false
                }
                checkShekelsButton()
                setYAxis()
            }
            onActiveButtonChanged: {
                checkShekelsButton()
            }
        }

        MaterialButton{
            id: memeActionButton
            width: parent.width
            height: pageHeader.height
            clickable: false
            anchors{
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }
            radius: height / 20
            labelSize: height / 4
        }
    }

    DropShadow{
        id: manipItemShadow
        anchors.fill: manipItem
        source: manipItem
        color: "#80000000"
        visible: manipItem.visible
    }

    states:[
        State{
            name: "general"
            PropertyChanges{ target: memeActionButton; label: "ЗАФОРСИТЬ" }
            PropertyChanges{ target: memeActionButton; clickable: true }
            PropertyChanges{ target: unforceButton; visible: false }
            PropertyChanges{ target: startPopValueLine; visible: false }
            PropertyChanges{ target: redZone; visible: false}
            StateChangeScript{ script: setRadioButtonsItems(userCreativity)}
        },
        State{
            name: "mine"
            PropertyChanges{ target: memeActionButton; label: "НАКРУТИТЬ ЛАЙКИ" }
            PropertyChanges{ target: unforceButton; visible: true }
            PropertyChanges{ target: startPopValueLine; visible: true }
            PropertyChanges{ target: redZone; visible: true }
            StateChangeScript{ script: setRadioButtonsItems(userShekels)}
            StateChangeScript{ script: checkShekelsButton()}
            StateChangeScript{ script: setStartPopValueAxis() }
        },
        State{
            name: "hidden"
            PropertyChanges{ target: pageHeader; opacity: 0 }
            PropertyChanges{ target: popGraphItem; opacity: 0 }
            PropertyChanges{ target: manipItem; opacity: 0 }
            PropertyChanges{ target: manipItemShadow; opacity: 0 }
            PropertyChanges{ target: backgroundItem; opacity: 0 }
            PropertyChanges{ target: headerShadow; opacity: 0 }
            PropertyChanges{ target: imageBack; opacity: 0 }
            PropertyChanges{ target: hamburger; opacity: 0 }
            PropertyChanges{ target: unforceButton; opacity: 0 }
        }
    ]
    state: "hidden"

    onStateChanged:{
        axisCondition = true
        radioButtons.setButtonActive(0)
        setManipItemColor()
        if(state != "hidden")
            updateMemePopGraph()
    }

    transitions: Transition {
        PropertyAnimation{
            property: "opacity"
            duration: 250
        }
    }

    Connections{
        target: memeActionButton.buttArea
        onClicked: {
            axisCondition = true
            if(state == "general"){
                memeCreativity = radioButtons.value
                memeStartPopValue = memePopValues[memePopValues.length - 1]
                User.forceMeme(name, memeCreativity, memeStartPopValue, category)
                state = "mine"
            }
            else if(state == "mine")
                User.increaseLikesQuantity(name, radioButtons.value)
        }
    }
}
