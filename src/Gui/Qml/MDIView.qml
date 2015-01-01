import QtQuick 1.1
import FreeCADLib 1.0

Item {
    property alias proxy: proxyitem.proxy
    anchors.fill: parent   
    Proxy {
      id: proxyitem
      objectName: "proxy"
      anchors.fill: parent
    }
}

