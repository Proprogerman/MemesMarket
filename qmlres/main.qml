import QtQuick 2.11
import QtQuick.Controls 1.4
import QtQuick.Controls.Material 2.2
import QtQuick.Controls.Universal 2.2
import QtQuick.Window 2.3
import QtQuick.Dialogs 1.2


import "qrc:/qml/pages"
import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

import QtFirebase 1.0

ApplicationWindow{
    id: mainWindow
    visible: true
    height: 720
    width: 405
//    x: 300 ; y: 50                           //for desktop

    visibility: ApplicationWindow.FullScreen               // for mobile

    Item{
        focus: true
        Keys.onReleased: {
            if(event.key === Qt.Key_Back)
            {
                event.accepted = true;
                var currItm = stackView.currentItem.objectName
                if(stackView.currentItem.objectName !== "mainUserPage" || stackView.currentItem.objectName !== "signInPage")
                {
                    stackView.pop()
                }
                else
                {
                    Qt.quit();
                }
            }
        }
    }

    onClosing: {
        close.accepted = true
    }

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
                var exitItemName = properties.exitItem.objectName
                var enterItemName = properties.enterItem.objectName
                if(exitItemName === "signInPage" && enterItemName === "mainUserPage")
                    currTransition = fromSignToMainTransition
                else if(exitItemName === "mainUserPage" && enterItemName === "signInPage")
                    currTransition = fromMainToSignTransition
                else if(enterItemName === "memePage")
                    currTransition = memePageTransition
                else if(exitItemName === "memePage" && enterItemName === "mainUserPage"
                && User.findMeme(properties.exitItem.name))
                    currTransition = fromMemePageTransition
                else if(properties.exitItem.objectName === "memePage"&& properties.enterItem.objectName === "categoryMemeListPage")
                    currTransition = fromMemePageTransition

                return currTransition
            }
            function transitionFinished(properties){
                var exitItemName = properties.exitItem.objectName
                var enterItemName = properties.enterItem.objectName
                properties.exitItem.x = 0
                properties.exitItem.y = 0
                properties.exitItem.opacity = 1
                if(exitItemName === "memePage" && enterItemName === "mainUserPage"
                || enterItemName === "categoryMemeListPage")
                    properties.enterItem.setVisibilityImageOnList(true)
                else if(exitItemName === "signInPage")
                    properties.exitItem.clearUserData()
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
                        duration: 650
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
                    ScriptAction{ script: enterItem.setImageOrigin(Item.TopLeft) }
                    ParallelAnimation{
                        PropertyAnimation{
                            target: enterItem
                            property: "memeImageY"
                            from: exitItem.clickedMemeOnList.y
                            to: target.memeImageY
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
                    ScriptAction{ script: enterItem.setImageOrigin(Item.Top) }
                }
            }

            property Component fromMemePageTransition: StackViewTransition {
                SequentialAnimation{
                    ScriptAction{ script: exitItem.state = "hidden" }
                    ScriptAction{ script: enterItem.getClosingMemePosition(exitItem.name)}
                    ScriptAction{ script: exitItem.setImageOrigin(Item.TopLeft) }
                        ParallelAnimation{
                            PropertyAnimation{
                                target: exitItem
                                property: "memeImageY"
                                from: exitItem.memeImageY
                                to: enterItem.getClosingMemePosition(exitItem.name).y - enterItem.contentY
                                duration: 200
                                easing.type: Easing.OutCirc
                            }
                            PropertyAnimation{
                                target: exitItem
                                property: "memeImageScale"
                                from: exitItem.memeImageScale
                                to: enterItem.clickedMemeImageSize / (target.width / 2)
                                duration: 200
                                easing.type: Easing.OutCirc
                            }
                            PropertyAnimation{
                                target: exitItem
                                property: "memeImageX"
                                from: exitItem.memeImageScale === 1 ? exitItem.memeImageX : exitItem.memeImageX - (exitItem.memeImageWidth / 2)
                                to: enterItem.clickedMemeOnList.x
                                duration: 200
                                easing.type: Easing.OutCirc
                            }
                    }
                    ScriptAction{ script: exitItem.setImageOrigin(Item.Top) }
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
        color: Qt.lighter("#7fa0ca")

        itemData:[
            Column{
                width: parent.width
                height: parent.height
                Image{
                    id: bigAvatar
                    width: parent.width
                    height: width
                    sourceSize.height: height
                    sourceSize.width: width
                    cache: false
                }
                MaterialButton{
                    id: memesExchange
                    width: parent.width
                    height: parent.height / 10
                    clickableColor: slidingMenu.color
                    label: qsTr("биржа мемов") + translator.emptyString
                    labelSize: height / 4
                    z: bigAvatar.z - 1
                    onClicked:{
                        User.getMemesCategories()
                        stackView.push(rialtoPage)
                        slidingMenu.hide()
                    }
                }
                MaterialButton{
                    id: ads
                    width: parent.width
                    height: parent.height / 10
                    clickableColor: slidingMenu.color
                    label: qsTr("реклама") + translator.emptyString
                    labelSize: height / 4
                    z: memesExchange.z - 1
                    property string lang: "ru"
                    onClicked:{
                        User.getAdList()
                        stackView.push(adsPage)
                        slidingMenu.hide()
                    }
                }
                MaterialButton{
                    id: usersRating
                    width: parent.width
                    height: parent.height / 10
                    clickableColor: slidingMenu.color
                    label: qsTr("рейтинг") + translator.emptyString
                    labelSize: height / 4
                    z: ads.z - 1
                    onClicked:{
                        stackView.push(usersRatingPage)
                        slidingMenu.hide()
                    }
                }
                MaterialButton{
                    id: signOut
                    width: parent.width
                    height: parent.height / 10
                    clickableColor: slidingMenu.color
                    label: qsTr("выход") + translator.emptyString
                    labelSize: height / 4
                    z: usersRating.z - 1
                    onClicked:{
                        exitDialog.open()
                    }
                }
            }
        ]
    }

    Dialog {
        id: exitDialog
        title: qsTr("Выход") + translator.emptyString
        contentItem: Rectangle{
            width: mainWindow.width * 5/6
            height: width / 3
            Column{
                anchors.fill: parent
                Text{
                    text: qsTr("Вы уверены, что хотите выйти?") + translator.emptyString
                    height: parent.height / 2
                    width: parent.width
                    font.pixelSize: height / 4
                    horizontalAlignment: Text.AlignLeft
                    wrapMode: Text.WordWrap
                }
                Row{
                    height: parent.height / 2
                    width: parent.width
                    MaterialButton{
                        label: qsTr("выйти") + translator.emptyString
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
                        label: qsTr("отмена") + translator.emptyString
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
        appId: User.getConfData("appData.json", "AdMob", "appId")
    }
}
