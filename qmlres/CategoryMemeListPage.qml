import QtQuick 2.0
import QtQuick.Controls 2.2

import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

Page{

    property color itemColor: "white"
    property color backColor: "#edeef0"

    property string pageCategory
    property var memesPopValues: []

    function updateMeme(meme_name, image_name){
        memeListModel.append({ "memeName": meme_name, "image": "image://meme/" + image_name })

        console.log("update Meme: ", image_name)
    }

    function updateMemeImage(meme_name, image_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeName === meme_name){
                memeListModel.setProperty(i, "image", " ")
                memeListModel.setProperty(i, "image", "image://meme/" + image_name)
            }
    }

    Component.onCompleted: {
        if(User.memesWithCategoryIsEmpty(pageCategory)){
            User.getMemeListWithCategory(pageCategory)
            console.log("MEMES WITH CATEGORY IS EMPTY111111111111111111111111")
        }
        else{
            User.setExistingMemeListWithCategory(pageCategory)
            console.log("MEMES WITH CATEGORY ISN'T EMPTY222222222222222222222")
        }
        getMemesWithCategoryTimer.start()
    }

    Timer{
        id: getMemesWithCategoryTimer
        interval: 5000
        repeat: true
        onTriggered: {
            User.getMemeListWithCategory(pageCategory)
        }
    }

    Connections{
        target: User
        onMemeWithCategoryReceived:{
            if(category == pageCategory){
                updateMeme(memeName, imageName)
                memesPopValues[memeName] = popValues
                console.log("onMemeWithCategoryReceived")
            }
        }
        onMemeImageReceived:{
            updateMemeImage(memeName, imageName)
        }
        onMemePopValuesWithCategoryUpdated:{
            if(category == pageCategory){
                memesPopValues[memeName] = popValues
                console.log("onMemePopValuesWithCategoryUpdated")
            }
        }
    }

    Rectangle{
        id: background
        anchors.fill: parent
        color: backColor
        z: -1
    }

    PageHeader{
        id: pageHeader
        width: parent.width
        height: parent.height / 10
        headerText: pageCategory
        z: appListView.z + 1
    }

    ListView {
        id: appListView
        height: parent.height - pageHeader.height
        width: parent.width
        spacing: parent.height/ 50
        z: background.z + 1
        anchors{
            top: pageHeader.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }

        model: memeListModel

        delegate: Rectangle{
            width: pageHeader.width
            height: pageHeader.height * 2

            color: itemColor
            Image{
                id: memeImage
                height: parent.height
                width: height
                cache: false
                source: image
            }
            Text{
                text: memeName
                anchors{ left: memeImage.right; top: parent.top }
            }
//            Text{
//                text: courseDirection
//                anchors{ right: parent.right; verticalCenter: parent.verticalCenter }

//                onTextChanged:{
//                    if(text.charAt(0) == "-"){
//                        color = "red"
//                    }
//                    else{
//                        color = "green"
//                    }
//                }
//            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    if(User.findMeme(memeName)){
                        stackView.push({item: memePage, properties: {img: memeImage.source, name: memeName,
                            memePopValues: memesPopValues[memeName], memeStartPopValue: memesPopValues[memeName],
                            category: pageCategory, state: "mine" }})
                    }
                    else{
                        stackView.push({item: memePage, properties: {img: memeImage.source, name: memeName,
                            memePopValues: memesPopValues[memeName], memeStartPopValue: memesPopValues[memeName],
                            category: pageCategory, state: "general" }})
                    }
                }
            }
            Rectangle{
                color: "red"
                anchors.fill: parent
                z: memeImage.z + 1
                visible: false
            }
        }
    }
    ListModel{
        id: memeListModel
    }
}
