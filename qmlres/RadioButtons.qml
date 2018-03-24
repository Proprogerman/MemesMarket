import QtQuick 2.0

Item {
    id: control

    property var buttItems: { 'item1': 0, 'item2': 0, 'item3': 0, 'item4': 0 }
    property color uncheckedColor
    property color checkedColor
    property color backgroundColor
    property int checkedItem
    property alias spacing: radioButtons.spacing
    property int activeButton: 0

    function setButtonActive(button){
        if(button === butt1){
            if(radioButtons.state !== "butt1Checked"){
                radioButtons.state = "butt1Checked"
            }
            else
                radioButtons.state = "unchecked"
        }
        else if(button === butt2){
            if(radioButtons.state !== "butt2Checked")
                radioButtons.state = "butt2Checked"
            else
                radioButtons.state = "unchecked"
        }
        else if(button === butt3){
            if(radioButtons.state !== "butt3Checked")
                radioButtons.state = "butt3Checked"
            else
                radioButtons.state = "unchecked"
        }
        else if(button === butt4){
            if(radioButtons.state !== "butt4Checked")
                radioButtons.state = "butt4Checked"
            else
                radioButtons.state = "unchecked"
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
            checkedColor: "#90A4AE"
            uncheckedColor: "#CFD8DC"
            Component.onCompleted:{ label = buttItems.item1 }

            Connections{
                target: butt1.buttArea
                onReleased:{
                    setButtonActive(butt1)
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        CheckButton{
            id: butt2;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: "#90A4AE"
            uncheckedColor: "#CFD8DC"
            Component.onCompleted:{ label = buttItems.item2 }

            Connections{
                target: butt2.buttArea
                onReleased:{
//                    butt2.checked = butt2.checked ? false : true
                    setButtonActive(butt2)
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        CheckButton{
            id: butt3;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: "#90A4AE"
            uncheckedColor: "#CFD8DC"
            Component.onCompleted:{ label = buttItems.item3 }

            Connections{
                target: butt3.buttArea
                onReleased:{
//                    butt3.checked = butt3.checked ? false : true
                    setButtonActive(butt3)
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        CheckButton{
            id: butt4;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: "#90A4AE"
            uncheckedColor: "#CFD8DC"
            Component.onCompleted:{ label = buttItems.item4 }

            Connections{
                target: butt4.buttArea
                onReleased:{
//                    butt4.checked = butt4.checked ? false : true
                    setButtonActive(butt4)
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        states:[
            State{
                name: "unchecked" 
                PropertyChanges{ target: control; checkedItem: 0}
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt3; checked: false }
                PropertyChanges{ target: butt4; checked: false }
            },
            State{
                name: "butt1Checked"
                PropertyChanges{ target: control; checkedItem: 1 }
                PropertyChanges{ target: butt1; checked: true }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt3; checked: false }
                PropertyChanges{ target: butt4; checked: false }
            },
            State{
                name: "butt2Checked"
                PropertyChanges{ target: control; checkedItem: 2 }
                PropertyChanges{ target: butt2; checked: true }
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt3; checked: false }
                PropertyChanges{ target: butt4; checked: false }
            },
            State{
                name: "butt3Checked"
                PropertyChanges{ target: control; checkedItem: 3 }
                PropertyChanges{ target: butt3; checked: true }
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt4; checked: false }
            },
            State{
                name: "butt4Checked"
                PropertyChanges{ target: control; checkedItem: 4 }
                PropertyChanges{ target: butt4; checked: true }
                PropertyChanges{ target: butt1; checked: false }
                PropertyChanges{ target: butt2; checked: false }
                PropertyChanges{ target: butt3; checked: false }
            }
        ]
        state: setDefaultActiveButton()
    }
}
