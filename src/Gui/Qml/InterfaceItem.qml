/***************************************************************************
 *   Copyright (c) 2014 StefanTroeger <stefantroeger@gmx.net>              *
 *                                                                         *
 *   This file is part of the FreeCAD CAx development system.              *
 *                                                                         *
 *   This library is free software; you can redistribute it and/or         *
 *   modify it under the terms of the GNU Library General Public           *
 *   License as published by the Free Software Foundation; either          *
 *   version 2 of the License, or (at your option) any later version.      *
 *                                                                         *
 *   This library  is distributed in the hope that it will be useful,      *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU Library General Public License for more details.                  *
 *                                                                         *
 *   You should have received a copy of the GNU Library General Public     *
 *   License along with this library; see the file COPYING.LIB. If not,    *
 *   write to the Free Software Foundation, Inc., 59 Temple Place,         *
 *   Suite 330, Boston, MA  02111-1307, USA                                *
 *                                                                         *
 ***************************************************************************/

import QtQuick 1.1
import FreeCADLib 1.0

import "InterfaceItemUtilities.js" as Util

Item {
      
    id: interfaceitem
    //all children are added to the childarea by default
    default property alias content: childarea.children
    property alias titleBar: titlebar
     
    property Item area: parent
    property Item resizeDragItem
    property Item resizeFixItem
    
    //margins for nice looks
    anchors.bottomMargin: 3
    anchors.leftMargin: 3
    anchors.rightMargin: 3
    
    //drag properties
    property alias fixedWidth:  resizer.fixedWidth
    property alias fixedHeight: resizer.fixedHeight
    property int dragframe: 5;    
    property int minWidth:  150;
    property int minHeight: 150;
    property int totalMinHeight: minHeight + titlebar.height + 3;
    
    height: 200;
    width:  200;
        
    property alias title: titleItem.text
       
    MouseCursor {
        id: cursorItem
    }
       
    Rectangle {
        id: titlebar
        height:20
        width: 150
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right

        radius:3
        color: "#999999"
        
        Text {
            id: titleItem
            width: parent.width - buttons.width
            height: parent.height
            anchors.leftMargin: 3
            anchors.left: parent.left
            elide: Text.ElideRight
        }          
        //This is our drag mouse area
        MouseArea {
            id: dragArea
            anchors.left: titleItem.left
            anchors.right: buttons.right
            height: titleItem.height
            drag.target: interfaceitem
            drag.minimumX: 0
            drag.maximumX: interfaceitem.parent.width - interfaceitem.width
            drag.minimumY: 0
            drag.maximumY: interfaceitem.parent.height - interfaceitem.height
            
            drag.onActiveChanged: cursorItem.cursor = (drag.active) ? Qt.SizeAllCursor : Qt.ArrowCursor;
            
            
            onPressed: Util.setupDrag(interfaceitem, mouse);
            onPositionChanged: Util.setAnchorsForPosition(mouse);            
        }
        Row {
            id:buttons
            anchors.top: titlebar.top;
            anchors.right: titlebar.right
            width: childrenRect.width
            height: titlebar.height
            TitleButton{
                width:  20
                height: 20
                id: shade
            }
            TitleButton{
                width:  20
                height: 20
                id: close
            }
        }
    }
        
    //this item is used as placeholder for the interface item
    Item {
        id: childarea
       
        anchors.topMargin: 3
        anchors.top:    titlebar.bottom
        anchors.bottom: parent.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
    }
    
    //add the resize areas
    InterfaceItemResizer {
        id: resizer
        interfaceitem: interfaceitem;
        anchors.fill: parent;   
    }    
    
    //we need to setup the anchor object arrays
    Component.onCompleted: {
        Util.anchors = new Object();
        Util.anchors.anchorXlist = new Array();
        Util.anchors.anchorYlist = new Array();
    }
    
    onAreaChanged: {
        area.setupInterfaceItem(interfaceitem);
    }
    
    anchors.onTopChanged: {
        if(!Util.anchors.controlledChange)
            console.debug("Top anchor removed")
    }
    anchors.onBottomChanged: {
        if(!Util.anchors.controlledChange)
            console.debug("Bottom anchor removed")
    }
    anchors.onVerticalCenterChanged: {
        if(!Util.anchors.controlledChange)
            console.debug("Vertical Center anchor removed")
    }
    
    function setPassiveAnchor(anchorObject) {
        
        if(anchorObject.isXtype)
            Util.anchors.anchorXlist[Util.anchors.anchorXlist.length] = anchorObject;
        else
            Util.anchors.anchorYlist[Util.anchors.anchorYlist.length] = anchorObject;
    }
    
    function removePassiveAnchor(anchorObject) {
     
        var list = anchorObject.isXtype ? Util.anchors.anchorXlist : Util.anchors.anchorYlist;
        var index = list.indexOf(anchorObject);
        list.splice(index, 1);
    }
    
    //if we set a anchor for this item we do not only need to set it but also to store the information
    //that we did. Furthermore this information needs to be stored in the passive element too.
    function setupAnchor(thisAnchor, item, itemAnchor) {
        
        //console.debug("setup anchor:")
        //console.debug("X anchor length: ", Util.anchors.anchorXlist.length);
        //console.debug("Y anchor length: ", Util.anchors.anchorYlist.length);
        
        Util.anchors.controlledChange = true;
        anchors[thisAnchor] = item[itemAnchor];
        Util.anchors.controlledChange = false;
        
        var anchorObject = {active: interfaceitem, passive: item, activeAnchor: thisAnchor, passiveAnchor: itemAnchor};        
        if(thisAnchor == 'top' || thisAnchor == 'bottom' || thisAnchor == 'verticalCenter') {
            anchorObject.isXtype = false;
            Util.anchors.anchorYlist[Util.anchors.anchorYlist.length] = anchorObject;
        }
        else {
            anchorObject.isXtype = false;
            Util.anchors.anchorXlist[Util.anchors.anchorXlist.length] = anchorObject;
        }
       
        if('setPassiveAnchor' in item)
            item.setPassiveAnchor(anchorObject);
        
        //console.debug("done X anchor length: ", Util.anchors.anchorXlist.length);
        //console.debug("done Y anchor length: ", Util.anchors.anchorYlist.length);
    }
    
    function removeAnchors(vertical) {
        
        //console.debug("remove anchors")
        
        var list = vertical ? Util.anchors.anchorYlist : Util.anchors.anchorXlist;
        
        for (var i=0; i < list.length; ++i) {
            //reset the anchor
            Util.anchors.controlledChange = true;
            list[i].active.anchors[list[i].activeAnchor] = undefined;
            Util.anchors.controlledChange = false;
        
            //inform the passive item that this anchor has gone
            if('removePassiveAnchor' in list[i].passive)
                list[i].passive.removePassiveAnchor(list[i]);
        }
        //clear the anchor list as all have been removed
        if(vertical) 
            Util.anchors.anchorYlist = new Array();
        else
            Util.anchors.anchorXlist = new Array();
    }
    
    //see if we can drag in the given anchor direction. 
    //if we are the active item in a anchor of the given direction the draging would override this 
    //anchor. this is not wanted. This function is used to check if we have an active anchor and 
    //deny the drag is fo
    function canDrag(dragAnchor) {
        
        var i = getActiveAnchorObjectFor(dragAnchor);        
        return (i==undefined) ? true : false;
    }
    
    function getActiveAnchorObjectFor(anchor)  {
        
        for (var i=0; i<Util.anchors.anchorXlist.length; ++i) {
            
            var item = Util.anchors.anchorXlist[i];
            if(item.active == interfaceitem && item.activeAnchor == anchor)
                return item;
        }
        for (var i=0; i<Util.anchors.anchorYlist.length; ++i) {
            
            var item = Util.anchors.anchorYlist[i];
            if(item.active == interfaceitem && item.activeAnchor == anchor)
                return item;
        }
        return undefined;
    }
    
    function setControlledChange(cc) {
        Util.anchors.controlledChange = cc;
    }
    
    function setupResize(xf, yf, fixedanchor, draganchor) {

        //the fix item mused be anchored to the item with the item as active one,
        //as the passive stays fixed and the active gets dragged. As this may override
        //possible existing anchors we need to store them and reenable them when finished
        Util.anchors.resizeAnchorCache = getActiveAnchorObjectFor(fixedanchor);        
        
        resizeFixItem.x = xf;
        resizeFixItem.y = yf;

        interfaceitem.setControlledChange(true)
        interfaceitem.anchors[fixedanchor] = resizeFixItem[fixedanchor];
        interfaceitem.anchors[draganchor]  = resizeDragItem[draganchor];
        interfaceitem.setControlledChange(false)
    }
    
    function clearResize(fixed, drag) {
        
        interfaceitem.setControlledChange(true)
        interfaceitem.anchors[drag] = undefined;
        interfaceitem.anchors[fixed] = undefined;
        
        if(Util.anchors.resizeAnchorCache != undefined) {
            var obj = Util.anchors.resizeAnchorCache;
            obj.active.anchors[obj.activeAnchor] = obj.passive[obj.passiveAnchor];
        }
            
        interfaceitem.setControlledChange(false)
    }
    
    function getPassiveYItemChain(list) {
        Util.getPassiveYItemChain(list);
    }
    
    function getPassiveXItemChain(list) {
        Util.getPassiveXItemChain(list);
    }
}