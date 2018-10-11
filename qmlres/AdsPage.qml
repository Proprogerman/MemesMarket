import QtQuick 2.11
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2

import "qrc:/qml/elements"

import KlimeSoft.SingletonUser 1.0

Page {
    id: adsPage
    objectName: "adsPage"

    property color itemColor: "white"
    property color backColor: "#edeef0"
    property color mainColor: "#507299"
    property color goldenColor: "#f9a602"

    property string normalRep: qsTr("нормальная") + translator.emptyString
    property string badRep: qsTr("плохая") + translator.emptyString
    property string awfulRep: qsTr("ужасная") + translator.emptyString
    property string goodRep: qsTr("хорошая") + translator.emptyString

    property string selectedAdName
    property int selectedAdIndex

    background: backgroundItem


    function setAd(adName, imageName, adProfit, adReputation, adDiscontented, secondsToReady){
        for(var i = 0; i < adListModel.count; i++){
            if(adListModel.get(i).adNameText === adName){
                adListModel.set(i, { "adNameText": adName, "image": "image://imgProv/ad_" + imageName, "adProfitText": adProfit,
                                     "adReputationText": qsTr(adReputation), "adDiscontented": adDiscontented, "buttonClickable": true,
                                     "secondsToReady": secondsToReady })
                if(secondsToReady || !adProfit)
                    adListModel.setProperty(i, "buttonClickable", false)
                return;
            }
        }
        adListModel.append({ "adNameText": adName, "image": "image://imgProv/ad_" + imageName, "adProfitText": adProfit,
                             "adReputationText": qsTr(adReputation), "adDiscontented": adDiscontented, "buttonClickable": true,
                             "secondsToReady": secondsToReady })
        if(secondsToReady || !adProfit)
            adListModel.setProperty(findAd(adName), "buttonClickable", false)
    }

    function removeAd(ad_name){
        for(var i = 0; i < adListModel.count; i++)
            if(adListModel.get(i).adNameText === ad_name){
                adListModel.remove(i)
            }
    }

    function updateAdImage(adName, imageName){
        for(var i = 0; i < adListModel.count; i++)
            if(adListModel.get(i).adNameText === adName){
                adListModel.setProperty(i, "image", " ")
                adListModel.setProperty(i, "image", "image://imgProv/ad_" + imageName)
            }
    }

    function findAd(adName){
        for(var i = 0; i < adListModel.count; i++){
            if(adListModel.get(i).adNameText === adName)
                return i;
        }
    }


    Component.onCompleted: {
        if(User.adsIsEmpty())
            User.getAdList()
        else
            User.setExistingAdList()
        getAdsTimer.start()
    }

    Connections{
        target: User
        onAdReceived: {
            setAd(adName, imageName, profit, reputation, discontented, secondsToReady)
        }
        onAdRemoved:{
            removeAd(adName)
        }
        onImageReceived: {
            if(type === "ad")
                updateAdImage(name, imageName)
        }
    }

    Timer{
        id: getAdsTimer
        triggeredOnStart: true
        interval: 10000
        repeat: true
        onTriggered: User.getAdList()
    }

    Rectangle{
        id: backgroundItem
        anchors.fill: parent
        z: -2
        color: backColor
    }

    Hamburger{
        id: hamburger
        height: pageHeader.height / 4
        width: height * 3 / 2
        y: pageHeader.y + Math.floor(pageHeader.height / 2) - height
        anchors{ left: pageHeader.left; leftMargin: width }
        z: pageHeader.z + 1
        dynamic: false
        onBackAction: {
            if(stackView.__currentItem.objectName === "adsPage")
                stackView.pop()
        }
    }

    PageHeader{
        id: pageHeader
        width: parent.width
        height: parent.height / 10
        headerText: qsTr("реклама") + translator.emptyString
        z: 7
    }

    ListView {
        id: appListView
        height: parent.height - pageHeader.height
        width: parent.width
        spacing: parent.height / 50
        z: background.z + 1
        anchors{
            top: pageHeader.bottom
            right: parent.right
            left: parent.left
            bottom: parent.bottom
        }

        model: adListModel

        delegate: Rectangle{
            width: pageHeader.width
            height: pageHeader.height * 4

            property int secondsInt: secondsToReady
            onSecondsIntChanged: {
                seconds.text = Math.floor(secondsInt / 60) + ":" + (secondsInt % 60 < 10 ? "0" : "") + secondsInt % 60
                secondsTimer.start()
            }

            color: itemColor
            Image{
                id: adImage
                height: parent.height * 2 / 3
                anchors{ top: parent.top; left: parent.left }
                width: height
                cache: false
                source: image
            }
            Text{
                id: adNameItem
                text: adNameText
                anchors{ left: adImage.right; top: parent.top }
                font.pixelSize: adImage.height / 8
                width: parent.width - adImage.width
                height: adImage.height
                wrapMode: Text.WordWrap
            }
            Text{
                id: profitItem
                text: qsTr("прибыль") + ": " + translator.emptyString
                anchors{ left: parent.left; top: adImage.bottom }
                font.pixelSize: adImage.height / 10
                y: adImage.y + adImage.height / 4 - font.pixelSize / 2
            }
            Text{
                text: adProfitText
                anchors{ left: profitItem.right; top: adImage.bottom }
                font.pixelSize: adImage.height / 10
                color: goldenColor
            }

            Text{
                id: reputationItem
                text: qsTr("репутация") + ": " + translator.emptyString
                anchors{ left: parent.left; top: profitItem.bottom }
                font.pixelSize: adImage.height / 10
                y: adImage.y + adImage.height / 2 - font.pixelSize / 2
            }
            Text{
                text: adReputationText
                anchors{ left: reputationItem.right; top: profitItem.bottom }
                font.pixelSize: adImage.height / 10
                y: adImage.y + adImage.height / 2 - font.pixelSize / 2
                onTextChanged: {
                    if(text === awfulRep || text === badRep)
                        color = "red"
                    else
                        color = "green"
                }
            }
            Text{
                text: qsTr("потеря аудитории") + ": " + adDiscontented + "%" + translator.emptyString
                anchors{ left: parent.left; top: reputationItem.bottom }
                font.pixelSize: adImage.height / 10
            }

            MaterialButton{
                id: adButton
                width: Math.ceil(adImage.width * 0.85)
                height: Math.ceil((parent.height - adImage.height) * 0.75)
                anchors{ right: parent.right; bottom: parent.bottom }
                clickable: buttonClickable
                clickableColor: mainColor
                unclickableColor: Qt.lighter(mainColor, 2)
                rippleColor: Qt.lighter(mainColor)
                label: qsTr("принять") + translator.emptyString
                labelSize: height / 3
                onClicked:{
                    selectedAdName = adNameItem.text
                    selectedAdIndex = index
                    adDialog.open()
                }
                onClickableChanged: {
                    seconds.visible = clickable ? false : true
                    labelVisible = clickable ? true : false
                }
            }
            Text{
                id: seconds
                text: parent.secondsInt
                anchors.centerIn: adButton
                height: adButton.height
                width: adButton.width
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: adButton.clickable ? false : true
                font.pixelSize: height / 4
            }

            Timer{
                id: secondsTimer
                interval: 1000
                repeat: true
                onTriggered: {
                    if(parent.secondsInt > 0){
                        --parent.secondsInt
                        adButton.clickable = false
                    }
                    else{
                        adButton.clickable = true
                        stop()
                        parent.secondsInt = 0
                    }
                }
            }
        }
    }
    ListModel{
        id: adListModel
    }

    Dialog {
        id: adDialog
        title: qsTr("Реклама") + translator.emptyString
        contentItem: Rectangle{
            width: adsPage.width * 5/6
            height: width / 3
            Column{
                anchors.fill: parent
                Text{
                    text: qsTr("Взять эту рекламу?") + translator.emptyString
                    height: parent.height / 2
                    width: parent.width
                }
                Row{
                    height: parent.height / 2
                    width: parent.width
                    MaterialButton{
                        label: qsTr("взять") + translator.emptyString
                        labelSize: height / 4
                        width: parent.width / 2
                        height: parent.height
                        clickableColor: Qt.lighter(mainColor, 1.5)
                        rippleColor: Qt.lighter(clickableColor)
                        z: cancelButton.z + 1
                        onClicked: {
                            adDialog.close()
                            adListModel.setProperty(selectedAdIndex, "buttonClickable", false)
                            adListModel.setProperty(selectedAdIndex, "secondsToReady", 1800)
                            User.acceptAd(selectedAdName)
                        }
                    }
                    MaterialButton{
                        id: cancelButton
                        label: qsTr("отмена") + translator.emptyString
                        labelSize: height / 4
                        width: parent.width / 2
                        height: parent.height
                        clickableColor: Qt.lighter(mainColor, 1.5)
                        rippleColor: Qt.lighter(clickableColor)
                        onClicked: {
                            adDialog.close()
                            selectedAdName = ""
                            selectedAdIndex = -1
                        }
                    }
                }
            }
        }
    }

}
