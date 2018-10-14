import QtQuick 2.0
import QtQuick.Controls 2.2

import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

Page{
    id: rialtoPage

    objectName: "rialtoPage"

    property color backColor: "#edeef0"
    property color mainColor: "#507299"

    Connections{
        target: stackView
        onCurrentItemChanged: {
            if(stackView.currentItem !== null)
                if(stackView.currentItem.objectName === objectName && !slidingMenu.open)
                    setupTutorial()
        }
    }

    Connections{
        target: slidingMenu
        onOpenChanged: if(!slidingMenu.open) setupTutorial()
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
        var descPos = "bottom"

        if(userSettings.memePageTrain)
            seq.push(getItemForTrain(
                         qsTr("Выберите категорию") + translator.emptyString,
                         "",
                         descPos,
                         categoriesGridView,
                         1,
                         false,
                         "onlyItem",
                         "rialtoPage"
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
                         "onlyZone",
                         "transfer"
                         )
                     )

        return seq
    }

    Connections{
        target: User
        onMemesCategoriesReceived:{
            var categories = memesCategories
            for(var i = 0; i < categories.length; i++){
                categoryGridModel.set(i, { "categoryText": categories[i] })
            }
        }
    }

    Timer{
        id: getCategoriesTimer
        triggeredOnStart: true
        interval: 10000
        repeat: true
        onTriggered: User.getMemesCategories()
    }

    Component.onCompleted: {
        if(User.categoriesIsEmpty())
            User.getMemesCategories()
        else
            User.setExistingCategoriesList()
        getCategoriesTimer.start()
    }

    Rectangle{
        id: background
        anchors.fill: parent
        color: backColor
    }

    PageHeader{
        id: pageHeader
        width: parent.width
        height: parent.height / 10
        headerText: qsTr("Биржа Мемов") + translator.emptyString
        z: categoriesGridView.z + 1
    }

    GridView{
        id: categoriesGridView
        height: parent.height - pageHeader.height
        width: parent.width
        cellWidth: background.width / 2
        cellHeight: cellWidth
        z: background.z + 1

        anchors{
            top: pageHeader.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        model: categoryGridModel

        delegate: Item{
                width: categoriesGridView.cellWidth
                height: categoriesGridView.cellHeight

                Rectangle{
                width: categoriesGridView.cellWidth / 1.1
                height: width
                anchors.centerIn: parent
                color: "lightblue"
                Text{
                    id: categoryLabel
                    text: categoryText
                    font.pixelSize: parent.height / 10
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked:{
                        stackView.push( {item: categoryMemeListPage, properties: { pageCategory: categoryLabel.text.toString() }} )
                    }
                }
            }
        }
    }
    ListModel{
        id: categoryGridModel
    }
}
