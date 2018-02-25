import QtQuick 2.0
import QtQuick.Controls 2.2

import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

Page{

    property color backColor: "#edeef0"
    property color mainColor: "#507299"

    Connections{
        target: User
        onMemesCategoriesReceived:{
            var categories = memesCategories
            for(var i = 0; i < categories.length; i++){
                categoryGridModel.append({ "categoryText": categories[i] })
            }
        }
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
        headerText: "Биржа Мемов"
    }

    GridView{
        id: categoriesGridView
        height: parent.height - pageHeader.height
        width: parent.width
        cellWidth: background.width / 2
        cellHeight: cellWidth

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
                    font.pixelSize: parent.height / 5
                }
                MouseArea{
                    anchors.fill: parent
                    onClicked:{
//                        User.getMemeListWithCategory(categoryLabel.text.toString())
                        stackView.push( {item: categoryMemeListPage, properties: { pageCategory: categoryLabel.text.toString() }} )
                    }
                }
            }
        }

    }
    ListModel{
        id: categoryGridModel
//        ListElement{
//            categoryText: "Стабильные"
//        }
//        ListElement{
//            categoryText: "Нестабильные"
//        }

    }
}
