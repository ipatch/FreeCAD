import QtQuick 1.1
import QuarterLib 1.0

Rectangle {
    id: coin
    objectName: "coin3D"
    anchors.fill: parent 
    Scene3D {
        id: scene3d
        objectName: "scene3d"
        anchors.fill: parent
    }
    Interaction3D {
        id: interaction3d
        objectName: "interaction3d"
        anchors.fill: parent
    }
}

