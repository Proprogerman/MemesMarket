import QtQuick 2.9


Item{
    id: root

    property bool dynamic: true
    property color itemColor: "white"

    signal openAction()
    signal backAction()

    property int smallBarLength: width / 1.5
    property int xOffsetBackBars: width / 2
    property int startBar2Yposition: bar2.y

    Rectangle{
        id: bar1
        color: itemColor
        width: parent.width
        height: parent.height * 1/5
        anchors.top: parent.top
        antialiasing: true
    }
    Rectangle{
        id: bar2
        color: itemColor
        width: parent.width
        height: parent.height * 1/5
        anchors.top: bar1.bottom
        anchors.topMargin: parent.height * 1/5
        antialiasing: true
    }
    Rectangle{
        id: bar3
        color: itemColor
        width: parent.width
        height: parent.height * 1/5
        anchors.top: bar2.bottom
        anchors.topMargin: parent.height * 1/5
        antialiasing: true
    }

    state: dynamic ? "menu" : "back"

    states:[
        State{
            name: "menu"
        },
        State{
            name: "back"
            PropertyChanges{ target: root; rotation: 180;}
            PropertyChanges{ target: bar1; rotation: 45; width: smallBarLength;
                x: xOffsetBackBars; y: startBar2Yposition - Math.floor(bar2.height * 1.5)/*- 5*/}
            PropertyChanges{ target: bar2}
            PropertyChanges{ target: bar3; rotation: -45; width: parent.smallBarLength;
                x: xOffsetBackBars; y: startBar2Yposition + Math.floor(bar2.height * 1.5)/*+ 5*/}
            AnchorChanges{ target: bar1; anchors.top: undefined}
            AnchorChanges{ target: bar2; anchors.top: undefined}
            AnchorChanges{ target: bar3; anchors.top: undefined}
        }
    ]

    transitions:[
        Transition{
            PropertyAnimation{target: hamburger; property:"rotation"; duration: 260; easing.type: Easing.InOutQuad}
            PropertyAnimation{target: bar1; properties:"rotation, width, x, y"; duration: 260; easing.type:Easing.InOutQuad}
            PropertyAnimation{target: bar2; properties:"rotation"; duration: 260; easing.type:Easing.InOutQuad}
            PropertyAnimation{target: bar3; properties:"rotation, width, x, y"; duration: 260; easing.type:Easing.InOutQuad}
        }
    ]

    MouseArea{
        anchors.centerIn: parent
        height: parent.height * 3
        width: parent.width * 3
        onClicked:{
            if(parent.state == "menu"){
                parent.state = "back"
                openAction()
            }
            else if(parent.state == "back"){
                if(dynamic)
                    parent.state = "menu"
                backAction()
            }
        }
    }

}
