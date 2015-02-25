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
    
    property bool hideTitlebar: false
    property bool overrideHideToolbar: false
    
    //shade stuff
    property bool shade: false
    property int  hShadeSize:0
    property int  wShadeSize: 0
    property bool autoShade: false
    property int  shadeDelay: 0
    property int  unshadeDelay: 0
    property bool shadeHor: false
    property int  shadeWidth: 0
    property bool shadeVer: true
    property int  shadeHeight: 0
    
    property int margin: 3;
     
    property Item area: parent
    property Item resizeDragItem
    property Item resizeFixItem
        
    //drag properties
    property alias fixedWidth:  resizer.fixedWidth
    property alias fixedHeight: resizer.fixedHeight
    property int dragframe: 5;    
    property int minWidth:  150;
    property int minHeight: 150;
    property int totalMinHeight: minHeight + titlebar.height + 3;
    
    //height: 200;
    width:  200;
        
    property alias title: titleItem.text
        
    //ensure we detect hoovers over the titlebar
    HoverItem {
        id: titlebar
        anchors.top:   parent.top
        anchors.left:  parent.left
        anchors.right: parent.right
            
        height: 23
        width:  150
        
        onEnter: {
            interfaceitem.onEnter();
        }
        onLeave: {
            interfaceitem.onLeave();
        }

        Rectangle {
            id: bar
            anchors.bottomMargin: 3
            anchors.fill: parent
            visible: !hideTitlebar || overrideHideToolbar

            onVisibleChanged: {
                if(visible) {
                    interfaceitem.height = childarea.height + 23
                    titlebar.height = 23        
                }
                else {
                    interfaceitem.height = interfaceitem.height - titlebar.height - childarea.anchors.topMargin;
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
                width: parent.width - buttons.width
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
                anchors.right: buttons.right
                height: titleItem.height
                drag.target: interfaceitem
                drag.minimumX: 0
                drag.maximumX: interfaceitem.parent.width - interfaceitem.width
                drag.minimumY: 0
                drag.maximumY: interfaceitem.parent.height - interfaceitem.height
                
                CursorArea {
                    anchors.fill: parent
                    cursor: dragArea.drag.active ? Qt.SizeAllCursor : Qt.ArrowCursor
                }
                
                drag.onActiveChanged: {
                    if(!drag.active) {
                        setAnchorIndicator(false)
                        Util.dragMode = Util.DragMode.None;                    
                    }
                    else {
                        setAnchorIndicator(true)
                    }
                }

                onPressed:  {
                    if(mouse.buttons == Qt.LeftButton)
                        Util.setupDrag(interfaceitem, mouse, Util.DragMode.DragXY)
                    else 
                        interfaceitem.contextMenu()
                }
                onPositionChanged: Util.setAnchorsForPosition(mouse);            
            }
            Row {
                id:buttons
                anchors.top: bar.top;
                anchors.right: bar.right
                width: childrenRect.width
                height: bar.height
                Button {
                    width:  20
                    height: 20
                    id: menuButton
                    icon: ":/icons/preferences-system.svg"
                    
                    onActivated: area.setSettingsMode(interfaceitem);
                }
                TitleButton{
                    width:  20
                    height: 20
                    id: shadeButton
                    styleIcon: shade ? TitleButton.Unshade : TitleButton.Shade
                    
                    onActivated: toggleShade();
                }
                TitleButton{
                    width:  20
                    height: 20
                    id: closeButton
                    styleIcon: TitleButton.Close
                    
                    onActivated: {
                        if(interfaceitem.visible)
                            interfaceitem.show(false)
                    }
                }
            }
        }
    }
        
    //this item is used as placeholder for the interface item
    Item {
        id: childarea
       
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
    
    Settings {
        id: settings
        tracked: interfaceitem.title
    }
    
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
        settings.setBool('visible', interfaceitem.visible)        
        settings.setBool('shade', interfaceitem.shade)
        settings.setInt('hShadeSize', interfaceitem.hShadeSize)
        settings.setInt('wShadeSize', interfaceitem.wShadeSize)
        settings.setBool('shadeHor', interfaceitem.shadeHor)
        settings.setBool('shadeVer', interfaceitem.shadeVer)
        settings.setInt('shadeHeight', interfaceitem.shadeHeight)
        settings.setInt('shadeWidth', interfaceitem.shadeWidth)
        settings.setBool('autoShade', interfaceitem.autoShade)
        settings.setInt('shadeDelay', interfaceitem.shadeDelay)
        settings.setInt('unshadeDelay', interfaceitem.unshadeDelay)
        settings.setBool('hideTitlebar', interfaceitem.hideTitlebar)
        settings.setInt('x', interfaceitem.x)
        settings.setInt('y', interfaceitem.y)
        settings.setInt('width', interfaceitem.width)
        settings.setInt('height', interfaceitem.height)
        settings.setString('anchors', Util.setupAnchorString(interfaceitem));
    }
    
    //signals that we want the interfaceiten context menu
    signal contextMenu();
    
    function setup() {
        interfaceitem.visible = settings.getBool('visible', false);
        interfaceitem.shade = settings.getBool('shade', false);
        interfaceitem.hShadeSize = settings.getInt('hShadeSize', 0);
        interfaceitem.wShadeSize = settings.getInt('wShadeSize', 0);
        interfaceitem.shadeHor = settings.getBool('shadeHor', false)
        interfaceitem.shadeVer = settings.getBool('shadeVer', true)
        interfaceitem.shadeHeight = settings.getInt('shadeHeight', 0)
        interfaceitem.shadeWidth= settings.getInt('shadeWidth', 0)        
        interfaceitem.autoShade = settings.getBool('autoShade', false)
        interfaceitem.shadeDelay = settings.getInt('shadeDelay', 0)
        interfaceitem.unshadeDelay = settings.getInt('unshadeDelay', 0)
        interfaceitem.hideTitlebar = settings.getBool('hideTitlebar',false)
        interfaceitem.x = settings.getInt('x', 0);
        interfaceitem.y = settings.getInt('y', 0);
        interfaceitem.width = settings.getInt('width', interfaceitem.minWidth);
        interfaceitem.height = settings.getInt('height', interfaceitem.minHeight);
    }
    function setupAnchors() {
        Util.dragMode = Util.DragMode.None;
        Util.loadAnchorString(settings.getString('anchors', ''), interfaceitem, interfaceitem.area);
        setAnchorIndicator(false);
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
    
    /*******************************************************************************************
     *                                          Shading
     * *****************************************************************************************/
    SequentialAnimation {
        id: shadeAnimation
        property alias toHeight: hanim.to
        property alias toWidth: wanim.to
        property alias delay: pause.duration;
        
        PauseAnimation { 
            id: pause
            duration: 0
        }
        ParallelAnimation {
            PropertyAnimation { 
                id:hanim            
                target: interfaceitem
                properties: 'height'
                to: 0
                duration: 200
                easing.type: Easing.InOutCubic
            }
            PropertyAnimation { 
                id:wanim            
                target: interfaceitem
                properties: 'width'
                to: 0
                duration: 200
                easing.type: Easing.InOutCubic
            }
        }
    }
    
    function setShade(sh) {
        if(shade != sh) {
            var running = shadeAnimation.running;
            shadeAnimation.stop()
            if(!shade) {
                if(!running || hShadeSize==0)
                    hShadeSize = interfaceitem.height;
                
                if(!running || wShadeSize==0)
                    wShadeSize = interfaceitem.width;
                
                if(shadeVer)
                    shadeAnimation.toHeight = titlebar.height + interfaceitem.shadeHeight
                else
                    shadeAnimation.toHeight = hShadeSize
                        
                if(shadeHor)
                    shadeAnimation.toWidth  = buttons.width + interfaceitem.shadeWidth
                else 
                    shadeAnimation.toWidth = wShadeSize
                
                if(autoShade)
                    shadeAnimation.delay = interfaceitem.shadeDelay
                else
                    shadeAnimation.delay = 0
                        
                shade = true;
            }
            else {
                shadeAnimation.toHeight = hShadeSize
                shadeAnimation.toWidth =  wShadeSize
                
                if(autoShade)
                    shadeAnimation.delay = interfaceitem.unshadeDelay;
                else
                    shadeAnimation.delay = 0
                shade = false;
            }        
            shadeAnimation.start()            
        }
    }
    
    function toggleShade() {
        setShade(!shade);
    }
    
    //auto shade stuff
    function onEnter() {
        if(autoShade) setShade(false);
    }
    function onLeave() {
        if(autoShade) setShade(true);
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
     
        if(anchorObject.passive != interfaceitem)
            return;
        
        var list = anchorObject.isXtype ? Util.anchors.anchorXlist : Util.anchors.anchorYlist;
        var index = list.indexOf(anchorObject);
        list.splice(index, 1);
    }
    
    function removeActiveAnchor(anchorObject) {
     
        if(anchorObject.active != interfaceitem)
            return;
        
        interfaceitem.setControlledChange(true) 
        interfaceitem.anchors[anchorObject.activeAnchor] = undefined;
        interfaceitem.setControlledChange(false) 
        
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
            anchors[thisAnchor+'Margin'] = interfaceitem.margin;
        else
            anchors[thisAnchor+'Margin'] = 0;
        
        Util.anchors.controlledChange = false;
        
        var anchorObject = {active: interfaceitem, passive: item, activeAnchor: thisAnchor, passiveAnchor: itemAnchor, passiveName: item.objectName};        
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
            if(list[i].active == interfaceitem && 
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
                    
                    interfaceitem.setControlledChange(true)           
                    interfaceitem.anchors[resizeAnchor]  = resizeDragItem[resizeAnchor];
                    Util.anchors.resizeDragAnchorCache[resizeAnchor] = undefined;
                    interfaceitem.setControlledChange(false)
                }
            }
        }
        
        setAnchorIndicator(true)
    }
    
    function removePassiveAnchors(vertical) {
        
        var list = vertical ? Util.anchors.anchorYlist : Util.anchors.anchorXlist;
        
        for (var i=list.length-1; i>=0; --i) {
            if(list[i].passive == interfaceitem) {

                list[i].active.removeActiveAnchor(list[i]);               
                list.splice(i, 1);
            }
        }
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
    
    function setupResize(mouse, xf, yf, fixedanchor, draganchor, mode) {

        //the fix item mused be anchored to the item with the item as active one,
        //as the passive stays fixed and the active gets dragged. As this may override
        //possible existing anchors we need to store them and reenable them when finished
        Util.anchors.resizeFixedAnchorCache[fixedanchor] = getActiveAnchorObjectFor(fixedanchor);    
        Util.anchors.resizeDragAnchorCache[draganchor] = getActiveAnchorObjectFor(draganchor);   
        
        resizeFixItem.x = xf;
        resizeFixItem.y = yf;

        interfaceitem.setControlledChange(true)
        interfaceitem.anchors[fixedanchor] = resizeFixItem[fixedanchor];
        interfaceitem.anchors[fixedanchor+'Margin'] = 0;
        if(Util.anchors.resizeDragAnchorCache[draganchor] == undefined) {
            interfaceitem.anchors[draganchor] = resizeDragItem[draganchor];
            interfaceitem.anchors[draganchor+'Margin'] = 0
        }
        interfaceitem.setControlledChange(false)
        
        Util.setupDrag(interfaceitem, mouse, mode, draganchor);
    }
    
    function resizeMove(mouse) {
        Util.setAnchorsForPosition(mouse);     
    }
    
    function clearResize(fixed, drag) {
        
        interfaceitem.setControlledChange(true)
        interfaceitem.anchors[drag] = undefined;
        interfaceitem.anchors[fixed] = undefined;
        
        if(Util.anchors.resizeDragAnchorCache[drag] != undefined) {
            var obj = Util.anchors.resizeDragAnchorCache[drag];
            obj.active.anchors[obj.activeAnchor] = obj.passive[obj.passiveAnchor];
        }
        
        if(Util.anchors.resizeFixedAnchorCache[fixed] != undefined) {
            var obj = Util.anchors.resizeFixedAnchorCache[fixed];
            obj.active.anchors[obj.activeAnchor] = obj.passive[obj.passiveAnchor];
            
            if(obj.activeAnchor != obj.passiveAnchor)
                obj.active.anchors[obj.activeAnchor+'Margin'] = interfaceitem.margin;
            else
                obj.active.anchors[obj.activeAnchor+'Margin'] = 0;
        }
            
        Util.dragMode = Util.DragMode.None;
        interfaceitem.setControlledChange(false)
    }
    
    function getPassiveYItemChain(list) {
        Util.getPassiveYItemChain(list, interfaceitem);
    }
    
    function getPassiveXItemChain(list) {
        Util.getPassiveXItemChain(list, interfaceitem);
    }
    
    function setAnchorIndicator(draw) {
        var clist = parent.children;
        for(var i=0; i<clist.length; ++i) {
            if('drawAnchorIndicator' in clist[i]) 
                clist[i].drawAnchorIndicator(draw);
        }
    }
    
    function drawAnchorIndicator(draw) {
        resizer.drawAnchorIndicator(draw);
    }
    
    signal show(bool shw);
    
    SequentialAnimation {
        id: showanimation;
        property bool vis: true;
        
        PropertyAnimation {
            target: interfaceitem;
            property: "opacity";
            from: showanimation.vis ? 0 : 1;
            to: showanimation.vis ? 1 : 0;
        }
        PropertyAction {
            target: interfaceitem;
            property: "visible";
            value: showanimation.vis;
        }
        PropertyAction {
            target: interfaceitem;
            properties: "x,y";
            value: 300;
        }
    }        
        
    onShow: {
        //reset anchor, position and size state
        if(!shw) {
            removeActiveAnchors(true);
            removePassiveAnchors(true);
            removeActiveAnchors(false);
            removePassiveAnchors(false);
            setAnchorIndicator(false);
        }
        
        showanimation.vis = shw;
        showanimation.start();
    }
}