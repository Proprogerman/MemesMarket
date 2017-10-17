import QtQuick 2.0
import QtCharts 2.2

Item{
    property alias points: chartPoints

    Rectangle{
        id: graphItem
        width: parent.width
        height: parent.height * 3/8
        anchors.top: imageItem.bottom

        property variant chartPoints: { point1; point2; point3; point4; point5; point6; point7 }

        ChartView{
            //title: "Популярность мема:"
            anchors.fill: parent
            antialiasing: true

            LineSeries{
                XYPoint { id: point1; x: 0; y: 0 }
                XYPoint { id: point2; x: 1.1; y: 2.1 }
                XYPoint { id: point3; x: 1.9; y: 3.3 }
                XYPoint { id: point4; x: 2.1; y: 2.1 }
                XYPoint { id: point5; x: 2.9; y: 4.9 }
                XYPoint { id: point6; x: 3.4; y: 3.0 }
                XYPoint { id: point7; x: 4.1; y: 3.3 }
            }
        }
    }
}

