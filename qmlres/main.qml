import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Window 2.0

import "qrc:/qml/pages"

    ApplicationWindow{
        visible: true
        height: 720
        width: 405
        x: 300 ; y: 50

//    Loader{id:pageLoader}
//    Component.onCompleted: pageLoader.source="SignInPage.qml"
//    NewSignInPage{}

    StackView{
        id:stackView
        anchors.fill: parent
        initialItem: mainUserPage

        Component{
            id: signInPage
            SignInPage{}
        }

        Component{
            id: mainUserPage
            MainUserPage{}
        }

        Component{
            id: memesPage
            MemePage{}
        }
    }
}
