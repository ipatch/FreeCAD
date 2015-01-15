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
    property Item area: parent
        
    property alias title: titleItem.text

    width:  childrenRect.width
    height: childrenRect.height
       
    Rectangle {
        id: titlebar
        height:20
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        radius:3
        color: "#999999"
        
        Text {
            id: titleItem
            width: 150
            height: parent.height
            anchors.leftMargin: 3
            anchors.left: parent.left
            elide: Text.ElideRight
        }
        MouseArea {
            anchors.left: titleItem.left
            anchors.right: buttons.left
            height: titleItem.height
            drag.target: interfaceitem
            drag.minimumX: 0
            drag.maximumX: interfaceitem.parent.width - interfaceitem.width
            drag.minimumY: 0
            drag.maximumY: interfaceitem.parent.height - interfaceitem.height
            
            onPressed: Util.setupHitPositions(interfaceitem, mouse);
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
    Rectangle {
        id: childarea
       
        anchors.topMargin: 3
        anchors.top:    titlebar.bottom
        
        width:  childrenRect.width
        height: childrenRect.height
    }
    
    //we need to setup the anchor object arrays
    Component.onCompleted: {
        Util.anchors = new Object();
        Util.anchors.anchorXlist = new Array();
        Util.anchors.anchorYlist = new Array();
    }
    
    anchors.onTopChanged: {
        if(!Util.anchors.controlledChange)
            console.warning("Top anchor removed")
    }
    anchors.onBottomChanged: {
        if(!Util.anchors.controlledChange)
            console.warning("Bottom anchor removed")
    }
    anchors.onVerticalCenterChanged: {
        if(!Util.anchors.controlledChange)
            console.warning("Vertical Center anchor removed")
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
}