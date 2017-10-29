import QtQuick 2.0

Rectangle{
    width: parent.width
    height: parent.height * 1/4

    color:"white"
    Image{
        id: memeImage
        height: parent.height
        width: height
        source: memeImageSource
    }
    Text{
        text: memeName
        anchors{ left: memeImage.right; top: parent.top }
    }
}
