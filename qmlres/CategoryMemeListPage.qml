import QtQuick 2.11
import QtQuick.Controls 2.2

import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

Page{
    id: categoryMemeListPage

    objectName: "categoryMemeListPage"

    property color itemColor: "white"
    property color backColor: "#edeef0"

    property string pageCategory

    property var memesPopValues: []
    property var startPopValues: []

    property string directionFormat

    property double weight: 0

    property int clickedMemeOnListY
    property int clickedMemeImageSize


    Connections{
        target: stackView
        onCurrentItemChanged: {
            if(stackView.currentItem !== null){
                if(stackView.currentItem.objectName === categoryMemeListPage.objectName && !slidingMenu.open){
                    setupTutorial()
                }
            }
        }
    }

    Connections{
        target: slidingMenu
        onOpenChanged: if(!slidingMenu.open && !stackView.transitions.running) setupTutorial()
    }

    function setupTutorial(){
        if(userSettings.tutorial)
            trainMode.items = getTrainSequence()
        trainMode.active = userSettings.tutorial
    }

    function getItemForTrain(name, desc, descPos, item, coeff, isCircle, clickable, page){
        var obj = {
            "name" : name,
            "description" : desc,
            "descriptionPosition" : descPos,
            "item" : item,
            "coeff" : coeff,
            "isCircle" : isCircle,
            "clickable" : clickable,
            "page" : page
        };
        return obj
    }

    function getTrainSequence(){
        var seq = []

        if(userSettings.memePageTrain)
            seq.push(getItemForTrain(
                         qsTr("Выберите мем") + translator.emptyString,
                         "",
                         "bottom",
                         appListView,
                         1,
                         false,
                         "onlyItem",
                         "categoryMemeListPage"
                         )
                     )
        else
            seq.push(getItemForTrain(
                         qsTr("Нажмите") + translator.emptyString,
                         "",
                         "bottom",
                         hamburger,
                         2,
                         true,
                         "onlyItem",
                         "transfer"
                         )
                     )

        return seq
    }


    function setMeme(meme_name, image_name, loyalty, crsDir, memeCreativity){
        if(memeListModel.count){
            for(var i = 0; i < memeListModel.count; i++)
                if(memeListModel.get(i).memeNameText === meme_name){
                    memeListModel.set(i, {"courseDirectionText": courseWithSign(crsDir), "loyaltyText": parseFloat(loyalty / 100),
                                          "memeCreativityText": memeCreativity, "mine": User.findMeme(meme_name) ? true : false})
                    return;
                }
        }

        memeListModel.append({ "memeNameText": meme_name, "courseDirectionText": courseWithSign(crsDir),
                               "imageNameText": image_name, "image": "image://imgProv/meme_" + image_name,
                               "memeCreativityText": memeCreativity, "loyaltyText": parseFloat(loyalty / 100),
                               "mine": User.findMeme(meme_name) ? true : false
                             })
    }

    function removeMeme(meme_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeNameText === meme_name){
                memeListModel.remove(i)
            }
    }

    function courseWithSign(direction){
        if(direction > 0)
            directionFormat = '+' + direction.toString()
        else
            directionFormat = direction.toString()
        return directionFormat
    }

    function updateMemeImage(meme_name, image_name){
        for(var i = 0; i < memeListModel.count; i++)
            if(memeListModel.get(i).memeNameText === meme_name){
                memeListModel.setProperty(i, "image", "")
                memeListModel.setProperty(i, "image", "image://imgProv/meme_" + image_name)
            }
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
                clickedMemeImageSize = mItem.height
                clickedMemeOnListY = mapFromItem(appListView, mItem.x, mItem.y).y - appListView.contentY
            }
        }
    }

    Component.onCompleted: {
        User.setExistingMemeListWithCategory(pageCategory)
        User.getMemeListWithCategory(pageCategory)
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
        onMemeReceived:{
            if(category == pageCategory){
                var crsDir = Math.ceil((popValues[popValues.length - 1] * (1 + parseFloat(memeCreativity / 100)) - startPopValue)
                                       * parseFloat(loyalty / 100))
                memesPopValues[memeName] = popValues
                startPopValues[memeName] = startPopValue
                setMeme(memeName, imageName, loyalty, crsDir, memeCreativity)
            }
        }
        onMemeRemoved:{
            if(memeCategory == pageCategory)
                removeMeme(memeName)
        }
        onImageReceived:{
            if(type == "meme")
                updateMemeImage(name, imageName)
        }
    }

    Connections{
        target: stackView
        onCurrentItemChanged: {
            if(stackView.currentItem !== null)
                if(stackView.currentItem.objectName === categoryMemeListPage.objectName){
                    User.setExistingMemeListWithCategory(pageCategory)
                    getMemesWithCategoryTimer.restart()
                }
        }
    }

    Rectangle{
        id: background
        anchors.fill: parent
        color: backColor
        z: -1
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

    PageHeader{
        id: pageHeader
        width: parent.width
        height: parent.height / 10
        headerText: pageCategory
        z: appListView.z + 1
        MouseArea{
            anchors.fill: parent
            onClicked: {
                goToIndex(0, ListView.Center)
            }
        }
    }

    ListView {
        id: appListView
        spacing: pageHeader.height / 10
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

            property string name: memeNameText
            property bool imageVisible: true

            color: itemColor
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

            ProgressIndicator{
                height: parent.height
                width: height
                running: memeImage.status !== Image.Ready
                visible: memeImage.status !== Image.Ready
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
                anchors{ bottom: loyaltyLabel.top; right: parent.right; rightMargin: font.pixelSize / 2 }
                visible: mine

                onTextChanged:{
                    if(text.charAt(0) == "-")
                        color = "red"
                    else
                        color = "green"
                }
            }

            Text{
                text: qsTr("лояльность") + ": " + translator.emptyString
                anchors{ verticalCenter: parent.verticalCenter; right: loyaltyLabel.left }
            }
            Text{
                id: loyaltyLabel
                text: loyaltyText
                anchors{ verticalCenter: parent.verticalCenter; right: parent.right; rightMargin: font.pixelSize / 2 }
                color: "#000000"
            }

            Text{
                text: qsTr("креативность") + ": " + translator.emptyString
                anchors{ top: memeCreativityLabel.top; right: memeCreativityLabel.left }
                visible: mine
            }
            Text{
                id: memeCreativityLabel
                text: memeCreativityText
                anchors{ top: loyaltyLabel.bottom; right: parent.right; rightMargin: font.pixelSize / 2 }
                color: "#00BCD4"
                visible: mine
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    var currentYPos = memeImage.mapToItem(categoryMemeListPage, memeImage.x, memeImage.y).y
                    if(appListView.y > currentYPos)
                        appListView.positionViewAtIndex(index, ListView.Beginning)
                    else if(appListView.y + appListView.height < currentYPos + parent.height)
                        appListView.positionViewAtIndex(index, ListView.End)
                    getClosingMemePosition(memeNameText)
                    stackView.push({item: memePage, properties: {img: memeImage.source, name: memeNameText,
                                    memePopValues: memesPopValues[memeNameText], memeStartPopValue: startPopValues[memeNameText],
                                    memeCreativity: Number(memeCreativityText), category: pageCategory}})
                }
            }
            Rectangle{
                color: "red"
                anchors.fill: parent
                z: memeImage.z + 1
                visible: false
            }
        }

        NumberAnimation{ id: listViewAnim; target: appListView; property: "contentY"; duration: 400;
            easing.type: Easing.InOutQuad }
    }
    ListModel{
        id: memeListModel
    }
}
