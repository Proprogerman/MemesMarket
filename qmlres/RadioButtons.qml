import QtQuick 2.0

Item {
    id: control

    property color uncheckedColor
    property color checkedColor
    property color backgroundColor
    property int checkedItem
    property alias spacing: radioButtons.spacing

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

            Connections{
                target: butt1.buttArea
                onClicked:{
                    if(butt1.checked){
                        radioButtons.state = "butt1Checked"
                        butt2.checked = false
                        butt3.checked = false
                        butt4.checked = false
                    }
                    else
                        radioButtons.state = "unchecked"
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        CheckButton{
            id: butt2;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: "#90A4AE"
            uncheckedColor: "#CFD8DC"

            Connections{
                target: butt2.buttArea
                onClicked:{
                    if(butt2.checked){
                        radioButtons.state = "butt2Checked"
                        butt1.checked = false
                        butt3.checked = false
                        butt4.checked = false
                    }
                    else
                        radioButtons.state = "unchecked"
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        CheckButton{
            id: butt3;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: "#90A4AE"
            uncheckedColor: "#CFD8DC"

            Connections{
                target: butt3.buttArea
                onClicked:{
                    if(butt3.checked){
                        radioButtons.state = "butt3Checked"
                        butt1.checked = false
                        butt2.checked = false
                        butt4.checked = false
                    }
                    else
                        radioButtons.state = "unchecked"
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        CheckButton{
            id: butt4;
            width: parent.rowWidth/4; height: parent.height
            checkedColor: "#90A4AE"
            uncheckedColor: "#CFD8DC"

            Connections{
                target: butt4.buttArea
                onClicked:{
                    if(butt4.checked){
                        radioButtons.state = "butt4Checked"
                        butt1.checked = false
                        butt2.checked = false
                        butt3.checked = false
                    }
                    else
                        radioButtons.state = "unchecked"
                    console.log("checkedItem: ", checkedItem)
                }
            }
        }

        states:[
            State{
                name: "unchecked"
                PropertyChanges{ target: control; checkedItem: 0}
            },
            State{
                name: "butt1Checked"
                PropertyChanges{ target: control; checkedItem: 1}
            },
            State{
                name: "butt2Checked"
                PropertyChanges{ target: control; checkedItem: 2}
            },
            State{
                name: "butt3Checked"
                PropertyChanges{ target: control; checkedItem: 3}
            },
            State{
                name: "butt4Checked"
                PropertyChanges{ target: control; checkedItem: 4}
            }
        ]

        state: "unchecked"
    }
}
