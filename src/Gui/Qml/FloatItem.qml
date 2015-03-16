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

import "FloatItemUtilities.js" as Util

Item {
      
    id: floatitem
    
    
    property alias titleBarHeight:      titlebar.height
    property alias title:               titleItem.text
    property alias ccontent:            childarea.children  
    
    property int   floatMode:           Util.FloatMode.Free
    property bool  hideTitlebar:        false
    property bool  overrideHideToolbar: false
    property bool  frame:               false
    
        
    height: 43
    //drag+resize properties
    property int  margin: 3;     
    property Item area: parent
    property Item resizeDragItem
    property Item resizeFixItem
    property Item tileIndicatorItem
    
    property alias fixedWidth:  resizer.fixedWidth
    property alias fixedHeight: resizer.fixedHeight
    property int dragframe: 5;    
    property int minWidth:  150;
    property int minHeight: 150;
    property int totalMinHeight: minHeight + titleBarHeight + 3;
    
    //controls 
    property Item controlsDelegate
    
    //signals emmited
    signal activated();
    
    width:  200;  
           
   //ensure we detect hoovers over the titlebar
    HoverItem {
        id: titlebar
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
            
        height: (!hideTitlebar || overrideHideToolbar) ? 23 : 0
        width:  150
        
        onEnter: {
            floatitem.onEnter();
        }
        onLeave: {
            floatitem.onLeave();
        }

        Rectangle {
            id: bar
            anchors.bottomMargin: 3
            anchors.fill: parent
            visible: !hideTitlebar || overrideHideToolbar

            onVisibleChanged: {
                if(visible) {
                    floatitem.height = childarea.height + 23
                    titlebar.height = 23        
                }
                else {
                    floatitem.height = floatitem.height - titlebar.height - childarea.anchors.topMargin;
                    titlebar.height = 0;                
                }
            }
            
            SystemPalette { 
                id: palette
            }
            
            radius:3
            color: palette.window
            
            Text {
                id: titleItem
                width: parent.width //- buttons.width
                height: parent.height
                anchors.leftMargin: 3
                anchors.left: parent.left
                elide: Text.ElideRight
            }          
            //This is our drag/menu/autoshade mouse area
            MouseArea {
                id: dragArea
                acceptedButtons: Qt.LeftButton | Qt.RightButton;
                anchors.left: titleItem.left
                anchors.right: titleItem.right
                height: titleItem.height
                drag.target: floatitem
                
                CursorArea {
                    anchors.fill: parent
                    cursor: dragArea.drag.active ? Qt.SizeAllCursor : Qt.ArrowCursor
                }
                
                drag.onActiveChanged: {
                    if(!drag.active) {
                        if(floatMode == Util.FloatMode.Anchor)
                            setAnchorIndicator(false)    
                            
                        if(floatMode == Util.FloatMode.Tile)
                                Util.finishTiling(floatitem)
                            
                        Util.dragMode = Util.DragMode.None;                    
                    }
                    else {
                        if(floatMode == Util.FloatMode.Anchor) {
                            setAnchorIndicator(true)
                            drag.maximumX = floatitem.parent.width - floatitem.width
                            drag.maximumY = floatitem.parent.height - floatitem.height
                            drag.minimumX = 0
                            drag.minimumY = 0
                        }  
                        else {
                            drag.maximumX = floatitem.parent.width - 50
                            drag.maximumY = floatitem.parent.height - 50
                            drag.minimumX = -(floatitem.width - 50)
                            drag.minimumY = -(floatitem.height - 50)
                            
                            if(floatMode == Util.FloatMode.Tile)
                                Util.setupTiling(area.width, area.height, tileIndicatorItem)
                        }
                    }
                }

                onPressed:  {
                    if(mouse.buttons == Qt.LeftButton)
                        Util.setupDrag(floatitem, mouse, Util.DragMode.DragXY)
                    else 
                        floatitem.contextMenu()
                        
                    activated()
                }
                onPositionChanged: {                    
                    if(floatMode == Util.FloatMode.Anchor)
                        Util.setAnchorsForPosition(mouse);  
                    else if(floatMode == Util.FloatMode.Tile) 
                        Util.setTileForPosition(mapToItem(area, mouse.x, mouse.y))
                }
                
            }
            Item {
                id:buttons
                anchors.top: bar.top;
                anchors.right: bar.right
                width: childrenRect.width
                height: bar.height
                children: controlsDelegate
            }
        }
    }
    
    //draw the frame rectangle below the childarea for the illusion of a frame
    Rectangle {
        visible: floatitem.frame
        radius:  2
        color:   palette.window
        
        anchors.top:    titlebar.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
        
        onVisibleChanged: {
        
            if(visible)
                childarea.anchors.margins = 2
            else
                childarea.anchors.margins = 0
        }
    }
    
    //this item is used as placeholder for the children
    Item {
        id: childarea       
        anchors.top:    titlebar.bottom
        anchors.left:   parent.left
        anchors.right:  parent.right
        anchors.bottom: parent.bottom
    }
       
    //add the resize areas
    InterfaceItemResizer {
        id: resizer
        interfaceitem: floatitem;
        anchors.fill: parent;   
    }  
    
    Settings {
        id: settings
        trackedObject: floatitem.objectName
    }
    
    
    onAreaChanged: {
        if(area["setupFloatItem"] != undefined)
            area.setupFloatItem(floatitem);
    }
    
    onFloatModeChanged: Util.loatMode = floatMode
    
    //we need to setup the anchor object arrays and load all settings
    Component.onCompleted: {
        Util.anchors = new Object();
        Util.anchors.anchorXlist = new Array();
        Util.anchors.anchorYlist = new Array();
        Util.anchors.resizeFixedAnchorCache = new Object;
        Util.anchors.resizeDragAnchorCache = new Object;
    }
    
    //let's save everything
    Component.onDestruction: {
        settings.setInt('x', floatitem.x)
        settings.setInt('y', floatitem.y)
        settings.setInt('width', floatitem.width)
        settings.setInt('height', floatitem.height)
        settings.setString('anchors', Util.setupAnchorString(floatitem));
        settings.setBool('hideTitlebar', floatitem.hideTitlebar)
    }
    
    //signals that we want the interfaceiten context menu
    signal contextMenu();
    
    function setupFloating() {
        floatitem.x = settings.getInt('x', 0);
        floatitem.y = settings.getInt('y', 0);
        floatitem.width = settings.getInt('width', floatitem.minWidth);
        floatitem.height = settings.getInt('height', floatitem.minHeight);
        floatitem.hideTitlebar = settings.getBool('hideTitlebar', false);
    }
    function setupAnchors() {
        Util.dragMode = Util.DragMode.None;
        Util.loadAnchorString(settings.getString('anchors', ''), floatitem, floatitem.area);
        setAnchorIndicator(false);
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
        
/*******************************************************************************************
*                                          Anchoring
* *****************************************************************************************/
    
    function setPassiveAnchor(anchorObject) {
        
        if(anchorObject.isXtype)
            Util.anchors.anchorXlist[Util.anchors.anchorXlist.length] = anchorObject;
        else
            Util.anchors.anchorYlist[Util.anchors.anchorYlist.length] = anchorObject;
    }
    
    function removePassiveAnchor(anchorObject) {
     
        if(anchorObject.passive != floatitem)
            return;
        
        var list = anchorObject.isXtype ? Util.anchors.anchorXlist : Util.anchors.anchorYlist;
        var index = list.indexOf(anchorObject);
        list.splice(index, 1);
    }
    
    function removeActiveAnchor(anchorObject) {
     
        if(anchorObject.active != floatitem)
            return;
        
        floatitem.setControlledChange(true) 
        floatitem.anchors[anchorObject.activeAnchor] = undefined;
        floatitem.setControlledChange(false) 
        
        var list = anchorObject.isXtype ? Util.anchors.anchorXlist : Util.anchors.anchorYlist;
        var index = list.indexOf(anchorObject);
        list.splice(index, 1);
    }
    
    //if we set a anchor for this item we do not only need to set it but also to store the information
    //that we did. Furthermore this information needs to be stored in the passive element too.
    function setupAnchor(thisAnchor, item, itemAnchor) {
                          
        Util.anchors.controlledChange = true;
        anchors[thisAnchor] = item[itemAnchor];
        if(thisAnchor != itemAnchor)
            anchors[thisAnchor+'Margin'] = floatitem.margin;
        else
            anchors[thisAnchor+'Margin'] = 0;
        
        Util.anchors.controlledChange = false;
        
        var anchorObject = {active: floatitem, passive: item, activeAnchor: thisAnchor, passiveAnchor: itemAnchor, passiveName: item.objectName};        
        if(thisAnchor == 'top' || thisAnchor == 'bottom' || thisAnchor == 'verticalCenter') {
            anchorObject.isXtype = false;
            Util.anchors.anchorYlist.push(anchorObject);
        }
        else {
            anchorObject.isXtype = true;
            Util.anchors.anchorXlist.push(anchorObject);
        }
       
        if('setPassiveAnchor' in item)
            item.setPassiveAnchor(anchorObject);
        
        if(Util.dragMode == Util.DragMode.SizeXY || Util.dragMode == Util.DragMode.SizeX
                    || Util.dragMode == Util.DragMode.SizeY) {
            Util.anchors.resizeDragAnchorCache[thisAnchor] = anchorObject;
        }
        setAnchorIndicator(true)
    }
    
    function removeActiveAnchors(vertical, resizeAnchor) {
        
        var list = vertical ? Util.anchors.anchorYlist : Util.anchors.anchorXlist;
        
        for (var i=list.length-1; i>=0; --i) {
            //reset the active anchors
            if(list[i].active == floatitem && 
                ( (Util.dragMode != Util.DragMode.SizeXY || Util.dragMode != Util.DragMode.SizeX 
                    || Util.dragMode != Util.DragMode.SizeY)
                    || list[i].activeAnchor==resizeAnchor)) {

                Util.anchors.controlledChange = true;
                list[i].active.anchors[list[i].activeAnchor] = undefined;
                Util.anchors.controlledChange = false;
        
                //inform the passive item that this anchor has gone
                if('removePassiveAnchor' in list[i].passive)
                    list[i].passive.removePassiveAnchor(list[i]);
                
                //remove the object from the list
                list.splice(i, 1);
                
                //if we are resizing we need to setup the drag anchor again
                if(Util.dragMode == Util.DragMode.SizeXY || Util.dragMode == Util.DragMode.SizeX
                    || Util.dragMode == Util.DragMode.SizeY) {
                    
                    floatitem.setControlledChange(true)           
                    floatitem.anchors[resizeAnchor]  = resizeDragItem[resizeAnchor];
                    Util.anchors.resizeDragAnchorCache[resizeAnchor] = undefined;
                    floatitem.setControlledChange(false)
                }
            }
        }
        
        setAnchorIndicator(true)
    }
    
    function removePassiveAnchors(vertical) {
        
        var list = vertical ? Util.anchors.anchorYlist : Util.anchors.anchorXlist;
        
        for (var i=list.length-1; i>=0; --i) {
            if(list[i].passive == floatitem) {

                list[i].active.removeActiveAnchor(list[i]);               
                list.splice(i, 1);
            }
        }
    }
    
    
    function getActiveAnchorObjectFor(anchor)  {
        
        for (var i=0; i<Util.anchors.anchorXlist.length; ++i) {
            
            var item = Util.anchors.anchorXlist[i];
            if(item.active == floatitem && item.activeAnchor == anchor)
                return item;
        }
        for (var i=0; i<Util.anchors.anchorYlist.length; ++i) {
            
            var item = Util.anchors.anchorYlist[i];
            if(item.active == floatitem && item.activeAnchor == anchor)
                return item;
        }
        return undefined;
    }
    
    function setControlledChange(cc) {
        Util.anchors.controlledChange = cc;
    }
    
    function setupResize(mouse, xf, yf, fixedanchor, draganchor, mode) {

        //the fix item mused be anchored to the item with the item as active one,
        //as the passive stays fixed and the active gets dragged. As this may override
        //possible existing anchors we need to store them and reenable them when finished
        Util.anchors.resizeFixedAnchorCache[fixedanchor] = getActiveAnchorObjectFor(fixedanchor);    
        Util.anchors.resizeDragAnchorCache[draganchor] = getActiveAnchorObjectFor(draganchor);   
        
        resizeFixItem.x = xf;
        resizeFixItem.y = yf;

        floatitem.setControlledChange(true)
        floatitem.anchors[fixedanchor] = resizeFixItem[fixedanchor];
        floatitem.anchors[fixedanchor+'Margin'] = 0;
        if(Util.anchors.resizeDragAnchorCache[draganchor] == undefined) {
            floatitem.anchors[draganchor] = resizeDragItem[draganchor];
            floatitem.anchors[draganchor+'Margin'] = 0
        }
        floatitem.setControlledChange(false)
        
        Util.setupDrag(floatitem, mouse, mode, draganchor);
    }
    
    function resizeMove(mouse) {
        Util.setAnchorsForPosition(mouse);     
    }
    
    function clearResize(fixed, drag) {
        
        floatitem.setControlledChange(true)
        floatitem.anchors[drag] = undefined;
        floatitem.anchors[fixed] = undefined;
        
        if(Util.anchors.resizeDragAnchorCache[drag] != undefined) {
            var obj = Util.anchors.resizeDragAnchorCache[drag];
            obj.active.anchors[obj.activeAnchor] = obj.passive[obj.passiveAnchor];
        }
        
        if(Util.anchors.resizeFixedAnchorCache[fixed] != undefined) {
            var obj = Util.anchors.resizeFixedAnchorCache[fixed];
            obj.active.anchors[obj.activeAnchor] = obj.passive[obj.passiveAnchor];
            
            if(obj.activeAnchor != obj.passiveAnchor)
                obj.active.anchors[obj.activeAnchor+'Margin'] = floatitem.margin;
            else
                obj.active.anchors[obj.activeAnchor+'Margin'] = 0;
        }
            
        Util.dragMode = Util.DragMode.None;
        floatitem.setControlledChange(false)
    }
    
    function getPassiveYItemChain(list) {
        Util.getPassiveYItemChain(list, floatitem);
    }
    
    function getPassiveXItemChain(list) {
        Util.getPassiveXItemChain(list, floatitem);
    }
    
    function setAnchorIndicator(draw) {
        if(floatMode == Util.FloatMode.Anchor) {
            var clist = area.children;
            for(var i=0; i<clist.length; ++i) {
                if('drawAnchorIndicator' in clist[i]) 
                    clist[i].drawAnchorIndicator(draw);
            }
        }
    }
    
    function drawAnchorIndicator(draw) {
        resizer.drawAnchorIndicator(draw);
    }
}