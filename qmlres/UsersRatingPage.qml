import QtQuick 2.11
import QtQuick.Controls 2.2
import QtGraphicalEffects 1.0

import KlimeSoft.SingletonUser 1.0

import "qrc:/qml/elements"

Page {
    id: usersRatingPage
    objectName: "usersRatingPage"

    property color itemColor: "white"
    property color mainColor: "#7fa0ca"
    property color backColor: "#edeef0"

    property int thisRating: -1
    property bool centered: false


    function updateRatingList(rating, userName, popValue){
        usersListModel.set(rating - 1, {"ratingText": rating, "userNameText": userName,
                                        "userPopValueText": popValue })
        if((thisRating != -1) && thisRating === rating && !centered){
            goToIndex(rating - 1)
            centered = true
        }
    }

    function goToIndex(index){
        listViewAnim.running = false
        var pos = ratingListView.contentY
        var destPos
        ratingListView.positionViewAtIndex(index, ListView.Center)
        destPos = ratingListView.contentY
        listViewAnim.from = pos
        listViewAnim.to = destPos
        listViewAnim.running = true
    }

    Component.onCompleted: {
        User.getUsersRating()
        updateTimer.start()
    }

    Connections{
        target: User
        onUsersRatingReceived: {
            for(var i = 0; i < usersList.length; i++){
                thisRating = userRating
                var userObj = usersList[i]
                updateRatingList(i + 1, userObj["user_name"], userObj["pop_value"])
            }
        }
    }

    Timer{
        id: updateTimer
        interval: 3000
        repeat: true
        onTriggered: {
            User.getUsersRating()
        }
    }

    Rectangle{
        id: background
        anchors.fill: parent
        z: -2
        color: backColor
    }

    Hamburger{
        id: hamburger
        height: pageHeader.height / 4
        width: height * 3 / 2
        y: pageHeader.y + Math.floor(pageHeader.height / 2) - height
        anchors{ left: pageHeader.left; leftMargin: width; /*verticalCenter: pageHeader.verticalCenter*/ }
        z: pageHeader.z + 1
        dynamic: false
        onBackAction: {
            if(stackView.__currentItem.objectName === "usersRatingPage")
                stackView.pop()
        }
    }

    PageHeader{
        id: pageHeader
        width: parent.width
        height: parent.height / 10
        headerText: qsTr("Рейтинг") + translator.emptyString
        z: 7
        MouseArea{
            anchors.fill: parent
            onClicked: {
                goToIndex(0)
            }
        }
    }

    DropShadow{
        anchors.fill: pageHeader
        source: pageHeader
        radius: Math.floor(pageHeader.height / 10)
        samples: radius * 2 + 1
        color:"#000000"
        opacity: 0.5
        z: pageHeader.z - 1
    }

    ListView {
        id: ratingListView
        height: parent.height - pageHeader.height
        width: parent.width
        spacing: Math.ceil(pageHeader.height / 15)
        anchors{
            top: pageHeader.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }

        model: usersListModel

        delegate: Rectangle{
            width: pageHeader.width
            height: pageHeader.height / 2
            color: Number(rating.text) === thisRating ? mainColor : itemColor

            Text{
                id: rating
                text: ratingText
                anchors{ left: parent.left; verticalCenter: parent.verticalCenter }
            }

            Text{
                text: userNameText
                anchors{ left: rating.right; leftMargin: parent.height / 2; verticalCenter: parent.verticalCenter }
            }

            Text{
                text: userPopValueText
                anchors{ right: parent.right; rightMargin: height; verticalCenter: parent.verticalCenter }
            }
        }
        NumberAnimation{ id: listViewAnim; target: ratingListView; property: "contentY"; duration: 400;
            easing.type: Easing.InOutQuad }
    }

    ListModel{
        id: usersListModel
    }
}
