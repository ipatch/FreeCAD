import QtQuick 1.1
import FreeCADLib 1.0

MDIView {
    id: mdiview

    property alias proxy: proxyitem.proxy
    property alias mimicCursor: proxyitem.mimicCursor
    anchors.fill: parent   
    
    Proxy {
        id: proxyitem
        objectName: "proxy"
        anchors.fill: parent
        
        onEnter: mdiview.onEnter();
        onLeave: mdiview.onLeave();    
    }
}

