import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

Page {
    id:mainUserPage


    Rectangle{
        id:background
        anchors.fill: parent
        z: 0
        color:"#edeef0"
    }

    Rectangle{
        id:header
        width:parent.width
        height:(parent.height/4.8)
        z:2
        color:"#507299"

        Image {
            id: avatar
            visible:false
            width: (header.height* 0.875)
            height: width
            anchors.horizontalCenter: header.horizontalCenter
            anchors.verticalCenter: header.bottom
            source: "../assets/sexyPhoto.jpg"
        }
        OpacityMask{
            anchors.fill: avatar
            source: avatar
            maskSource:Rectangle{
                width: avatar.width
                height: width
                radius: width
            }
        }

        /////////////////////////////////////////////////////////////////////////
        Rectangle{
            id: moneyInd
            width: (header.height* 0.375)
            height: width
            anchors.verticalCenter: header.verticalCenter
            x: (header.width*3/4 - width*1/2)
            color:"gold"
            visible:false
        }
        OpacityMask{
            width: moneyInd. width
            height: width
            anchors.fill: moneyInd
            source: moneyInd
            maskSource: Rectangle{
                width: moneyInd.width
                height: width
                radius: width
            }
        }
        ////////////////////////////////////////////////////////////////////////
        Rectangle{
            id:creativeInd
            width: (header.height* 0.375)
            height: width
            anchors.verticalCenter: header.verticalCenter
            x: (header.width*1/4 - width*1/2)
            color:"lime"
            visible:false
        }
        OpacityMask{
            width: creativeInd.width
            height: width
            anchors.fill:creativeInd
            source:creativeInd
            maskSource:Rectangle{
                width: creativeInd.width
                height: width
                radius: width
            }

        }
    }

    AppListView {
        id: appListView
        height: parent.height - header.height
        width: parent.width
        spacing: parent.height/50
        anchors{
            top: header.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        //Component.onCompleted:positionViewAtBeginning()
        //rotation: 180
        Component.onCompleted: {
            console.log(getScrollPosition())
        }
        z: 1
        model:ListModel{
            ListElement{
                memeImage:"../assets/catMeme.jpg"
                memeName:"Кошан"
            }
            ListElement{
                memeImage:"../assets/contiMeme.jpg"
                memeName:"Ну давай, продолжай"
            }
            ListElement{
                memeImage:"../assets/dryzhMeme.jpg"
                memeName:"Дружко"
            }
            ListElement{
                memeImage:"../assets/exactlyMeme.jpg"
                memeName:"Действительно"
            }
            ListElement{
                memeImage:"../assets/potMeme.jpg"
                memeName:"Потный"
            }
            ListElement{
                memeImage:"../assets/respectMeme.jpg"
                memeName:"Мое уважение"
            }
            ListElement{
                memeImage:"../assets/shlMeme.jpg"
                memeName:"А ты точно?"
            }
            ListElement{
                memeImage:"../assets/vzhyhMeme.jpg"
                memeName:"Вжух"
            }
            ListElement{
                memeImage:"../assets/watchMeme.jpg"
                memeName:"Я слежу за тобой"
            }
        }
        delegate: Rectangle{
            width: header.width
            height: header.height
            //rotation:180
            color:"white"
            Image{
                height: parent.height
                width: height
                source: memeImage
            }
            Text{
                text: memeName
            }
        }
    }
}
