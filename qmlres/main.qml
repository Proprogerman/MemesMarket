import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Window 2.0

import "qrc:/qml/pages"

    ApplicationWindow{
        visible: true
//        height: 720
//        width: 405
//        x: 300 ; y: 50
        height: 1280
        width: 720


    // You get free licenseKeys from https://v-play.net/licenseKey
    // With a licenseKey you can:
    //  * Publish your games & apps for the app stores
    //  * Remove the V-Play Splash Screen or set a custom one (available with the Pro Licenses)
    //  * Add plugins to monetize, analyze & improve your apps (available with the Pro Licenses)

//    Loader{id:pageLoader}
//    Component.onCompleted: pageLoader.source="SignInPage.qml"
//    NewSignInPage{}

    StackView{
        id:stackView
        anchors.fill: parent
        initialItem: signInPage

        Component{
            id: signInPage
            SignInPage{}
        }

//        Component{
//            id: mainUserPage
//            MainUserPage{}
//        }

        Component{
            id: memesPage
            MemesPage{}
        }
    }
}
