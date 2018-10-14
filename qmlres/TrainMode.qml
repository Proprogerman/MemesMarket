import QtQuick 2.11
import QtGraphicalEffects 1.0

import CustomMouseArea 1.0

Item {
    id: root

    property bool active: false
    property var items: []
    property int currentItemIndex: 0

    property int finishIndex: 0

    property var currentItem: typeof(items) !== 'undefined' ? items[currentItemIndex] : 0

    property color backColor: "#000000"
    property color descColor: "#b0d1fd"
    property real maxOpacity: 0.7

    property real trainOpacity: active ? maxOpacity : 0
    property real descOpacity: active ? 1 : 0


    property int originalAreaWidth: typeof(currentItem) !== 'undefined' ? currentItem.item.width : 0
    property int originalAreaHeight: typeof(currentItem) !== 'undefined' ? currentItem.item.height : 0
    property int sizeCoeff: typeof(currentItem) !== 'undefined' ? currentItem.coeff : 0


    property int areaPosX: typeof(currentItem) !== 'undefined' ?
                               (-currentItem.item.x + originalAreaWidth * (sizeCoeff - 1) / 2) : 0
    property int areaPosY: typeof(currentItem) !== 'undefined' ?
                               (-currentItem.item.y + originalAreaHeight * (sizeCoeff - 1) / 2) : 0
    property int areaWidth: typeof(currentItem) !== 'undefined' ?
                                (originalAreaWidth * sizeCoeff) : 0
    property int areaHeight: typeof(currentItem) !== 'undefined' ?
                                 (originalAreaHeight * sizeCoeff) : 0
    property real areaRadius: typeof(currentItem) !== 'undefined' ?
                                  (currentItem.isCircle ? Math.max(areaWidth, areaHeight) / 2 : 0) : 0


    property string currentName: typeof(currentItem) !== 'undefined' ? currentItem.name : ""
    property string currentDescription: typeof(currentItem) !== 'undefined' ? currentItem.description : ""
    property string descriptionPosition: typeof(currentItem) !== 'undefined' ? currentItem.descriptionPosition : ""
    property string itemClickable: typeof(currentItem) !== 'undefined' ? currentItem.clickable : ""
    property string page: typeof(currentItem) !== 'undefined' ? currentItem.page : ""


    Behavior on areaPosX { enabled: active; NumberAnimation{ id: xAnim; duration: 150;
            onRunningChanged: if(!running) root.isFixated() } }
    Behavior on areaPosY { enabled: active; NumberAnimation{ id: yAnim; duration: 150;
            onRunningChanged: if(!running) root.isFixated() } }
    Behavior on areaWidth { enabled: active; NumberAnimation{ id: wAnim; duration: 150;
            onRunningChanged: if(!running) root.isFixated() } }
    Behavior on areaHeight { enabled: active; NumberAnimation{ id: hAnim; duration: 150;
            onRunningChanged: if(!running) root.isFixated() } }
    Behavior on areaRadius { enabled: active; NumberAnimation{ id: rAnim; duration: 150;
            onRunningChanged: if(!running) root.isFixated() } }

    onActiveChanged: {
        if(active)
            isFixated()
        checkProcess()
    }

    onItemsChanged: {
        finishIndex = 0
        currentItemIndex = 0
        checkProcess()
        checkFinished()
    }

    onCurrentItemIndexChanged: {
        checkFinished()
    }

    function isFixated(){
        if(!(xAnim.running && yAnim.running && wAnim.running && hAnim.running && rAnim.running)){
            if(itemClickable === "onlyItem" || itemClickable === "both")
                showZone.grabToImage(function(result){
                    mouse.maskSource = result
                })
            else
                mouse.resetMaskSource()

        }
    }

    function checkFinished(){
        if(currentItemIndex >= finishIndex){
            switch(page){
                case 'mainUserPage':
                    userSettings.mainUserPageTrain = false
                    break;
                case 'memePageMine':
                    userSettings.memePageTrain = false
                    break;
                case 'adsPage':
                    userSettings.adsPageTrain = false
                    break;
            }
        }
    }

    function checkProcess(){
        if(root.active){
            if(page === "mainUserPage" || page === "memePageMine" || page === "adsPage"){
                while(items[finishIndex].page !== "transfer" && finishIndex < items.length - 1)
                    finishIndex++
            }
        }
    }

    function trainClick(){
        if(itemClickable === "onlyZone" || itemClickable === "both"){
            if(currentItemIndex >= (items.length - 1)){
                root.active = false
                return
            }
            currentItemIndex++
        }
    }

    ShaderEffect {
        id: showZone
        anchors.fill: parent
        opacity: trainOpacity

        property color color: backColor
        property var source : ShaderEffectSource {
            id: se
            sourceRect: Qt.rect(areaPosX, areaPosY, root.width, root.height)
            sourceItem: Item {
                id: area
                height: areaHeight
                width: areaWidth

                Rectangle{
                    anchors.fill: parent
                    radius: areaRadius
                }
            }
        }
        fragmentShader:
            "varying highp vec2 qt_TexCoord0;
            uniform highp vec4 color;
            uniform sampler2D source;
            uniform lowp float qt_Opacity;
            void main() {
                gl_FragColor = color * (qt_Opacity - texture2D(source, qt_TexCoord0).w);
            }"
      }

    Behavior on trainOpacity{ NumberAnimation{ duration: 250 } }
    Behavior on descOpacity{ NumberAnimation{ duration: 250 } }

    MaskedMouseArea{
        id: mouse
        anchors.fill: parent
        enabled: root.active
        alphaThreshold: maxOpacity
        onClicked: {
            trainClick()
        }
    }

    Item{
        id: tapToContinue
        width: parent.width
        height: description.height / (currentDescription !== "" ? 10 : 5)
        visible: itemClickable === "onlyZone" || itemClickable === "both" ? 1 : 0
        opacity: descOpacity
        Text{
            anchors.fill: parent
            text: qsTr("Нажмите на экран, чтобы продолжить") + translator.emptyString
            font.family: "Roboto"
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: parent.height / 2
            color: "#ffffff"
        }
    }

    states:[
        State{
            name: "top"
            when: descriptionPosition === "top"
            AnchorChanges{ target: description; anchors.top: root.top; anchors.bottom: undefined }
            AnchorChanges{ target: tapToContinue; anchors.top: description.bottom; anchors.bottom: undefined }
        },
        State{
            name: "bottom"
            when: descriptionPosition === "bottom"
            AnchorChanges{ target: description; anchors.bottom: root.bottom; anchors.top: undefined }
            AnchorChanges{ target: tapToContinue; anchors.bottom: description.top; anchors.top: undefined }
        }
    ]

    Rectangle{
        id: description
        color: descColor
        opacity: descOpacity
        width: root.width
        height: width * (currentDescription === "" ?  1 / 3 : 2 / 3 )
        Item{
            anchors{
                top: parent.top;
                bottom: fullDescription.top
            }
            width: parent.width
            Text{
                anchors.fill: parent
                text: currentName
                font.pixelSize: height
                font.family: "Roboto"
                font.bold: true
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignVCenter
                color: Qt.darker(mainColor, 1.2)
            }
        }
        Item{
            id: fullDescription
            height: currentDescription !== "" ? parent.height / 2 : 0
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            visible: currentDescription !== "" ? 1 : 0
            Text{
                anchors.fill: parent
                text: currentDescription
                font.pixelSize: height / 5
                font.family: "Roboto"
                fontSizeMode: Text.Fit
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
                color: Qt.darker(mainColor, 1.2)
            }
        }
        Item{
            id: skipButton
            width: parent.width
            anchors{
                bottom: parent.bottom;
                top: fullDescription.bottom
            }

            MaterialButton{
                anchors.fill: parent
                clickableColor: "#507299"
                label: qsTr("пропустить обучение") + translator.emptyString
                labelSize: height / 4
                onClicked:{
                    userSettings.mainUserPageTrain = false
                    userSettings.memePageTrain = false
                    userSettings.adsPageTrain = false
                    root.active = false
                }
            }
        }
    }
}
