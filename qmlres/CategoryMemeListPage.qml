import QtQuick 2.0
import QtQuick.Controls 2.2

import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

Page{

    property color itemColor: "white"

    property string pageCategory
    property var memesPopValues: []

    function updateMeme(meme_name, image_name){
        memeListModel.append({ "memeName": meme_name, "imageName": image_name })

        console.log("update Meme: ", image_name)
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
        onMemePopValuesWithCategoryUpdated:{
            if(category == pageCategory){
                memesPopValues[memeName] = popValues
                console.log("onMemePopValuesWithCategoryUpdated")
            }
        }
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
        spacing: parent.height/50
        anchors{
            top: pageHeader.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }

        model: memeListModel

        delegate: Rectangle{
            width: pageHeader.header
            height: pageHeader.height * 2

            //rotation:180
            color: itemColor
            Image{
                id: memeImage
                height: parent.height
                width: height
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
            Component.onCompleted:{
                memeImage.source = "image://meme/" + imageName
                //memeImage.source = "image://meme/exactlyMeme.jpg"
                //IMAGE PROVIDER
                console.log("image name:", imageName)
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    stackView.push({item: memePage, properties: {img: memeImage.source, name: memeName,
                        memePopValues: memesPopValues[memeName], memeStartPopValue: startPopValues[memeName] }})
                }
            }
        }
    }
    ListModel{
        id: memeListModel
    }
}
