import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import KlimeSoft.SingletonUser 1.0

import QtFirebase 1.0

import "qrc:/qml/elements"

Page {
    id:mainUserPage

    objectName: "mainUserPage"

    property string userPopValue: "100"
    property int userCreativity: 0
    property string userShekels: "100"

    property color backColor: "#edeef0"
    property color itemColor: "white"

    property var memesPopValues: []
    property var startPopValues: []

    property string directionFormat

    property Item slidingMenu

    property bool avatarPosFixation: true

    property int clickedMemeOnList
    property int clickedMemeImageSize


    function valueToShort(value){
        var count = 0
        while(Math.floor(value / 1000) > 0){
            count++
            value = Math.floor(value / 1000)
            print(value)
        }
        for(var i = 0; i < count; i++)
            value += 'K'
        return value
    }


    function courseWithSign(direction){
        if(direction > 0)
            directionFormat = '+' + direction.toString()
        else
            directionFormat = direction.toString()
        return directionFormat
    }

    function updateMeme(meme_name, image_name, crsDir, /*memeFeedbackRate,*/ memeCreativity){
        if(!findMeme(meme_name)){
            memeListModel.append({ "memeNameText": meme_name, "courseDirectionText": courseWithSign(crsDir),
                                   "imageNameText": image_name, "image": "image://meme/" + image_name,
                                   /*"memeFeedbackRateText": memeFeedbackRate,*/ "memeCreativityText": memeCreativity
                                 })
        }

        console.log("update Meme: ", image_name)
    }

    function updateMemeImage(meme_name, image_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeNameText === meme_name){
                memeListModel.setProperty(i, "image", " ")
                memeListModel.setProperty(i, "image", "image://meme/" + image_name)
            }
    }

    function updatePopValues(meme_name, crsDir){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeNameText === meme_name){
                memeListModel.setProperty(i, "courseDirectionText", courseWithSign(crsDir))
            }
    }

    function unforceMeme(meme_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeNameText === meme_name){
                memeListModel.remove(i)
            }
    }

    function findMeme(meme_name){
        for(var i = 0; i < memeListModel.count; i++){
            if(memeListModel.get(i).memeNameText === meme_name)
                return true
        }
        return false
    }

    Connections{
        target: User
        onMemeForUserReceived:{
            var crsDir = Math.ceil(popValues[popValues.length - 1] * (1 + parseFloat(memeCreativity / 100))/*memeFeedbackRate*/ - startPopValue)
            updateMeme(memeName, imageName, crsDir, /*memeFeedbackRate,*/ memeCreativity)
            memesPopValues[memeName] = popValues
            startPopValues[memeName] = startPopValue
        }
        onMemePopValuesForUserUpdated:{
            var crsDir = Math.ceil(popValues[popValues.length - 1] * (1 + parseFloat(memeCreativity / 100))/*memeFeedbackRate*/ - startPopValue)
            updatePopValues(memeName, crsDir, startPopValue)
            memesPopValues[memeName] = popValues
            startPopValues[memeName] = startPopValue
        }
        onMemeImageReceived:{
            updateMemeImage(memeName, imageName)
        }
        onPopValueChanged:{
            userPopValue = valueToShort(User.pop_values)
        }
        onCreativityChanged:{
            userCreativity = User.creativity
        }
        onShekelsChanged:{
            userShekels = valueToShort(User.shekels)
        }
        onMemeUnforced:{
            unforceMeme(memeName)
        }
    }

    Connections{
        target: stackView
        onCurrentItemChanged: {
            if(stackView.currentItem.objectName == "mainUserPage"){
                User.localUpdateUserData()
            }
        }
    }

    Component.onCompleted:{
        User.getUserData()
        getUserDataTimer.start()
    }

    Timer{
        id: getUserDataTimer
        interval: 10000
        repeat: true
        onTriggered:{
//            if(stackView.currentItem.objectName == "mainUserPage"){
                console.log("GET USER DATA TIMER")
                User.getUserData()
                if(!creativeInd.running)
                    creativeInd.running = true
//            }
        }
    }

    states: [
        State{
            name: "normal"
            AnchorChanges{ target: pageHeader; anchors.top: background.top }
            AnchorChanges{ target: pageHeader; anchors.bottom: undefined }
            AnchorChanges{ target: userPanel; anchors.bottom: undefined }
//            PropertyChanges{ target: userPanel; y: pageHeader.y + height / 2 }
            AnchorChanges{ target: appListView; anchors.top: pageHeader.bottom }
            StateChangeScript{ name: "avatarFixationScript"; script: avatarPosFixation = true }
        },
        State{
            name: "hidden"
            AnchorChanges{ target: pageHeader; anchors.bottom: background.top }
            AnchorChanges{ target: userPanel; anchors.bottom: pageHeader.top }
            AnchorChanges{ target: appListView; anchors.top: background.bottom }
            StateChangeScript{ name: "avatarFixationScript"; script: avatarPosFixation = false }
        }
    ]
    state: "hidden"

    transitions: [
        Transition {
            from: "hidden"; to: "normal"
            SequentialAnimation{
                AnchorAnimation{ duration: 750; easing.type: Easing.InOutElastic; easing.period: 1.0; easing.amplitude: 1.0 }
                ScriptAction{ scriptName: "avatarFixationScript" }
            }
        },
        Transition {
            from: "normal"; to: "hidden"
            SequentialAnimation{
                ScriptAction{ scriptName: "avatarFixationScript" }
                AnchorAnimation{ duration: 750; easing.type: Easing.InOutElastic; easing.period: 1.0; easing.amplitude: 1.0 }
            }
        }
    ]

    Rectangle{
        id: background
        anchors.fill: parent
        z: -2
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
        anchors.fill: pageHeader
        //verticalOffset: staticLine.height * 1/5
        radius: 13
        samples: 17
        color:"#000000"
        source: pageHeader
        opacity: 0.5
        z: avatarMask.z + 1/*pageHeader.z - 1*/
    }

    Rectangle{
        id:userPanel
        width: parent.width
        height: (parent.height * 1/5)
        //anchors.top: pageHeader.bottom
        y: pageHeader.y + height / 2
        z: pageHeader.z - 3
        color:"#507299"

        states: [
            State{
                when: appListView.contentY <= (appListView.originY - userPanel.height)
                name: "normalState"
                PropertyChanges { target: userPanel; y: pageHeader.y + height / 2 }
            },
            State{
                when: appListView.contentY > (appListView.originY - userPanel.height)
                name: "scrollUpState"
                PropertyChanges{ target: userPanel; y: - appListView.contentY - userPanel.height / 2 }
                //PropertyChanges{ target: avatar; y: pageHeader.y}
            }
        ]
        state: "normalState"
    }

    Image {
        id: avatar
        visible:false
        width: Math.ceil(userPanel.height * 0.95)
        height: width
        x: userPanel.x + (userPanel.width - width) / 2
        y: userPanel.y + (userPanel.height - height) / 2


        source: "qrc:/photo/sexyPhoto.jpg"
        states:[
            State{
                when: !avatarPosFixation && (userPanel.y + userPanel.height / 2) > (pageHeader.y + pageHeader.height)
                name: "normal"
                PropertyChanges{ target: avatar; y: userPanel.y + (userPanel.height - height) / 2 }
                PropertyChanges{ target: avatarLable; flipped: false}
            },
            State{
                when: avatarPosFixation && ((userPanel.y + userPanel.height / 2) < (pageHeader.y + pageHeader.height))
                name: "tapToTop"
                AnchorChanges{ target: avatar; anchors.verticalCenter: pageHeader.bottom }
                PropertyChanges{ target: avatarLable; flipped: true }
            }
        ]
        state: "normal"
    }

    function goToBegin(){
        listViewAnim.running = false
        var pos = appListView.contentY
        var destPos
        appListView.positionViewAtIndex(0, ListView.Center)
        destPos = appListView.contentY
        listViewAnim.from = pos
        listViewAnim.to = destPos
        listViewAnim.running = true
    }

    MouseArea{
        z: pageHeader.z
        anchors.fill: avatar
        onClicked:{
            if(avatar.state == "tapToTop"){
                goToBegin()
            }
        }
    }

    OpacityMask{
        id: avatarMask
        anchors.fill: avatar
        source: bluredAvatar
        z: pageHeader.z - 2
        maskSource:Rectangle{
            width: avatar.width
            height: width
            radius: width
        }
    }

    Item{
        id: blurMask
        width: avatar.width
        height: avatar.height
        visible: false
        clip: true
        Rectangle{
            width: parent.width
            height: Math.ceil(parent.height / 2)
            anchors.bottom: parent.bottom
        }
    }

    MaskedBlur{
        id: bluredAvatar
        anchors.fill: avatar
        source: avatar
        maskSource: blurMask
        radius: 10
        samples: 21
        visible: false
        cached: true
    }

    Item{
        anchors.fill: avatar
        z: pageHeader.z - 1
        Rectangle{
            height: Math.floor(parent.height / 2)
            width: parent.width
            anchors.bottom: parent.bottom
            color: "#505050"
            opacity: 0.4
        }

        layer.enabled: true
        layer.effect: OpacityMask{
            maskSource:Rectangle{
                height: avatar.height
                width: avatar.width
                radius: width
            }
        }
    }

    Flipable{
        id: avatarLable
        width: avatar.width / 4
        height: avatar.height / 4
        anchors{ bottom: avatar.bottom; bottomMargin: height / 2; horizontalCenter: avatar.horizontalCenter}
        z: pageHeader.z + 2

        property bool flipped: false

        front: Text{
            text: userPopValue
            width: parent.width
            height: parent.height
            font.pixelSize: parent.height
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"
        }
        back: Image{
            width: Math.ceil(parent.width * 1.25)
            height: Math.ceil(parent.height * 1.25)
            anchors{ horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            source: "qrc:/uiIcons/up-arrow.svg"
            antialiasing: true
        }

        transform: Rotation{
            id: rotation
            origin.x: avatarLable.width / 2
            origin.y: avatarLable.height / 2
            axis{ x: 1; y: 0; z: 0 }
            angle: 0
        }
        states: State{
            name: "back"
            PropertyChanges{ target: rotation; angle: 180 }
            when: avatarLable.flipped
        }
        transitions: Transition{
            NumberAnimation{ target: rotation; property: "angle"; duration: 350 }
        }
    }

    /////////////////////////////////////////////////////////////////////////
    Rectangle{
        id: moneyInd
        width: (avatar.height * 1 / 2)
        height: width
        anchors.verticalCenter: userPanel.verticalCenter
        anchors.left: avatar.right
        anchors.leftMargin: width * 1 / 2
        z: userPanel.z + 1
        color: "#fdd835"
        radius: width / 2
        Text{
            id: moneyLabel
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.bottom }
            font.pixelSize: parent.height / 5
            text: userShekels.toString()
            color: "#ffffff"
        }
    }
    ////////////////////////////////////////////////////////////////////////
