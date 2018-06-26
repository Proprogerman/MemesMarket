import QtQuick 2.11
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0
import QtQuick.Dialogs 1.2

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
    property color mainColor: "#507299"

    property var memesPopValues: []
    property var startPopValues: []

    property string directionFormat

    property Item slidingMenu

    property bool avatarPosFixation: true

    property int clickedMemeOnListY
    property int clickedMemeImageSize


    function valueToShort(num) {
        var digits = 1
        var si = [
            { value: 1, symbol: "" },
            { value: 1E3, symbol: "k" },
            { value: 1E6, symbol: "M" },
        ];
        var rx = /\.0+$|(\.[0-9]*[1-9])0+$/;
        var i;
        for (i = si.length - 1; i > 0; i--) {
            if (num >= si[i].value) {
                break;
            }
        }
        return (num / si[i].value).toFixed(digits).replace(rx, "$1") + si[i].symbol;
    }


    function courseWithSign(direction){
        if(direction > 0)
            directionFormat = '+' + direction.toString()
        else
            directionFormat = direction.toString()
        return directionFormat
    }

    function setMeme(meme_name, image_name, crsDir, memeCreativity, loyalty){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeNameText === meme_name){
                memeListModel.set(i, {"courseDirectionText": courseWithSign(crsDir), "loyaltyText": parseFloat(loyalty / 100),
                                      "memeCreativityText": memeCreativity})
                return;
            }
        memeListModel.append({ "memeNameText": meme_name, "courseDirectionText": courseWithSign(crsDir),
                               "imageNameText": image_name, "image": "image://meme/" + image_name,
                               "memeCreativityText": memeCreativity, "loyaltyText": parseFloat(loyalty / 100),
                             })
    }

    function updateMemeImage(meme_name, image_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeNameText === meme_name){
                memeListModel.setProperty(i, "image", " ")
                memeListModel.setProperty(i, "image", "image://meme/" + image_name)
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

    function setVisibilityImageOnList(mName, vis){
        for(var i = 0; i < appListView.contentItem.children.length; i++){
            if(appListView.contentItem.children[i].name === mName)
                appListView.contentItem.children[i].imageVisible = vis
        }
    }

    function getClosingMemePosition(mName){
        for(var i = 0; i < appListView.contentItem.children.length; i++){
            if(appListView.contentItem.children[i].name === mName){
                var mItem = appListView.contentItem.children[i]
                var currentYPos = mapFromItem(appListView, mItem.x, mItem.y).y
                if(appListView.y > currentYPos - appListView.contentY)
                    appListView.positionViewAtIndex(i, ListView.Beginning)
                else if(appListView.y + appListView.height < currentYPos + mItem.height - appListView.contentY)
                    appListView.positionViewAtIndex(i, ListView.End)
                return clickedMemeOnListY = mapFromItem(appListView, mItem.x, mItem.y).y - appListView.contentY
            }
        }
    }

    Connections{
        target: User
        onMemeReceived:{
            if(User.findMeme(memeName)){
                var crsDir = Math.ceil((popValues[popValues.length - 1] * (1 + parseFloat(memeCreativity / 100)) - startPopValue)
                                       * parseFloat(loyalty / 100))
                memesPopValues[memeName] = popValues
                startPopValues[memeName] = startPopValue
                setMeme(memeName, imageName, crsDir, memeCreativity, loyalty)
            }
        }
        onImageReceived:{
            if(type === "meme")
                updateMemeImage(name, imageName)
            else if(type === "user")
                avatar.source = "image://meme/" + imageName
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
            if(stackView.currentItem !== null)
                if(stackView.currentItem.objectName == "mainUserPage")
                    User.localUpdateUserData()
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
            User.getUserData()
        }
    }

    states: [
        State{
            name: "normal"
            AnchorChanges{ target: pageHeader; anchors.top: background.top }
            AnchorChanges{ target: pageHeader; anchors.bottom: undefined }
            AnchorChanges{ target: userPanel; anchors.bottom: undefined }
            AnchorChanges{ target: appListView; anchors.top: pageHeader.bottom }
            StateChangeScript{ name: "avatarFixationScript"; script: avatarPosFixation = true }
            StateChangeScript{ name: "waveAnimationRunningScript"; script: creativeInd.running = true }
        },
        State{
            name: "hidden"
            AnchorChanges{ target: pageHeader; anchors.bottom: background.top }
            AnchorChanges{ target: userPanel; anchors.bottom: pageHeader.top }
            AnchorChanges{ target: appListView; anchors.top: background.bottom }
            StateChangeScript{ name: "avatarFixationScript"; script: avatarPosFixation = false }
            StateChangeScript{ name: "waveAnimationRunningScript"; script: creativeInd.running = false }
        }
    ]
    state: "hidden"

    transitions: [
        Transition {
            from: "hidden"; to: "normal"
            SequentialAnimation{
                ScriptAction{ scriptName: "waveAnimationRunningScript" }
                AnchorAnimation{ duration: 750; easing.type: Easing.InOutElastic; easing.period: 1.0; easing.amplitude: 1.0 }
                ScriptAction{ scriptName: "avatarFixationScript" }
            }
        },
        Transition {
            from: "normal"; to: "hidden"
            SequentialAnimation{
                ScriptAction{ scriptName: "avatarFixationScript" }
                AnchorAnimation{ duration: 750; easing.type: Easing.InOutElastic; easing.period: 1.0; easing.amplitude: 1.0 }
                ScriptAction{ scriptName: "waveAnimationRunningScript" }
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
        radius: 13
        samples: 17
        color:"#000000"
        source: pageHeader
        opacity: 0.5
        z: avatarMask.z + 1
    }

    Rectangle{
        id:userPanel
        width: parent.width
        height: (parent.height * 1/5)
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
        source: "image://meme/"

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

    function goToIndex(index, mode){
        listViewAnim.running = false
        var pos = appListView.contentY
        var destPos
        appListView.positionViewAtIndex(index, mode)
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
                goToIndex(0, ListView.Center)
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
        width: avatar.width / 2
        height: avatar.height / 2
        anchors{ bottom: avatar.bottom; horizontalCenter: avatar.horizontalCenter }
        z: pageHeader.z + 2

        property bool flipped: false

        front: Text{
            text: userPopValue
            width: Math.floor(parent.width * 1.25)
            height: Math.floor(parent.height * 1.25)
            anchors{ horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }
            font.pixelSize: parent.height / 2
            fontSizeMode: Text.HorizontalFit
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            color: "white"
        }
        back: Image{
            width: Math.ceil(parent.width * 0.75)
            height: Math.ceil(parent.height * 0.75)
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
            NumberAnimation{ target: rotation; property: "angle"; duration: 150 }
        }
    }

    Image{
        id: moneyInd
        width: Math.ceil(avatar.height * 1 / 2)
        height: width
        anchors.verticalCenter: userPanel.verticalCenter
        anchors.left: avatar.right
        anchors.leftMargin: width * 1 / 2
        source: "qrc:/uiIcons/shekel.svg"
        antialiasing: true
        mipmap: true
        z: userPanel.z + 1
        Text{
            id: moneyLabel
            anchors{ horizontalCenter: moneyInd.horizontalCenter; top: moneyInd.bottom }
            font.pixelSize: moneyInd.height / 4
            text: userShekels.toString()
            color: "#ffffff"
        }
        MouseArea{
            anchors.fill: parent
            onClicked: {
                rewardDialog.open()
            }
        }
    }

    Rectangle{
        id: moneyGlowForm
        anchors.fill: moneyInd
        radius: width / 2
        z: moneyInd.z - 1
        color: "black"
        visible: false
    }

    RectangularGlow{
        id: moneyGlow
        anchors.fill: moneyGlowForm
        color: Qt.lighter("#FFD74A")
        glowRadius: moneyGlowForm.width / 8
        smooth: glowRadius * 2 + 1
        spread: 0.7
        cornerRadius: moneyGlowForm.radius + glowRadius
        z: moneyGlowForm.z
        opacity: rewardedVideoAd.ready ? 1 : 0
        Behavior on opacity{
            NumberAnimation{ duration: 250 }
        }
    }

    WaveIndicator{
        id: creativeInd
        width: Math.ceil(avatar.height * 1 / 2)
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
            font.pixelSize: parent.height / 4
            text: userCreativity.toString()
            color: "#ffffff"
        }
    }

    ListView {
        id: appListView
        height: parent.height - pageHeader.height
        width: parent.width
        spacing: parent.height / 50
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

            property string name: memeNameText
            property bool imageVisible: true

            Image{
                id: memeImage
                height: parent.height
                width: height
                cache: false
                source: image
                visible: imageVisible
                onVisibleChanged: {
                    appListView.forceLayout()
                }
            }

            Text{
                id: memeNameLabel
                text: memeNameText
                anchors{ left: memeImage.right; top: parent.top }
                font.pixelSize: parent.height / 8
                fontSizeMode: Text.HorizontalFit
                font.family: "Roboto"
            }
            Text{
                id: courseDirectionLabel
                text: courseDirectionText
                anchors{ bottom: loyaltyLabel.top; right: parent.right }

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
                id: loyaltyLabel
                text: loyaltyText
                anchors{ verticalCenter: parent.verticalCenter; right: parent.right }
                color: "#000000"
            }
            Text{
                id: memeCreativityLabel
                text: memeCreativityText
                anchors{ top: loyaltyLabel.bottom; right: parent.right }
                color: "#00BCD4"
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    var currentYPos = memeImage.mapToItem(mainUserPage, memeImage.x, memeImage.y).y
                    if(appListView.y > currentYPos - appListView.contentY)
                        appListView.positionViewAtIndex(index, ListView.Beginning)
                    else if(appListView.y + appListView.height < currentYPos + parent.height - appListView.contentY)
                        appListView.positionViewAtIndex(index, ListView.End)
                    clickedMemeOnListY = memeImage.mapToItem(mainUserPage, memeImage.x, memeImage.y).y
                    clickedMemeImageSize = memeImage.width
//                    clickedMemeIndex = index
                    stackView.push({item: memePage, properties: {img: memeImage.source, name: memeNameText,
                                    memePopValues: memesPopValues[memeNameText], memeStartPopValue: startPopValues[memeNameText],
                                    memeCreativity: Number(memeCreativityText)}})
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

        adUnitId: "ca-app-pub-5551381749080346/6707293633"

        onReadyChanged:{
            if(ready){
                load()
                moneyGlow.opacity = 1
            }
            else
                moneyGlow.opacity = 0
        }

        onClosed: load()

        request: AdMobRequest {
            gender: AdMob.GenderUnknown
            childDirectedTreatment: AdMob.ChildDirectedTreatmentUnknown

            keywords: [ "memes" ]
        }

        onError: {
            App.log("RewardedVideoAd failed with error code",code,"and message",message)

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
        onRewarded: {
            User.rewardUserWithShekels()
        }
    }

    Dialog {
        id: rewardDialog
        title: "Вознаграждение"
        contentItem: Rectangle{
            width: mainUserPage.width * 5 / 6
            height: width / 3
            Column{
                anchors.fill: parent
                Text{
                    text: "Получить 100 shekelcoin за просмотр короткого видео?"
                    height: parent.height / 2
                    width: parent.width
                    font.pixelSize: height / 4
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                }
                Row{
                    height: parent.height / 2
                    width: parent.width
                    MaterialButton{
                        label: "получить"
                        labelSize: height / 4
                        width: parent.width / 2
                        height: parent.height
                        clickableColor: Qt.lighter(mainColor, 1.5)
                        rippleColor: Qt.lighter(clickableColor)
                        z: cancelButton.z + 1
                        onClicked: {
                            rewardedVideoAd.show()
                            rewardDialog.close()
                        }
                    }
                    MaterialButton{
                        id: cancelButton
                        label: "отмена"
                        labelSize: height / 4
                        width: parent.width / 2
                        height: parent.height
                        clickableColor: Qt.lighter(mainColor, 1.5)
                        rippleColor: Qt.lighter(clickableColor)
                        onClicked: {
                            rewardDialog.close()
                        }
                    }
                }
            }
        }
    }
}
