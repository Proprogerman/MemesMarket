import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import io.qt.SingletonConnection 1.0

//import "../elements"

Page {
    id:mainUserPage

    Rectangle{
        id:background
        anchors.fill: parent
        z: -2
        color:"#edeef0"
    }

    Rectangle{
        id: staticLine
        width: parent.width
        height: parent.height * 1/10
        anchors.top: parent.top
        color: header.color
        z: 4

        Text{
            id: groupName
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.top;
                topMargin: height/4 }
            text: ServerConnection.user_name
            font.pointSize: parent.height * 1/8
        }
    }

    DropShadow{
        anchors.fill: staticLine
        //verticalOffset: staticLine.height * 1/5
        radius: 20
        samples: 17
        color:"#80000000"
        source: staticLine
        opacity: 0.5
        spread: 0.5
        z: 3
    }

    Rectangle{
        id:header
        width:parent.width
        height:(parent.height * 1/5)
        anchors.top: staticLine.bottom
        z:2
        color:"#507299"

        Image {
            id: avatar
            visible:false
            width: (header.width * 1/3)
            height: width
            anchors.horizontalCenter: header.horizontalCenter
            anchors.verticalCenter: header.bottom
            source: "../../assets/sexyPhoto.jpg"
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

//        Rectangle{
//            id: sortButtons
//            anchors{left: header.left; right: header.right;
//                top: header.bottom}
//            height: avatar.height * 1/2
//            color: "#83A5CC"
//            z: -1
//        }

        /////////////////////////////////////////////////////////////////////////
        Rectangle{
            id: moneyInd
            width: (avatar.height * 1/2)
            height: width
            anchors.verticalCenter: header.verticalCenter
            x: (header.width*3/4 - width*1/2)
            color:"gold"
            radius: width
        }
        ////////////////////////////////////////////////////////////////////////
        Rectangle{
            id:creativeInd
            width: (avatar.height * 1/2)
            height: width
            anchors.verticalCenter: header.verticalCenter
            x: (header.width*1/4 - width*1/2)
            color:"lime"
            radius: width
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
        model:ListModel{
            ListElement{
                memeImage:"../../assets/catMeme.jpg"
                memeName:"Кошан"
            }
            ListElement{
                memeImage:"../../assets/contiMeme.jpg"
                memeName:"Ну давай, продолжай"
            }
            ListElement{
                memeImage:"../../assets/dryzhMeme.jpg"
                memeName:"Дружко"
            }
            ListElement{
                memeImage:"../../assets/exactlyMeme.jpg"
                memeName:"Действительно"
            }
            ListElement{
                memeImage:"../../assets/potMeme.jpg"
                memeName:"Потный"
            }
            ListElement{
                memeImage:"../../assets/respectMeme.jpg"
                memeName:"Мое уважение"
            }
            ListElement{
                memeImage:"../../assets/shlMeme.jpg"
                memeName:"А ты точно?"
            }
            ListElement{
                memeImage:"../../assets/vzhyhMeme.jpg"
                memeName:"Вжух"
            }
            ListElement{
                memeImage:"../../assets/watchMeme.jpg"
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
