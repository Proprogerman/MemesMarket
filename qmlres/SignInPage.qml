import QtQuick 2.11
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import Qt.labs.settings 1.0

import KlimeSoft.SingletonUser 1.0

import "qrc:/qml/elements"

Page{
    id: signInPage

    objectName: "signInPage"

    property color mainColor: "#507299"
    property color backColor: "#78909C"
    property color dataColor: "#CFD8DC"
    property color errColor: "#EA7171"

    property string mode: "signUp"

    property alias backgroundColor: background.color

    signal panelWasHidden()

    function toUserPage(){
        stackView.push(mainUserPage)
        signInPage.panelWasHidden.disconnect(toUserPage)
    }

    Connections{
        target: User
        onNameExist: { nameOfGroup.state = indicateZone.state = "nameExistState" }
        onNameDoesNotExist: { nameOfGroup.state = indicateZone.state = "nameDoesNotExistState" }
        onSignAnswered: {
            checkForAnswerTimer.stop()
            if(progress){
                User.user_name = name
                if(!signInPage.transitions[0].running)
                    stackView.push(mainUserPage)
                else
                    signInPage.panelWasHidden.connect(toUserPage)
            }
            else{
                indicateZone.state = mode == "signUp" ? "signUpErrorState" : "signInErrorState"
                signInPage.state = "normal"
            }
        }
    }

    Settings{
        id: userSettings
        category: "user"
        property string name
        property string passwordHash
    }

    Component.onCompleted: {
        if(userSettings.name === "")
            stateTimer.start()
        else{
            User.autoSignIn()
            nameInputRow.insert(0, userSettings.name)
            checkForAnswerTimer.start()
        }
    }

    function clearUserData(){
        nameInputRow.clear()
        passwordInputRow.clear()
    }

    Timer{
        id: stateTimer
        interval: 1
        onTriggered: signInPage.state = "normal"
    }

    Timer{
        id: checkForAnswerTimer
        interval: 10000
        repeat: false
        onTriggered: {
            signInPage.state = "normal"
            indicateZone.state = mode === "signUp" ? "signUpErrorState" : "signInErrorState"
            User.connectToHost()
        }
    }

    onModeChanged: {
        signUpButtonCheck()
    }

    property string indicateMessage

    function signUpButtonCheck(){
        if(mode == "signUp"){
            if(nameOfGroup.state == "nameDoesNotExistState" && password.state == "passwordIsOkState")
                signUpButton.clickable = true
            else
                signUpButton.clickable = false
        }
        else{
            if(nameOfGroup.state == "nameExistState" && password.state == "passwordIsOkState")
                signUpButton.clickable = true
            else
                signUpButton.clickable = false
        }
    }

    states: [
        State{
            name: "normal"
            AnchorChanges{ target: dataSheet; anchors.top: indicateZone.bottom }
            PropertyChanges{ target: dataSheetShadow; opacity: 0.35 }
            PropertyChanges{ target: indicateZone; visible: true }
            StateChangeScript{
                name: "activeFocusChange";
                script: {
                    if(nameInputRow.getText(0, nameInputRow.length) === "")
                        nameInputRow.forceActiveFocus()
                }
            }
        },
        State{
            name: "hidden"
            AnchorChanges{ target: dataSheet; anchors.top: background.bottom }
            PropertyChanges{ target: dataSheetShadow; opacity: 0.0 }
            PropertyChanges{ target: indicateZone; visible: false}
            StateChangeScript{ name: "hiddenSignalScript"; script: panelWasHidden() }
        }
    ]

    transitions: Transition{
        id: signTransition
        SequentialAnimation{
            ParallelAnimation{
                AnchorAnimation{ duration: 650; easing.type: Easing.InOutElastic; easing.period: 1.0; easing.amplitude: 1.0 }
                PropertyAnimation{ property: "opacity"; duration: 650; easing.type: Easing.InOutElastic }
                PropertyAnimation{ property: "visible"; duration: signInPage.state == "hidden" ? 0 : 650 }
            }
            ScriptAction{ scriptName: "hiddenSignalScript" }
            ScriptAction{ scriptName: "activeFocusChange" }
        }
    }

    state: "hidden"

    Rectangle{
        id: background
        anchors.fill: parent
        color: backColor
        z: -2
    }
    Item{
        id: indicateZone
        width: background.width; height: background.height * 1/3
        anchors.top: background.top
        z: -1
        state: "nameInputState"

        Text{
            id: indicateMessage
            anchors{ left: indicateImage.right; right: parent.right; top: parent.top}
            font.family: "Impact"
            color: "#ffffff"
            font.pixelSize: parent.height * 1/6
            horizontalAlignment: Text.AlignRight
            wrapMode: Text.WordWrap
            z: indicateImage.z + 1
        }
        Image{
            id: indicateImage
            height: parent.height * 3/4; width: height
            anchors{ bottom: parent.bottom; left: parent.left }
        }

        states: [
            State{
                name: "nameInputState"
                PropertyChanges{ target: indicateMessage;  text: mode == "signUp" ? "Придумайте название группы" :
                                                                                    "Введите название группы" }
                PropertyChanges{ target: indicateImage; source: "qrc:/memePhoto/mem_hmm.png"}
            },
            State{
                name: "nameDoesNotExistState"
                PropertyChanges{ target: indicateMessage; text: mode == "signUp" ? "Название доступно" :
                                                                                    "Такого имени нет" }
                PropertyChanges{ target: indicateImage; source: mode == "signUp" ? "qrc:/memePhoto/okMeme.png" :
                                                                                   "qrc:/memePhoto/noMeme.png" }
            },
            State{
                name: "nameExistState"
                PropertyChanges{ target: indicateMessage; text: mode == "signUp" ? "Название занято" :
                                                                                   "Ок!" }
                PropertyChanges{ target: indicateImage; source: mode == "signUp" ? "qrc:/memePhoto/noMeme.png" :
                                                                                   "qrc:/memePhoto/okMeme.png" }
            },
            State{
              name: "passwordInputState"
              PropertyChanges{ target: indicateMessage; text: mode == "signUp" ? "Придумайте пароль" :
                                                                                 "Введите пароль" }
              PropertyChanges{ target: indicateImage; source: "qrc:/memePhoto/mem_hmm.png" }
            },
            State{
                name: "passwordIsOkState"
                PropertyChanges{ target: indicateMessage; text: "Пароль удовлетворяет требованиям" }
                PropertyChanges{ target: indicateImage; source: "qrc:/memePhoto/okMeme.png" }
            },
            State{
                name: "passwordHasFewerCharsState"
                PropertyChanges{ target: indicateMessage; text: "Пароль должен быть не менее 6-ти символов" }
                PropertyChanges{ target: indicateImage; source: "qrc:/memePhoto/noMeme.png" }
            },
            State{
                name: "signUpErrorState"
                PropertyChanges{ target: indicateMessage; text: "Ошибка при создании, попробуйте ещё" }
                PropertyChanges{ target: indicateImage; source: "qrc:/memePhoto/noMeme.png" }
            },
            State{
                name: "signInErrorState"
                PropertyChanges{ target: indicateMessage; text: "Вход не выполнен, проверьте название и пароль" }
                PropertyChanges{ target: indicateImage; source: "qrc:/memePhoto/noMeme.png" }
            }
        ]
    }

    Rectangle{
        id: dataSheet
        width: background.width; height: background.height
        color: dataColor

        Rectangle{
            id: nameOfGroup
            width: parent.width; height: Math.ceil(signInPage.height / 8)
            anchors.top: parent.top
            color: "#edeef0"

            states:[
                State{
                    name: "nameInputState"
                    PropertyChanges{ target: nameOfGroup; color: "#edeef0" }
                },
                State{
                    name: "nameDoesNotExistState"
                    PropertyChanges{ target: nameOfGroup; color: mode == "signUp" ? mainColor : errColor }
                },
                State{
                    name: "nameExistState"
                    PropertyChanges{ target: nameOfGroup; color: mode == "signUp" ? errColor : mainColor }
                }
            ]
            state: "nameInputState"

            onStateChanged: {
                signUpButtonCheck()
            }

            TextField{
                id: nameInputRow
                width: parent.width * 3 / 4; height: parent.height / 2
                anchors.centerIn: parent
                font.family: "Roboto"
                font.pixelSize: height / 2
                placeholderText: "Название группы"
                maximumLength: 16
                validator: RegExpValidator{regExp: /^[^\s][\w\s]+$/}
                inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
                property color backgroundColor: "#ffffff"

                background: Rectangle{
                    anchors.fill: parent
                    radius: parent.height / 2
                    color: parent.backgroundColor
                }

                Timer{
                    id: submitTimer
                    interval: 3000
                    running: false
                    repeat: false
                    onTriggered:{
                        if(nameInputRow.getText(0, nameInputRow.length) !== '')
                            User.checkName(nameInputRow.getText(0, nameInputRow.length))
                        }
                }

                onActiveFocusChanged: {
                    if(activeFocus == true){
                        indicateZone.state = nameOfGroup.state
                        backgroundColor = "lightgrey"
                        if(nameInputRow.getText(0, nameInputRow.length) !== '')
                            User.checkName(nameInputRow.getText(0, nameInputRow.length))
                    }
                    else
                        backgroundColor = "#ffffff"
                    }
                onTextChanged: {
                    nameOfGroup.state = indicateZone.state = "nameInputState"
                    if(nameInputRow.getText(0, nameInputRow.length) !== '')
                        submitTimer.start()
                }
            }
        }

        Rectangle{
            id: password
            width: parent.width; height: Math.ceil(signInPage.height / 8)
            anchors.top: nameOfGroup.bottom
            anchors.topMargin: height * 1/20
            color: "#edeef0"

            states:[
                State{
                    name: "passwordInputState"
                    PropertyChanges{ target: password; color: "#edeef0" }
                },
                State{
                    name:"passwordIsOkState"
                    PropertyChanges{ target: password; color: mainColor }
                },
                State{
                    name: "passwordHasFewerCharsState"
                    PropertyChanges{ target:password; color: errColor }
                }
            ]
            state: "passwordInputState"

            onStateChanged: {
                signUpButtonCheck()
            }

            TextField{
                id: passwordInputRow
                width: parent.width * 3 / 4; height: parent.height / 2
                anchors.centerIn: parent
                font.family:"Roboto"
                font.pixelSize: height / 2
                placeholderText:"Пароль"
                maximumLength: 16
                validator: RegExpValidator{regExp:/[a-zA-Z1-9\!\@\#\$\%\^\&\*\(\)\-\_\+\=\;\:\,\.\/\?\\\|\`\~\[\]\{\}]{6,}/}
                property color backgroundColor: "#ffffff"
                echoMode: TextInput.Password
                inputMethodHints: Qt.ImhNoAutoUppercase

                background: Rectangle{
                    id: passwordBackground
                    anchors.fill: parent
                    radius: height / 2
                    color: parent.backgroundColor
                }

                onActiveFocusChanged: {
                    if(activeFocus == true){
                        indicateZone.state = password.state
                        backgroundColor = "lightgrey"
                    }
                    else
                        backgroundColor = "#ffffff"
                }
                onTextChanged:{
                    if(length < 6){
                        if(length === 0)
                            password.state = indicateZone.state = "passwordInputState"
                        else{
                            password.color = errColor
                            password.state = indicateZone.state = "passwordHasFewerCharsState"
                        }
                    }
                    else{
                        password.color = mainColor
                        password.state = indicateZone.state = "passwordIsOkState"
                    }
                }

                Rectangle{
                    id: passwordVis

                    property color activeColor:"#757575"
                    property color inactiveColor:"#BDBDBD"

                    height: parent.height + 2; width: height
                    anchors{ left: parent.left; leftMargin: parent.width - width + 1; verticalCenter: parent.verticalCenter }
                    radius: passwordInputRow.height / 2
                    color: inactiveColor
                    Rectangle{
                        height: parent.height; width: height / 2
                        anchors{ left: parent.left; verticalCenter: parent.verticalCenter }
                        radius: height / 10
                        color: parent.color
                    }
                    Image{
                        anchors.centerIn: parent
                        height: parent.height * 3 / 4
                        width: height
                        antialiasing: true
                        mipmap: true
                        source: "qrc:/uiIcons/eyeIcon.svg"
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

        MaterialButton{
            id: signUpButton
            width: password.width; height: password.height
            anchors{ top: password.bottom; topMargin: height/20; horizontalCenter: parent.horizontalCenter }
            label: mode == "signUp" ? "создать" : "войти"
            labelSize: height / 4
            radius: height/10
            clickableColor: mainColor
            unclickableColor: "#edeef0"
            rippleColor: Qt.lighter(clickableColor, 1.5)
            clickable: false

            onClicked:{
                signInPage.state = "hidden"
                if(mode == "signUp"){
                    User.signUp(nameInputRow.getText(0, nameInputRow.length),
                                passwordInputRow.getText(0, passwordInputRow.length))
                }
                else{
                    User.signIn(nameInputRow.getText(0, nameInputRow.length),
                                passwordInputRow.getText(0, passwordInputRow.length))
                }
                checkForAnswerTimer.start()
            }
        }

        Row{
            height: nameOfGroup.height / 2
            width: nameOfGroup.width / 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: signUpButton.bottom
            anchors.topMargin: height / 10
            CheckButton{
                id: signUpToggle
                label: "создать"
                height: parent.height
                width: parent.width / 2
                checkedColor: "#90A4AE"
                uncheckedColor: "#CFD8DC"
                checked: true
                uncheckWithTap: false
                onCheckedChanged: {
                    if(checked){
                        signInToggle.checked = false
                        mode = "signUp"
                    }
                }
            }
            CheckButton{
                id: signInToggle
                label: "войти"
                height: parent.height
                width: parent.width / 2
                checkedColor: "#90A4AE"
                uncheckedColor: "#CFD8DC"
                uncheckWithTap: false
                onCheckedChanged: {
                    if(checked){
                        signUpToggle.checked = false
                        mode = "signIn"
                    }
                }
            }
        }
    }

    Rectangle{
        id: shadowPlot
        width: dataSheet.width * 2
        height: dataSheet.height
        anchors.centerIn: dataSheet
        visible: false
    }

    DropShadow{
        id: dataSheetShadow
        anchors.fill: shadowPlot
        horizontalOffset: 0
        verticalOffset: - Math.ceil(indicateZone.height / 10)
        radius: Math.abs(Math.ceil(verticalOffset / 2))
        samples: radius * 2 + 1
        color: "#000000"//"#80000000"
        source: shadowPlot
        cached: true
        z: dataSheet.z - 1
    }

}
