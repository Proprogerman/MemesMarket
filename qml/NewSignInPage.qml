import VPlayApps 1.0
import QtQuick 2.0
import QtGraphicalEffects 1.0

import io.qt.ServerConnection 1.0

Page{
    id:newSignInPage

    ServerConnection{
    id: serverConnection
        onNameIsExist:{
            nameOfGroup.state = "nameIsExistState"
            nameOfGroup.color = "#F8BBD0"
        }
        onNameIsCorrect:{
            nameOfGroup.state = "nameIsValidState"
            nameOfGroup.color = "#507299"
        }
    }


    property string indicateMessage

    function signUpButtonCheck(){
        if(nameOfGroup.color == "#507299" && password.color == "#507299")
            signUpButton.visible = true
        else
            signUpButton.visible = false
    }

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

            states: [
                State{
                    name:"nameInputState"
                    PropertyChanges{ target: indicateMessage;  text:"Придумайте название группы" }
                    PropertyChanges{ target: indicateImage; source:"../assets/mem_hmm.png"}
                },
                State{
                    name:"nameIsValidState"
                    PropertyChanges{ target: indicateMessage; text:"Название доступно" }
                    PropertyChanges{ target: indicateImage; source:"../assets/okMeme.png" }
                },
                State{
                    name:"nameIsExistState"
                    PropertyChanges{ target: indicateMessage; text: "Имя занято, придумайте другое" }
                    PropertyChanges{ target: indicateImage; source:"../assets/noMeme.png" }
                }
            ]

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
                    if(getText(0,length) != '' && activeFocus == false)
                        serverConnection.user_name = nameInputRow.getText(0, nameInputRow.length)
                    signUpButtonCheck()
                }
            }
        }

        Rectangle{
            id: password
            width: parent.width; height: nameInputRow.height * 2
            anchors.top: nameOfGroup.bottom
            anchors.topMargin: height * 1/20
            color:"#edeef0"

            states:[
                State{
                    name:"passwordHasFewerCharsState"
                    PropertyChanges{ target: indicateMessage; text: "Пароль должен быть длиннее 6-ти символов" }
                    PropertyChanges{ target: indicateImage; source:"../assets/noMeme.png" }
                },
                State{
                    name:"passwordIsOkState"
                    PropertyChanges{ target: indicateMessage; text: "Пароль удовлетворяет требованиям" }
                    PropertyChanges{ target: indicateImage; source:"../assets/okMeme.png" }
                }
            ]

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
                onTextChanged:{
                    if(length < 6){
                        password.color = "#F8BBD0"
                        password.state = "passwordHasFewerCharsState"
                    }
                    else{
                        password.color = "#507299"
                        password.state = "passwordIsOkState"
                    }
                    signUpButtonCheck()
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
        AppButton{
            id: signUpButton
            width: passwordInputRow.width; height: password.height
            anchors{ top: password.bottom; horizontalCenter: parent.horizontalCenter }
            text:"создать"
            visible: false

            onClicked:{
                serverConnection.user_name = nameInputRow.getText(0, nameInputRow.length)
                serverConnection.user_password = passwordInputRow.getText(0, passwordInputRow.length)
                serverConnection.signUp()
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
