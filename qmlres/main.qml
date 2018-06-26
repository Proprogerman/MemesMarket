import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Universal 2.2
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2


import "qrc:/qml/pages"
import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

import QtFirebase 1.0

ApplicationWindow{
    id: mainWindow
    visible: true
    height: 720                                 //
    width: 405                                  // for desktop
    x: 300 ; y: 50                              //

//    visibility: Window.FullScreen               // for mobile

    property color mainColor: "#507299"


    StackView{
        id: stackView
        anchors.fill: parent
        initialItem: signInPage

        onCurrentItemChanged: {
            if(stackView.currentItem !== null){
                hamburger.visible = stackView.currentItem.objectName === "mainUserPage" ? true : false
                slidingMenu.active = stackView.currentItem.objectName === "signInPage" ? false : true
            }
        }

        delegate: StackViewDelegate{
            function getTransition(properties){
                var currTransition = someTransition
                if(properties.exitItem.objectName === "signInPage" && properties.enterItem.objectName === "mainUserPage")
                    currTransition = fromSignToMainTransition
                else if(properties.exitItem.objectName === "mainUserPage" && properties.enterItem.objectName === "signInPage")
                    currTransition = fromMainToSignTransition
                else if(properties.enterItem.objectName === "memePage")
                    currTransition = memePageTransition
                else if(properties.exitItem.objectName === "memePage" && properties.enterItem.objectName === "mainUserPage"
                && User.findMeme(properties.exitItem.name))
                    currTransition = fromMemePageTransition
                else if(properties.exitItem.objectName === "memePage"&& properties.enterItem.objectName === "categoryMemeListPage")
                    currTransition = fromMemePageTransition

                return currTransition
            }
            function transitionFinished(properties){
                properties.exitItem.x = 0
                properties.exitItem.y = 0
                properties.exitItem.opacity = 1
                if(properties.exitItem.objectName === "memePage" && properties.enterItem.objectName === "mainUserPage"
                || properties.enterItem.objectName === "categoryMemeListPage")
                    properties.enterItem.setVisibilityImageOnList(true)
            }
            property Component someTransition: StackViewTransition{
                PropertyAnimation{
                    target: exitItem
                    property: "x"
                    from: target.Stack.index > enterItem.Stack.index ? 0 : 0
                    to: target.Stack.index > enterItem.Stack.index ? target.width : -target.width
                    duration: 250
                    easing.type: Easing.OutCirc
                }
                PropertyAnimation{
                    target: enterItem
                    property: "x"
                    from: target.Stack.index < exitItem.Stack.index ? -exitItem.width : exitItem.width
                    to: target.Stack.index < exitItem.Stack.index ? 0 : 0
                    duration: 250
                    easing.type: Easing.OutCirc
                }
            }

            property Component fromSignToMainTransition: StackViewTransition {
                SequentialAnimation{
                    ScriptAction{ script: hamburger.opacity = 0 }
                    PropertyAnimation{
                        target: enterItem
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 1000
                    }
                    ScriptAction{ script: enterItem.state = "normal" }
                    PropertyAnimation{ target: hamburger; property: "opacity"; from: 0; to: 1; duration: 100 }
                }
            }

            property Component fromMainToSignTransition: StackViewTransition {
                SequentialAnimation{
                    ScriptAction{ script: exitItem.state = "hidden" }
                    PauseAnimation{ duration: 750 }
                    PropertyAnimation{
                        target: exitItem
                        property: "opacity"
                        from: 1
                        to: 0
                        duration: 1000
                    }
                    ScriptAction{ script: enterItem.state = "normal" }
                }
            }

            property Component memePageTransition: StackViewTransition {
                SequentialAnimation{
                    ScriptAction{ script: enterItem.state = User.findMeme(enterItem.name) ? "mine" : "general" }
                    ScriptAction{ script: exitItem.setVisibilityImageOnList(enterItem.name, false) }
                    ParallelAnimation{
                        PropertyAnimation{
                            target: enterItem
                            property: "memeImageY"
                            from: exitItem.clickedMemeOnListY
                            to: target.imageBackY
                            duration: 200
                            easing.type: Easing.OutCirc
                        }
                        PropertyAnimation{
                            target: enterItem
                            property: "memeImageScale"
                            from: exitItem.clickedMemeImageSize / (target.width / 2)
                            to: 1
                            duration: 200
                            easing.type: Easing.OutCirc
                        }
                        PropertyAnimation{
                            target: enterItem
                            property: "memeImageX"
                            from: 0
                            to: target.width / 4
                            duration: 200
                            easing.type: Easing.OutCirc
                        }
                    }
                }
            }

            property Component fromMemePageTransition: StackViewTransition {
                SequentialAnimation{
                    ScriptAction{ script: exitItem.state = "hidden" }
//                    ScriptAction{ script: enterItem.setVisibilityImageOnList(exitItem.name, false) }
                    ScriptAction{ script: enterItem.getClosingMemePosition(exitItem.name)}
                        ParallelAnimation{
                            PropertyAnimation{
                                target: exitItem
                                property: "memeImageY"
                                from: exitItem.imageBackY
                                to: enterItem.getClosingMemePosition(exitItem.name)//enterItem.clickedMemeOnListY
                                duration: 200
                                easing.type: Easing.OutCirc
                            }
                            PropertyAnimation{
                                target: exitItem
                                property: "memeImageScale"
                                from: 1
                                to: enterItem.clickedMemeImageSize / (target.width / 2)
                                duration: 200
                                easing.type: Easing.OutCirc
                            }
                            PropertyAnimation{
                                target: exitItem
                                property: "memeImageX"
                                from: target.width / 4
                                to: 0
                                duration: 200
                                easing.type: Easing.OutCirc
                            }
                    }
                    ScriptAction{ script: enterItem.setVisibilityImageOnList(exitItem.name, true) }
                }
            }
        }

        Component{
            id: signInPage
            SignInPage{}
        }

        Component{
            id: mainUserPage
            MainUserPage{}
        }

        Component{
            id: memePage
            MemePage{}
        }

        Component{
            id: rialtoPage
            RialtoPage{}
        }
        Component{
            id: categoryMemeListPage
            CategoryMemeListPage{}
        }
        Component{
            id: adsPage
            AdsPage{}
        }

        Component{
            id: usersRatingPage
            UsersRatingPage{}
        }
    }

    Hamburger{
        id: hamburger
        height: slidingMenu.height / 40
        width: height * 3 / 2
        anchors{ left: slidingMenu.right; leftMargin: width; }
        y: slidingMenu.y + height * 1.5
        z: slidingMenu.z
        onOpenAction: slidingMenu.show()
        onBackAction: slidingMenu.hide()
    }

    SlidingMenu{
        id: slidingMenu
        onOpenChanged: {
            hamburger.state = open ? hamburger.state = "back" : hamburger.state = "menu"
        }

        itemData:[
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
                        text:"биржа мемов"
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
                Rectangle{
                    width: parent.width
                    height: 1
                    color: Qt.darker("lightgrey", 1.2)
                }
                Rectangle{
                    id: ads
                    width: parent.width
                    height: parent.height / 10
                    color: "lightgrey"
                    Text{
                        text:"реклама"
                        font.pixelSize: parent.height / 3
                        anchors.centerIn: parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            User.getAdList()
                            stackView.push(adsPage)
                            slidingMenu.hide()
                        }
                    }
                }
                Rectangle{
                    width: parent.width
                    height: 1
                    color: Qt.darker("lightgrey", 1.2)
                }
                Rectangle{
                    id: usersRating
                    width: parent.width
                    height: parent.height / 10
                    color: "lightgrey"
                    Text{
                        text:"рейтинг"
                        font.pixelSize: parent.height / 3
                        anchors.centerIn: parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            stackView.push(usersRatingPage)
                            slidingMenu.hide()
                        }
                    }
                }
                Rectangle{
                    width: parent.width
                    height: 1
                    color: Qt.darker("lightgrey", 1.2)
                }
                Rectangle{
                    id: signOut
                    width: parent.width
                    height: parent.height / 10
                    color: "lightgrey"
                    Text{
                        text:"выход"
                        font.pixelSize: parent.height / 3
                        anchors.centerIn: parent
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            exitDialog.open()
                        }
                    }
                }
            }
        ]
    }

    Dialog {
        id: exitDialog
        title: "Выход"
        contentItem: Rectangle{
            width: mainWindow.width * 5/6
            height: width / 3
            Column{
                anchors.fill: parent
                Text{
                    text: "Вы уверены, что хотите выйти?"
                    height: parent.height / 2
                    width: parent.width
                }
                Row{
                    height: parent.height / 2
                    width: parent.width
                    MaterialButton{
                        label: "выйти"
                        labelSize: height / 4
                        width: parent.width / 2
                        height: parent.height
                        clickableColor: Qt.lighter(mainColor, 1.5)
                        rippleColor: Qt.lighter(clickableColor)
                        z: cancelButton.z + 1
                        onClicked: {
                            exitDialog.close()
                            slidingMenu.hide()
                            User.signOut()
                            stackView.pop(signInPage)
                        }
                    }
                    MaterialButton{
                        id: cancelButton
                        label: "отмена"
                        labelSize: height / 4
                        width: parent.width / 2
                        height: parent.height
                        clickableColor: Qt.lighter(mainColor, 1.5)
                        rippleColor: Qt.lighter(clickableColor)
                        onClicked: {
                            exitDialog.close()
                        }
                    }
                }
            }
        }
    }


    AdMob {
        appId: "ca-app-pub-5551381749080346~2416103256"
            //Qt.platform.os == "android" ? "ca-app-pub-6606648560678905~6485875670" : "ca-app-pub-6606648560678905~1693919273"

        testDevices: [
            "01987FA9D5F5CEC3542F54FB2DDC89F6",
            "d206f9511ffc1bc2c7b6d6e0d0e448cc"
        ]
    }
}
