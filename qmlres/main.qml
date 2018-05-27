import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Window 2.0

import "qrc:/qml/pages"
import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

import QtFirebase 1.0

ApplicationWindow{
    visible: true
    height: 720                                 //
    width: 405                                  // for desktop
    x: 300 ; y: 50                              //

//    visibility: Window.FullScreen               // for mobile

    StackView{
        id:stackView
        anchors.fill: parent
        initialItem: signInPage

        onCurrentItemChanged: {
            hamburger.visible = stackView.currentItem.objectName == "mainUserPage" ? true : false
            slidingMenu.active = stackView.currentItem.objectName == "signInPage" ? false : true
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
                        text:"Биржа мемов"
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
            }
        ]
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
