import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

Page {
    id:signInPage

    Component{ id: mainUserPageComponent; MainUserPage{} }

    Image{
        id:background
        width: signInPage.width; height: signInPage.height
        source:"../assets/background.jpg"
        visible: false
    }
    GaussianBlur{
        id:blur
        anchors.fill: parent
        source:background
        radius: 8
        samples: 16
    }

        Rectangle{
            id:signInPlane
            width: background.width* 3/4; height: background.height/2
            anchors.centerIn: background
            radius: 25
            opacity: 0.75
            color:"#ffffff"
        }

        Item{
            anchors.centerIn: signInPlane
            width: signInPlane.width* 3/4; height: signInPlane.height/2

            AppTextField {
                id: loginRow
                anchors{ top: parent.top; topMargin: height/2 }
                height: parent.height/5; width: parent.width
                radius: 10
                maximumLength: 20
                placeholderText: "логин"
                z:1
            }

            AppTextField {
                id: passwordRow
                anchors{ top: loginRow.bottom; topMargin: height/2 }
                height: parent.height/5; width: parent.width
                radius: 10
                maximumLength: 16
                placeholderText: "пароль"
                echoMode: TextInput.Password


                property string currText

                Rectangle{
                    property color activeColor: "#bdbdbd"
                    property color passiveColor: "#d5d5d5"

                    id: passwordVis
                    anchors{right: passwordRow.right; top: passwordRow.top}
                    height: passwordRow.height; width: height
                    color: passiveColor
                    radius: passwordRow.radius

                    Rectangle{
                        height: parent.height; width: parent.width/2
                        anchors{ left: parent.left; top: parent.top }
                        color: parent.color
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            if(passwordVis.color == parent.activeColor){
                                passwordVis.color = parent.passiveColor
                                passwordRow.echoMode = TextInput.Password
                            }
                            else{
                                passwordVis.color = parent.activeColor
                                passwordRow.echoMode = TextInput.Normal
                            }
                        }
                    }
                }

            AppButton{
                id:signInButton
                width: passwordRow.width/2; height: passwordRow.height
                anchors{ horizontalCenter: parent.horizontalCenter; top: passwordRow.bottom;
                    topMargin: passwordRow.height/2 }
                text:"вход"
                onClicked:{
                    navigationStack.push(mainUserPageComponent)
                }
            }

            Rectangle{
                color:"#507299"
                width:passwordRow.width; height:passwordRow.height* 2
                anchors{top: signInButton.bottom; topMargin:passwordRow.height/2 }
            }
        }
        }
}
