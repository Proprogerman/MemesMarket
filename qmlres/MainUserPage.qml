import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import KlimeSoft.SingletonUser 1.0

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

    function updateMeme(meme_name, image_name, crsDir){
        if(!findMeme(meme_name))
            memeListModel.append({ "memeName": meme_name, "courseDirection": courseWithSign(crsDir),
                "imageName": image_name, "image": "image://meme/" + image_name })

        console.log("update Meme: ", image_name)
    }

    function updateMemeImage(meme_name, image_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeName === meme_name){
                memeListModel.setProperty(i, "image", " ")
                memeListModel.setProperty(i, "image", "image://meme/" + image_name)
            }
    }

    function updatePopValues(meme_name, crsDir){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeName === meme_name){
                memeListModel.setProperty(i, "courseDirection", courseWithSign(crsDir))
            }
    }

    function unforceMeme(meme_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeName === meme_name){
                memeListModel.remove(i)
            }
    }

    function findMeme(meme_name){
        for(var i = 0; i < memeListModel.count; i++){
            if(memeListModel.get(i).memeName === meme_name)
                return true
        }
        return false
    }

    Connections{
        target: User
        onMemeForUserReceived:{
            var crsDir = popValues[popValues.length - 1] - startPopValue
            updateMeme(memeName, imageName, crsDir, startPopValue)
            memesPopValues[memeName] = popValues
            startPopValues[memeName] = startPopValue
            console.log("startPopValue: ", startPopValue)
        }
        onMemePopValuesForUserUpdated:{
            var crsDir = popValues[popValues.length - 1] - startPopValue
            updatePopValues(memeName, crsDir, startPopValue)
            memesPopValues[memeName] = popValues
            startPopValues[memeName] = startPopValue
            console.log("startPopValue: ", startPopValue)
            console.log("___________________________________________________")
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
            if(stackView.currentItem.objectName == "mainUserPage"){
                console.log("GET USER DATA TIMER")
                User.getUserData()
                if(!creativeInd.running)
                    creativeInd.running = true
            }
        }
    }

    SlidingMenu{
        id: slidingMenu
        onOpenChanged: {
            hamburger.state = open ? hamburger.state = "back" : hamburger.state = "menu"
        }
        data:[
            Column{
                width: parent.width
                height: parent.height
                Image{
                    id: bigAvatar
                    source: "qrc:/photo/sexyPhoto.jpg"
                    width: parent.width
                    height: width
                    sourceSize.height: height
                    sourceSize.width: width
                }

                Rectangle{
                    id: memesExchange
                    width: parent.width
                    height: parent.height / 10
                    color: "lightgrey"
                    Text{
                        text:"Биржа мемов"
                        font.pixelSize: parent.height / 3
                        anchors.centerIn: parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            User.getMemesCategories()
                            stackView.push(rialtoPage)
                            slidingMenu.hide()
                        }
                    }
                }
            }
        ]
    }

    Hamburger{
        id: hamburger
        height: pageHeader.height / 4
        width: height * 3 / 2
        anchors{ left: slidingMenu.right; leftMargin: width; verticalCenter: pageHeader.verticalCenter }
        z: slidingMenu.z
        onOpenAction: slidingMenu.show()
        onBackAction: slidingMenu.hide()
    }

    Rectangle{
        id:background
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
        z: pageHeader.z - 1
    }

    Rectangle{
        id:userPanel
        width:parent.width
        height:(parent.height * 1/5)
        //anchors.top: pageHeader.bottom
        y: pageHeader.y + height / 2
        z: pageHeader.z - 3
        color:"#507299"

        states: [
            State{
                when: appListView.contentY <= (appListView.originY - userPanel.height)
                name:"normalState"
                PropertyChanges { target: userPanel; y: pageHeader.y + height / 2 }
            },
            State{
                when: appListView.contentY > (appListView.originY - userPanel.height)
                name:"scrollUpState"
                PropertyChanges{ target: userPanel; y: - appListView.contentY - userPanel.height / 2 }
                //PropertyChanges{ target: avatar; y: pageHeader.y}
            }
        ]
        state: "normalState"
    }

    Image {
        id: avatar
        visible:false
        width: userPanel.width * 1/3
        height: width
        x: userPanel.x + (userPanel.width - width) / 2
        y: userPanel.y + (userPanel.height - height) / 2

        source: "qrc:/photo/sexyPhoto.jpg"
        states:[
            State{
                when: (userPanel.y + userPanel.height / 2) > (pageHeader.y + pageHeader.height)
                name: "normal"
                PropertyChanges{ target: avatar; y: userPanel.y + (userPanel.height - height) / 2 }
                PropertyChanges{ target: avatarLable; flipped: false}
            },
            State{
                when: (userPanel.y + userPanel.height / 2) < (pageHeader.y + pageHeader.height)
                name: "tapToTop"
//                PropertyChanges{ target: avatar; y: pageHeader.y }
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
        width: (avatar.height * 1/2)
        height: width
        anchors.verticalCenter: userPanel.verticalCenter
        anchors.left: avatar.right
        anchors.leftMargin: width * 1/2
        z: userPanel.z + 1
        color:"gold"
        radius: width/2
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
        width: (avatar.height * 1/2)
        height: width
        anchors.verticalCenter: userPanel.verticalCenter
        anchors.right: avatar.left
        anchors.rightMargin: width * 1/2
        z: userPanel.z + 1

        amount: userCreativity
        Text{
            id: creativityLabel
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.bottom }
            font.pixelSize: parent.height / 5
            text: userCreativity.toString()
            color: "#ffffff"
        }
    }

    DropShadow{
        anchors.fill: userPanel
        source: userPanel
        radius: 13
        samples: 17
        color: "#000000"
        opacity: 0.8
        spread: 0.4
        z: userPanel.z - 1
    }

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

//        onContentYChanged: {
//            if(contentY > 0){
//                userPanel.state = "scrollUpState"
//            }
//            else
//                userPanel.state = "normalState"
//        }

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
                text: memeName
                anchors{ left: memeImage.right; top: parent.top }
            }
            Text{
                text: courseDirection
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

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    stackView.push({item: memePage, properties: {img: memeImage.source, name: memeName,
                        memePopValues: memesPopValues[memeName], memeStartPopValue: startPopValues[memeName] }})
                }
            }
            MouseArea{
                anchors.fill: unforceButton
                onClicked:{
                    User.unforceMeme(memeName)
                }
            }
        }
        NumberAnimation{ id: listViewAnim; target: appListView; property: "contentY"; duration: 400;
            easing.type: Easing.InOutQuad }
    }
    ListModel{
        id: memeListModel
//        ListElement{
//            memeName: "Check"
//            courseDirection: 100
//            imageName: "exactlyMeme.jpg"
//        }
//        ListElement{
//            memeName: "Check"
//            courseDirection: 100
//            imageName: "exactlyMeme.jpg"
//        }
//        ListElement{
//            memeName: "Check"
//            courseDirection: 100
//            imageName: "exactlyMeme.jpg"
//        }
//        ListElement{
//            memeName: "Check"
//            courseDirection: 100
//            imageName: "exactlyMeme.jpg"
//        }
//        ListElement{
//            memeName: "Check"
//            courseDirection: 100
//            imageName: "exactlyMeme.jpg"
//        }
//        ListElement{
//            memeName: "Check"
//            courseDirection: 100
//            imageName: "exactlyMeme.jpg"
//        }
    }
}