//    Rectangle{
//        id:creativeInd
//        width: (avatar.height * 1/2)
//        height: width
//        anchors.verticalCenter: userPanel.verticalCenter
//        anchors.right: avatar.left
//        anchors.rightMargin: width * 1/2
//        z: userPanel.z + 1
//        color:"lime"
//        radius: width/2
//        Text{
//            id: creativityLabel
//            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.bottom }
//            font.pixelSize: parent.height / 5
//            text: userCreativity.toString()
//            color: "#ffffff"
//        }
//    }
    WaveIndicator{
        id: creativeInd
        width: (avatar.height * 1 / 2)
        height: width
        anchors.verticalCenter: userPanel.verticalCenter
        anchors.right: avatar.left
        anchors.rightMargin: width * 1 / 2
        z: userPanel.z + 1
        itemColor: "#00BCD4"

        amount: userCreativity
        Text{
            id: creativityLabel
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.bottom }
            font.pixelSize: parent.height / 5
            text: userCreativity.toString()
            color: "#ffffff"
        }
    }

//    DropShadow{
//        anchors.fill: userPanel
//        source: userPanel
//        radius: 13
//        samples: 17
//        color: "#000000"
//        opacity: 0.8
//        spread: 0.4
//        z: userPanel.z - 1
//    }

    ListView {
        id: appListView
        height: parent.height - pageHeader.height
        width: parent.width
        spacing: parent.height/50
        anchors{
            top: pageHeader.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        topMargin: userPanel.height

        model: memeListModel

        delegate: Rectangle{
            width: userPanel.width
            height: userPanel.height
            color: itemColor

            Image{
                id: memeImage
                height: parent.height
                width: height
                cache: false
                source: image
            }
            Rectangle{
                id: unforceButton
                width: memeImage.width
                height: memeImage.height
                anchors.centerIn: memeImage
                opacity: 0.5
                radius: width
                color: "#000000"
            }

            Text{
                id: memeNameLabel
                text: memeNameText
                anchors{ left: memeImage.right; top: parent.top }
            }
            Text{
                id: courseDirectionLabel
                text: courseDirectionText
                anchors{ right: parent.right; verticalCenter: parent.verticalCenter }

                onTextChanged:{
                    if(text.charAt(0) == "-"){
                        color = "red"
                    }
                    else{
                        color = "green"
                    }
                }
            }
            Text{
                id: memeCreativityLabel
                text: memeCreativityText
                anchors{ top: courseDirectionLabel.bottom; right: parent.right }
                color: "#00BCD4"
            }
//            Text{
//                text: memeFeedbackRateText
//                anchors{ top: memeCreativityLabel.bottom; right: parent.right }
//                color: "#000000"
//            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    clickedMemeOnList = memeImage.mapToItem(mainUserPage, memeImage.x, memeImage.y).y
                    clickedMemeImageSize = memeImage.width
                    stackView.push({item: memePage, properties: {img: memeImage.source, name: memeNameText,
                                    memePopValues: memesPopValues[memeNameText], memeStartPopValue: startPopValues[memeNameText],
                                    memeCreativity: Number(memeCreativityText)/*, memeFeedbackRate: parseFloat(memeFeedbackRateText)*/}})
                }
            }
            MouseArea{
                anchors.fill: unforceButton
                onClicked:{
                    User.unforceMeme(memeNameText)
                }
            }
        }
        NumberAnimation{ id: listViewAnim; target: appListView; property: "contentY"; duration: 400;
            easing.type: Easing.InOutQuad }
    }
    ListModel{
        id: memeListModel
    }

    AdMobRewardedVideoAd {
        id: rewardedVideoAd

        adUnitId: "ca-app-pub-3940256099942544/5224354917"
//            Qt.platform.os == "android" ? "ca-app-pub-6606648560678905/5628948780" : "ca-app-pub-6606648560678905/2850564595"

        onReadyChanged: if(ready) load()

        onClosed: load()

        request: AdMobRequest {
            gender: AdMob.GenderUnknown
            childDirectedTreatment: AdMob.ChildDirectedTreatmentUnknown

            // NOTE remember JS Date months are 0 based
            // 8th of December 1979:
            birthday: new Date(1979,11,8)

            keywords: [
                "Qt",
                "Firebase"
            ]

            extras: [
                { "something_extra1": "extra_stuff1" },
                { "something_extra2": "extra_stuff2" }
            ]
        }

        onError: {
            App.log("RewardedVideoAd failed with error code",code,"and message",message)

            // See AdMob.Error* enums
            if(code === AdMob.ErrorNetworkError)
                App.log("No network available");
        }

        onPresentationStateChanged: {
            if(state === AdMobRewardedVideoAd.PresentationStateHidden)
                App.log("AdMobRewardedVideoAd","::onPresentationStateChanged","PresentationStateHidden")
            if(state === AdMobRewardedVideoAd.PresentationStateCoveringUI)
                App.log("AdMobRewardedVideoAd","::onPresentationStateChanged","PresentationStateCoveringUI");
        }
        onLoading: {
            showFullScreen()
        }
    }
}
