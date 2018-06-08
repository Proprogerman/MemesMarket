import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2

import Qt.labs.settings 1.0

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

    Settings{
        id: userSettings
        category: "user"
        property string name
        property string passwordHash
    }

//    Component.onCompleted:{
//        if(userSettings.signed){
//            User.autoSignIn()
//            stackView.initialItem = mainUserPage
//        }
//        else
//            stackView.initialItem = signInPage
//    }

    StackView{
        id: stackView
        anchors.fill: parent
        initialItem: userSettings.name === "" ? signInPage : mainUserPage

        onCurrentItemChanged: {
            hamburger.visible = stackView.currentItem.objectName == "mainUserPage" ? true : false
            slidingMenu.active = stackView.currentItem.objectName == "signInPage" ? false : true
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

                return currTransition
            }
            function transitionFinished(properties){
                properties.exitItem.x = 0
                properties.exitItem.y = 0
                properties.exitItem.opacity = 1
            }
            property Component someTransition: StackViewTransition{
//                ScriptAction{ script: console.log("exitItem: ", exitItem.Stack.index) }
//                ScriptAction{ script: console.log("enterItem: ", enterItem.Stack.index) }
                PropertyAnimation{
                    target: exitItem
                    property: "x"
                    from: target.Stack.index > enterItem.Stack.index ? 0 : 0
                    to: target.Stack.index > enterItem.Stack.index ? target.width : -target.width
                    duration: 100
                }
                PropertyAnimation{
                    target: enterItem
                    property: "x"
                    from: target.Stack.index < exitItem.Stack.index ? -exitItem.width : exitItem.width
                    to: target.Stack.index < exitItem.Stack.index ? 0 : 0
                    duration: 100
                }
            }

            property Component fromSignToMainTransition: StackViewTransition {
                SequentialAnimation{
                    PropertyAnimation{
                        target: enterItem
                        property: "opacity"
                        from: 0
                        to: 1
                        duration: 100
                    }
                    ScriptAction{ script: enterItem.state = "normal" }
                }
            }

            property Component fromMainToSignTransition: StackViewTransition {
                SequentialAnimation{
                    ScriptAction{ script: exitItem.state = "hidden" }
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
                    ScriptAction{ script: enterItem.transformOrigin = Item.TopLeft }
                    ScriptAction{ script: enterItem.state = "hidden" }
                    ParallelAnimation{
                        PropertyAnimation{
                            target: enterItem
                            property: "y"
                            from: exitItem.clickedMemeOnList - target.height / 10 * target.scale
                            to: 0
                            duration: 350
                        }
                        PropertyAnimation{
                            target: enterItem
                            property: "scale"
                            from: exitItem.clickedMemeImageSize / (target.width / 2)
                            to: 1
                            duration: 350
                        }
                        PropertyAnimation{
                            target: enterItem
                            property: "x"
                            from: -target.width / 4 * target.scale
                            to: 0
                            duration: 350
                        }
                        PropertyAnimation{
                            target: enterItem
                            property: "opacity"
                            from: 0.5
                            to: 1
                            duration: 350
                        }
                    }
                    ScriptAction{ script: enterItem.state = "normal" }
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
            id: usersRatingPage
            UsersRatingPage{}
        }
    }

    Hamburger{
        id: hamburger
        height: slidingMenu.height / 40//pageHeader.height / 4
        width: height * 3 / 2
        anchors{ left: slidingMenu.right; leftMargin: width; /*verticalCenter: pageHeader.verticalCenter*/ }
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
                }
                Row{
                    height: parent.height / 2
                    width: parent.width
                    anchors{ left: parent.left; right: parent.right; bottom: parent.bottom }
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
