import QtQuick 1.1
import FreeCADLib 1.0

FloatItem {
    id: mdiview
    
    //item properties
    property bool    floating: false
    property int     viewID: 999
    property variant icon
    
    floatMode: 2
    hideTitlebar: !floating
    frame: floating
    default property alias content: mdiview.ccontent //all children are added to the childarea by default
    signal requestDestroy(variant item)
    
    //needs to be implemented
    function onEnter() {}
    function onLeave() {}
    
        
    onActivated: area.activateView(viewID)
    
    onAreaChanged:  {
        if(area["setupFloatItem"] != undefined)
            viewID = ++mdiview.area.uniqueID
    }
}

