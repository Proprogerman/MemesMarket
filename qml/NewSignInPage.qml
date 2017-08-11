import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import io.qt.ServerConnection 1.0

Page {
    id:newSignInPage

    ServerConnection{ id: serverConnection }

    property string indicateMessage

    Rectangle{
        id: background
        anchors.fill: parent
        color:"#78909C"
        z: -2
    }
    Item{
        id: indicateZone
        width: background.width; height: background.height * 1/3
        anchors.top: background.top
        z: -1
        state:"inputNameState"

        AppText{
            id: indicateMessage
            anchors{ left: parent.left; right: parent.right; top: parent.top}
            font.family: "Impact"
            color: "lightgrey"
            font.pixelSize: parent.height * 1/6
            horizontalAlignment: Text.AlignRight
        }
        AppImage{
            id: indicateImage
            height: parent.height * 3/4; width: height
            anchors{ bottom: parent.bottom; left: parent.left }
            opacity: 0.5
        }

        states: [
            State{
                name:"inputNameState"
                PropertyChanges{ target: indicateMessage;  text:"Придумайте название группы" }
                PropertyChanges{ target: indicateImage; source:"../assets/mem_hmm.png"}
            },
            State{
                name:"nameIsCorrectState"
                PropertyChanges{ target: indicateMessage; text:"Название доступно" }
                PropertyChanges{ target: indicateImage; source:"../assets/okMeme.png" }
            },
            State{
                name:"nameIsExistState"
                PropertyChanges{ target: indicateMessage; text: "Имя занято, придумайте другое"}
                PropertyChanges{ target: indicateImage; source:"../assets/noMeme.png" }
            }
        ]

        /*
            реализовать обработку текущего статуса регистрации для индикатора
        */
    }

    Rectangle{
        id: dataSheet
        width: background.width; height: background.height * 2/3
        anchors.bottom: background.bottom
        color:"#CFD8DC"
        Rectangle{
            id: nameOfGroup
            width: parent.width; height: nameInputRow.height * 2
            anchors.top: parent.top
            color:"#edeef0"

            AppTextField{
                id: nameInputRow
                width: parent.width * 3/4; height: width * 1/7;
                anchors.centerIn: parent
                radius: height * 1/4
                font.family:"Roboto"
                font.pixelSize: height * 1/2
                placeholderText:"Название группы"
                maximumLength: 16
                validator: RegExpValidator{regExp: /^[^\s][\w\s]+$/}

                backgroundColor: "#ffffff"
                onActiveFocusChanged: {
                    if(activeFocus == true)
                        backgroundColor = "lightgrey"
                    else
                        backgroundColor = "#ffffff"
                }
            }
//            AppButton{
//                height: nameInputRow.height; width: height
//                minimumHeight: height; minimumWidth: width
//                anchors.verticalCenter: parent.verticalCenter
//                radius: nameInputRow.radius
//            }
        }

        Rectangle{
            id: password
            width: parent.width; height: nameInputRow.height * 2
            anchors.top: nameOfGroup.bottom
            anchors.topMargin: height * 1/20
            color:"#edeef0"
            AppTextField{
                id: passwordInputRow
                width: parent.width * 3/4; height: width * 1/7
                anchors.centerIn: parent
                radius: height * 1/4
                font.family:"Roboto"
                font.pixelSize: height * 1/2
                placeholderText:"Пароль"
                maximumLength: 16
                validator: RegExpValidator{regExp:/[a-zA-Z1-9\!\@\#\$\%\^\&\*\(\)\-\_\+\=\;\:\,\.\/\?\\\|\`\~\[\]\{\}]{6,}/}
                backgroundColor: "#ffffff"
                echoMode: TextInput.Password
                onActiveFocusChanged: {
                    if(activeFocus == true)
                        backgroundColor = "lightgrey"
                    else
                        backgroundColor = "#ffffff"
                }
                Rectangle{
                    id: passwordVis

                    property color activeColor:"#757575"
                    property color inactiveColor:"#BDBDBD"

                    height: parent.height; width: height
                    anchors{right: parent.right; top: parent.top}
                    radius: passwordInputRow.radius
                    color: inactiveColor
                    Rectangle{
                        height: parent.height; width: height * 1/2
                        anchors{left: parent.left; top: parent.top}
                        color: parent.color
                    }
                    MouseArea{
                        anchors.fill: parent
                        onClicked:{
                            if(passwordVis.color == passwordVis.activeColor){
                                passwordVis.color = passwordVis.inactiveColor
                                passwordInputRow.echoMode = TextInput.Password
                                }
                            else{
                                passwordVis.color = passwordVis.activeColor
                                passwordInputRow.echoMode = TextInput.Normal
                            }
                        }
                    }
                }
            }
        }

    }
    DropShadow{
        anchors.fill: dataSheet
        horizontalOffset: 0
        verticalOffset: - indicateZone.height * 1/10
        radius: 20
        samples: 17
        color:"#80000000"
        source: dataSheet
        opacity: 0.5
    }

}
