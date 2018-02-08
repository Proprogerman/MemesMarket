import QtQuick 2.0
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import KlimeSoft.SingletonUser 1.0

import "qrc:/qml/elements"

Page {
    id:mainUserPage

    property string directionFormat

    function updateMeme(meme_name, image_name, values, direction){
        if(direction > 0)
            directionFormat = "+" + direction
        else
            directionFormat = direction

        memeListModel.append({"memeName": meme_name, "popValues": values, "courseDirection": directionFormat,
                                 "imageName": image_name})

        console.log("update Meme: ", image_name, " - ",values)
    }

    Connections{
        target: User
        onMemesRecieved:{
            updateMeme(memeName, imageName, popValues, courseDir)
        }
    }

    Component.onCompleted:{
        User.getMemeList()
        getMemeListTimer.start()
    }

    Timer{
        id: getMemeListTimer
        interval: 10000
        repeat: true
        onTriggered:{
            memeListModel.clear()
            User.getMemeList()
        }
    }

    property color backColor: "#edeef0"
    property color itemColor: "white"

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
                }
            }

        ]
    }

    Item{
        id: hamburger
        height: pageHeader.height / 4
        width: height * 3 / 2
        anchors{ left: slidingMenu.right; leftMargin: width; verticalCenter: pageHeader.verticalCenter }
        z: 5

        property int smallBarLength: width / 1.5
        property int xOffsetBackBars: width / 2
        property int startBar2Yposition: bar2.y

        Rectangle{
            id: bar1
            color:"white"
            width: parent.width
            height: parent.height * 1/5
            anchors.top: parent.top
            antialiasing: true
        }
        Rectangle{
            id: bar2
            color:"white"
            width: parent.width
            height: parent.height * 1/5
            anchors.top: bar1.bottom
            anchors.topMargin: parent.height * 1/5
            antialiasing: true
        }
        Rectangle{
            id: bar3
            color:"white"
            width: parent.width
            height: parent.height * 1/5
            anchors.top: bar2.bottom
            anchors.topMargin: parent.height * 1/5
            antialiasing: true
        }
        state: "menu"

        states:[
            State{
                name: "menu"
            },
            State{
                name: "back"
                PropertyChanges{ target: hamburger; rotation: 180;}
                PropertyChanges{ target: bar1; rotation: 45; width: hamburger.smallBarLength;
                    x: hamburger.xOffsetBackBars; y: hamburger.startBar2Yposition - 5}
                PropertyChanges{ target: bar2}
                PropertyChanges{ target: bar3; rotation: -45; width: hamburger.smallBarLength;
                    x: hamburger.xOffsetBackBars; y: hamburger.startBar2Yposition + 5}
                AnchorChanges{ target: bar1; anchors.top: undefined;}
                AnchorChanges{ target: bar2; anchors.top: undefined;}
                AnchorChanges{ target: bar3; anchors.top: undefined;}
            }
        ]

        transitions:[
            Transition{
                PropertyAnimation{target: hamburger; property:"rotation"; duration: 260; easing.type: Easing.InOutQuad}
                PropertyAnimation{target: bar1; properties:"rotation, width, x, y"; duration: 260; easing.type:Easing.InOutQuad}
                PropertyAnimation{target: bar2; properties:"rotation"; duration: 260; easing.type:Easing.InOutQuad}
                PropertyAnimation{target: bar3; properties:"rotation, width, x, y"; duration: 260; easing.type:Easing.InOutQuad}
            }

        ]

        MouseArea{
            anchors.fill: parent
            onClicked:{
                if(hamburger.state == "menu"){
                    hamburger.state = "back"
                    slidingMenu.show()
                }
                else if(hamburger.state == "back"){
                    hamburger.state = "menu"
                    slidingMenu.hide()
                }
            }
        }
    }

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
            text: User.user_name
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

        Image {
            id: avatar
            visible:false
            width: (userPanel.width * 1/3)
            height: width
            anchors.horizontalCenter: userPanel.horizontalCenter
            anchors.verticalCenter: userPanel.verticalCenter
            source: "qrc:/photo/sexyPhoto.jpg"
            //radius: height/2
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

    ListView {
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

        model: memeListModel
//        model:ListModel{
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/catMeme.jpg"
//                memeName:"Кошан"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/contiMeme.jpg"
//                memeName:"Ну давай, продолжай"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/dryzhMeme.jpg"
//                memeName:"Дружко"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/exactlyMeme.jpg"
//                memeName:"Действительно"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/potMeme.jpg"
//                memeName:"Потный"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/respectMeme.jpg"
//                memeName:"Мое уважение"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/shlMeme.jpg"
//                memeName:"А ты точно?"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/vzhyhMeme.jpg"
//                memeName:"Вжух"
//            }
//            ListElement{
//                memeImageSource:"qrc:/memePhoto/watchMeme.jpg"
//                memeName:"Я слежу за тобой"
//            }
//        }
        delegate: Rectangle{
            width: userPanel.width
            height: userPanel.height

            //rotation:180
            color: itemColor
            Image{
                id: memeImage
                height: parent.height
                width: height
                //source: memeImageSource
            }
            Text{
                text: memeName
                anchors{ left: memeImage.right; top: parent.top }
            }
            Text{
                text: courseDirection
                anchors{ right: parent.right; verticalCenter: parent.verticalCenter }

                property int intCourse

                onTextChanged:{
                    intCourse = text
                    if(intCourse > 0)
                        color = "green"
                    else if(intCourse < 0)
                        color = "red"
                }
            }
            Component.onCompleted:{
                memeImage.source = "image://meme/" + imageName
                //memeImage.source = "image://meme/exactlyMeme.jpg"
                //IMAGE PROVIDER
                console.log("image name:", imageName)
            }

            MouseArea{
                anchors.fill: parent
                onClicked:{
                    stackView.push({item: memesPage, properties: {img: "qrc:/photo/sexyPhoto.jpg", name: "Lol"}})
                }
            }
        }
    }
    ListModel{
        id: memeListModel
    }
}
