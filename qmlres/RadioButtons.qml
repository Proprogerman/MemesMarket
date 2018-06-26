import QtQuick 2.0

Item {
    id: control

    property int value: 0

    property color itemUncheckedColor
    property color itemCheckedColor
    property color backgroundColor
    property alias spacing: radioButtons.spacing
    property int activeButton: 0

    property alias button1Label: butt1.label
    property alias button2Label: butt2.label
    property alias button3Label: butt3.label
    property alias button4Label: butt4.label

    onActiveButtonChanged: {
        setButtonActive
    }

    function setButtonActive(button){
        if(button === 0){
            radioButtons.state = "unchecked"
        }
        else if(button === 1){
            radioButtons.state = radioButtons.state !== "butt1Checked" ? "butt1Checked" : "unchecked"
        }
        else if(button === 2){
            radioButtons.state = radioButtons.state !== "butt2Checked" ? "butt2Checked" : "unchecked"
        }
        else if(button === 3){
            radioButtons.state = radioButtons.state !== "butt3Checked" ? "butt3Checked" : "unchecked"
        }
        else if(button === 4){
            radioButtons.state = radioButtons.state !== "butt4Checked" ? "butt4Checked" : "unchecked"
        }
    }

    function setDefaultActiveButton(){
        if(activeButton == 0)
            return "unchecked"
        if(activeButton == 1)
            return "butt1Checked"
        if(activeButton == 2)
            return "butt2Checked"
        if(activeButton == 3)
            return "butt3Checked"
        if(activeButton == 4)
            return "butt4Checked"
    }

    Rectangle{
        id: background
        color: backgroundColor
        anchors.fill: parent
    }

    Row{
        id: radioButtons
        anchors.fill: parent
        property int rowWidth: parent.width - spacing * 3

        CheckButton{
            id: butt1;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: itemCheckedColor
            uncheckedColor: itemUncheckedColor

            Connections{
                target: butt1.buttArea
                onReleased:{
                    setButtonActive(1)
                }
            }
        }

        CheckButton{
            id: butt2;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: itemCheckedColor
            uncheckedColor: itemUncheckedColor

            Connections{
                target: butt2.buttArea
                onReleased:{
                    setButtonActive(2)
                }
            }
        }

        CheckButton{
            id: butt3;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: itemCheckedColor
            uncheckedColor: itemUncheckedColor

            Connections{
                target: butt3.buttArea
                onReleased:{
                    setButtonActive(3)
                }
            }
        }

        CheckButton{
            id: butt4;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: itemCheckedColor
            uncheckedColor: itemUncheckedColor

            Connections{
                target: butt4.buttArea
                onReleased:{
                    setButtonActive(4)
                }
            }
        }

        states:[
            State{
                name: "unchecked" 
                PropertyChanges{ target: control; activeButton: 0}
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt3; checked: false }
                PropertyChanges{ target: butt4; checked: false }
                PropertyChanges{ target: control; value: 0 }
            },
            State{
                name: "butt1Checked"
                PropertyChanges{ target: control; activeButton: 1 }
                PropertyChanges{ target: butt1; checked: true }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt3; checked: false }
                PropertyChanges{ target: butt4; checked: false }
                PropertyChanges{ target: control; value: Number(butt1.label) }
            },
            State{
                name: "butt2Checked"
                PropertyChanges{ target: control; activeButton: 2 }
                PropertyChanges{ target: butt2; checked: true }
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt3; checked: false }
                PropertyChanges{ target: butt4; checked: false }
                PropertyChanges{ target: control; value: Number(butt2.label) }
            },
            State{
                name: "butt3Checked"
                PropertyChanges{ target: control; activeButton: 3 }
                PropertyChanges{ target: butt3; checked: true }
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt4; checked: false }
                PropertyChanges{ target: control; value: Number(butt3.label) }
            },
            State{
                name: "butt4Checked"
                PropertyChanges{ target: control; activeButton: 4 }
                PropertyChanges{ target: butt4; checked: true }
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt3; checked: false }
                PropertyChanges{ target: control; value: Number(butt4.label) }
            }
        ]
        state: setDefaultActiveButton()
    }
}
