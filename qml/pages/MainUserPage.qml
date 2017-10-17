import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import io.qt.SingletonConnection 1.0

//import "../elements"

Page {
    id:mainUserPage

    property color backColor: "#edeef0"
    property color itemColor: "white"

    Rectangle{
        id:background
        anchors.fill: parent
        z: -2
        color: backColor
    }

    Rectangle{
        id: pageHeader
        width: parent.width
        height: parent.height * 1/10
        anchors.top: parent.top
        color: userPanel.color
        z: 4

        Text{
            id: groupName
            anchors{ horizontalCenter: parent.horizontalCenter; top: parent.top;
                topMargin: height/4 }
            text: "King of Memes"//ServerConnection.user_name
            font.pixelSize: parent.height/2
        }
    }


    DropShadow{
        anchors.fill: pageHeader
        //verticalOffset: staticLine.height * 1/5
        radius: 13
        samples: 17
        color:"#000000"
        source: pageHeader
        opacity: 0.5
        z: 3
    }

    Rectangle{
        id:userPanel
        width:parent.width
        height:(parent.height * 1/5)
        anchors.top: pageHeader.bottom
        z:2
        color:"#507299"

        RoundedImage {
            id: avatar
            //visible:false
            width: (userPanel.width * 1/3)
            height: width
            anchors.horizontalCenter: userPanel.horizontalCenter
            anchors.verticalCenter: userPanel.verticalCenter
            source: "../../assets/sexyPhoto.jpg"
            radius: height/2
        }
//        OpacityMask{
//            anchors.fill: avatar
//            source: avatar
//            maskSource:Rectangle{
//                width: avatar.width
//                height: width
//                radius: width
//            }
//        }

//        Rectangle{
//            id: sortButtons
//            anchors{left: header.left; right: header.right;
//                top: userPanel.bottom}
//            height: avatar.height * 1/2
//            color: "#83A5CC"
//            z: -1
//        }

        /////////////////////////////////////////////////////////////////////////
        Rectangle{
            id: moneyInd
            width: (avatar.height * 1/2)
            height: width
            anchors.verticalCenter: userPanel.verticalCenter
            anchors.left: avatar.right
            anchors.leftMargin: width * 1/2
            color:"gold"
            radius: width/2
        }
        ////////////////////////////////////////////////////////////////////////
        Rectangle{
            id:creativeInd
            width: (avatar.height * 1/2)
            height: width
            anchors.verticalCenter: userPanel.verticalCenter
            anchors.right: avatar.left
            anchors.rightMargin: width * 1/2
            color:"lime"
            radius: width/2
        }
        states: [
            State{
                name:"normalState"
                AnchorChanges{ target: userPanel; anchors.top: pageHeader.bottom }
            },
            State{
                name:"scrollUpState"
                AnchorChanges{ target: userPanel; anchors.bottom: pageHeader.bottom }
            }
        ]

        transitions:[
            Transition{
                from: "normalState"; to: "scrollUpState"
                reversible: true
                AnchorAnimation{ duration: 500 }
            }

        ]


//        state: "scrollUpState"
//        Timer{
//            interval: 3000
//            onTriggered:{ header.state == "normalState"? header.state = "scrollUpState" : header.state = "normalState"}
//        }
    }

    DropShadow{
        anchors.fill: userPanel
        source: userPanel
        radius: 13
        samples: 17
        color: "#000000"
        opacity: 0.8
        spread: 0.4
        z: 1
    }

    AppListView {
        id: appListView
        height: parent.height - userPanel.height
        width: parent.width
        spacing: parent.height/50
        anchors{
            top: userPanel.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }
        //Component.onCompleted:positionViewAtBeginning()
        //rotation: 180

//        Timer{
//            running: true
//            repeat: true
//            interval: 1000
//            onTriggered:{
//                console.log("scrollPosition: ", appListView.getScrollPosition())
//            }
//        }

        model:ListModel{
            ListElement{
                memeImageSource:"../../assets/catMeme.jpg"
                memeName:"Кошан"
            }
            ListElement{
                memeImageSource:"../../assets/contiMeme.jpg"
                memeName:"Ну давай, продолжай"
            }
            ListElement{
                memeImageSource:"../../assets/dryzhMeme.jpg"
                memeName:"Дружко"
            }
            ListElement{
                memeImageSource:"../../assets/exactlyMeme.jpg"
                memeName:"Действительно"
            }
            ListElement{
                memeImageSource:"../../assets/potMeme.jpg"
                memeName:"Потный"
            }
            ListElement{
                memeImageSource:"../../assets/respectMeme.jpg"
                memeName:"Мое уважение"
            }
            ListElement{
                memeImageSource:"../../assets/shlMeme.jpg"
                memeName:"А ты точно?"
            }
            ListElement{
                memeImageSource:"../../assets/vzhyhMeme.jpg"
                memeName:"Вжух"
            }
            ListElement{
                memeImageSource:"../../assets/watchMeme.jpg"
                memeName:"Я слежу за тобой"
            }
        }
        delegate: Rectangle{
            width: userPanel.width
            height: userPanel.height
            //rotation:180
            color: itemColor
            Image{
                id: memeImage
                height: parent.height
                width: height
                source: memeImageSource
            }
            Text{
                text: memeName
                anchors{ left: memeImage.right; top: parent.top }
            }
        }
    }
}
