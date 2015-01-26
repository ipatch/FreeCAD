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

Item {
    
    id: resizeitem 
    
    property bool fixedWidth:  false
    property bool fixedHeight: false
    
    property Item interfaceitem;
         
    MouseCursor {
        id: cursorItem
    }
       
     //this is the top drag area
    MouseArea {
        id: topResizeArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: interfaceitem.dragframe

        enabled: !fixedHeight
        
        hoverEnabled: true
        onEntered: {
            if(!fixedHeight) {
                cursorItem.cursor = Qt.SizeVerCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
        
        onPressed: interfaceitem.resizeDragItem.y = interfaceitem.y;
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
        
        drag.target: interfaceitem.resizeDragItem
        drag.axis: Drag.YAxis
        drag.minimumY: 0
        drag.maximumY: interfaceitem.y + interfaceitem.height - interfaceitem.totalMinHeight
        
        drag.onActiveChanged: {
            if(drag.active && !fixedHeight) {
                var y_ = interfaceitem.y + interfaceitem.height;
                interfaceitem.setAnchorIndicator(true);
                interfaceitem.setupResize({x:mouseX, y:mouseY}, 0, y_, 'bottom', 'top', 5);
            }
            else if(!fixedHeight) {
                interfaceitem.clearResize('bottom', 'top');
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
            
        }
    }
    //top arrow
    Image {
        id: indicatorTop
        source: "qrc:/icons/button_up.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        height: Math.min(30, interfaceitem.height/2)
        width: Math.min(30, interfaceitem.width/2)
        visible:false
        
        onVisibleChanged: opacity=0;
        
        Behavior on visible {
            PropertyAnimation{
                target: indicatorTop
                property: "opacity"
                from: 0
                to: 1
            }
        }
    }

    //this is the bottom drag area
    MouseArea {
        id: bottomResizeArea
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: dragframe

        enabled: !fixedHeight
        
        hoverEnabled: true
        onEntered: {
            if(!fixedHeight) {
                cursorItem.cursor = Qt.SizeVerCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                //interfaceitem.setAnchorIndicator(false);
            }
        }
                
        onPressed: interfaceitem.resizeDragItem.y = interfaceitem.y + interfaceitem.height;
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
                
        drag.target: interfaceitem.resizeDragItem
        drag.axis: Drag.YAxis
        drag.minimumY: interfaceitem.y + interfaceitem.totalMinHeight;
                
        drag.onActiveChanged: {
            if(drag.active && !fixedHeight) {
                drag.maximumY = interfaceitem.parent.height;
                var y_ = interfaceitem.y;
                interfaceitem.setAnchorIndicator(true);
                interfaceitem.setupResize({x:mouseX, y:mouseY}, 0, y_, 'top', 'bottom', 5);
            }
            else if(!fixedHeight) {
                interfaceitem.clearResize('top', 'bottom');
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
    }
    
    //bottom arrow
    Image {
        id: indicatorBottom
        source: "qrc:/icons/button_down.svg"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        width: Math.min(30, interfaceitem.width/2)
        height: Math.min(30, interfaceitem.height/2)
        visible:false
        
        onVisibleChanged: opacity=0;
        
        Behavior on visible {
            PropertyAnimation{
                target: indicatorBottom
                property: "opacity"
                from: 0
                to: 1
            }
        }
    }
    
    //this is the left drag area
    MouseArea {
        id: leftResizeArea
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: dragframe

        enabled: !fixedWidth

        hoverEnabled: true
        onEntered: {
            if(!fixedWidth) {
                cursorItem.cursor = Qt.SizeHorCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                //interfaceitem.setAnchorIndicator(false);
            }
        }
                
        onPressed: interfaceitem.resizeDragItem.x = interfaceitem.x;
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
                
        drag.target: interfaceitem.resizeDragItem
        drag.axis: Drag.XAxis
        drag.minimumX: 0
        drag.maximumX: interfaceitem.x + interfaceitem.width - interfaceitem.minWidth
                
        drag.onActiveChanged: {
            if(drag.active && !fixedWidth) {
                interfaceitem.setAnchorIndicator(true);
                var x = interfaceitem.x + interfaceitem.width;
                interfaceitem.setupResize({x:mouseX, y:mouseY}, x, 0, 'right', 'left',4);
            }
            else if(!fixedWidth) {
                interfaceitem.clearResize('right', 'left');
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
    }
    //leftarrow
    Image {
        id: indicatorLeft
        source: "qrc:/icons/button_left.svg"
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: Math.min(30, interfaceitem.width/2)
        height: Math.min(30, interfaceitem.height/2)
        visible:false
        
        onVisibleChanged: opacity=0;
        
        Behavior on visible {
            PropertyAnimation{
                target: indicatorLeft
                property: "opacity"
                from: 0
                to: 1
            }
        }
    }
    
    //this is the right drag area
    MouseArea {
        id: rightResizeArea
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: dragframe               

        enabled: !fixedWidth
        
        hoverEnabled: true
        onEntered: {
            if(!fixedWidth) {
                cursorItem.cursor = Qt.SizeHorCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                //interfaceitem.setAnchorIndicator(false);
            }
        }
                
        onPressed: interfaceitem.resizeDragItem.x = interfaceitem.x + interfaceitem.width;
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
                
        drag.target: interfaceitem.resizeDragItem
        drag.axis: Drag.XAxis
        drag.minimumX: interfaceitem.x + interfaceitem.minWidth;
                
        drag.onActiveChanged: {
            if(drag.active && !fixedWidth) {
                interfaceitem.setAnchorIndicator(true);
                drag.maximumX = interfaceitem.parent.width; //parent is not defined on creation
                var x = interfaceitem.x;
                interfaceitem.setupResize({x:mouseX, y:mouseY}, x, 0, 'left', 'right', 4);
            }
            else if(!fixedWidth) {
                interfaceitem.clearResize('left', 'right');
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
    }
    //right arrow
    Image {
        id: indicatorRight
        source: "qrc:/icons/button_right.svg"
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        width: Math.min(30, interfaceitem.width/2)
        height: Math.min(30, interfaceitem.height/2)
        visible:false
        
        onVisibleChanged: opacity=0;
        
        Behavior on visible {
            PropertyAnimation{
                target: indicatorRight
                property: "opacity"
                from: 0
                to: 1
            }
        }
    }
    
    //go on with the corners
    //**********************
    
    
    //this is the top right drag area
    MouseArea {
        id: toprightResizeArea
        anchors.right: parent.right
        anchors.top: parent.top
        width:  dragframe
        height: dragframe

        enabled: !fixedWidth || !fixedHeight
        
        hoverEnabled: true
        onEntered: {
            if(!(fixedWidth && fixedHeight)) {
                cursorItem.cursor = Qt.SizeBDiagCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                //interfaceitem.setAnchorIndicator(false);
            }
        }
                
        onPressed: {
            interfaceitem.resizeDragItem.x = interfaceitem.x + interfaceitem.width;
            interfaceitem.resizeDragItem.y = interfaceitem.y;
        }
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
                
        drag.target: interfaceitem.resizeDragItem
        drag.minimumX: interfaceitem.x + interfaceitem.minWidth;
        drag.minimumY: 0
        drag.maximumY: interfaceitem.y + interfaceitem.height - interfaceitem.totalMinHeight
                 
        drag.onActiveChanged: {
            if(drag.active && (!(fixedWidth && fixedHeight))) {
                interfaceitem.setAnchorIndicator(true);
                drag.maximumX = interfaceitem.parent.width; //parent is not defined on creation
                var y = interfaceitem.y + interfaceitem.height;
                var mode = 5 - ((fixedWidth) ? 0 : ((fixedHeight) ? 1 : 2));
                if(!fixedWidth)
                    interfaceitem.setupResize({x:mouseX, y:mouseY}, interfaceitem.x, y, 'left', 'right', mode);
                if(!fixedHeight)
                    interfaceitem.setupResize({x:mouseX, y:mouseY}, interfaceitem.x, y, 'bottom', 'top', mode)
            }
            else if(!(fixedWidth && fixedHeight)) {
                if(!fixedWidth)
                    interfaceitem.clearResize('left', 'right');
                if(!fixedHeight)
                    interfaceitem.clearResize('bottom', 'top');
                
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
    }
    
    //this is the bottom left drag area
    MouseArea {
        id: bottomleftResizeArea
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width:  dragframe
        height: dragframe

        enabled: !fixedWidth || !fixedHeight
        
        hoverEnabled: true
        onEntered: {
            if(!(fixedWidth && fixedHeight)) {
                cursorItem.cursor = Qt.SizeBDiagCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                //interfaceitem.setAnchorIndicator(false);
            }
        }
                
        onPressed: {
            interfaceitem.resizeDragItem.x = interfaceitem.x;
            interfaceitem.resizeDragItem.y = interfaceitem.y + interfaceitem.height;
        }
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
                
        drag.target: interfaceitem.resizeDragItem
        drag.minimumX: 0;
        drag.maximumX: interfaceitem.x + interfaceitem.width - interfaceitem.minWidth;
        drag.minimumY: interfaceitem.y + interfaceitem.totalMinHeight
                 
        drag.onActiveChanged: {
            if(drag.active && (!(fixedWidth && fixedHeight))) {
                interfaceitem.setAnchorIndicator(true);
                drag.maximumY = interfaceitem.parent.height; //parent is not defined on creation
                var x = interfaceitem.x + interfaceitem.width;
                var mode = 5 - ((fixedWidth) ? 0 : ((fixedHeight) ? 1 : 2));
                if(!fixedWidth)
                    interfaceitem.setupResize({x:mouseX, y:mouseY}, x, interfaceitem.y, 'right', 'left', mode);
                if(!fixedHeight)
                    interfaceitem.setupResize({x:mouseX, y:mouseY}, x, interfaceitem.y, 'top', 'bottom', mode)
            }
            else if(!(fixedWidth && fixedHeight)) {
                if(!fixedWidth)
                    interfaceitem.clearResize('right', 'left');
                if(!fixedHeight)
                    interfaceitem.clearResize('top', 'bottom');
                
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
    }
    
    //this is the top left drag area
    MouseArea {
        id: topleftResizeArea
        anchors.left: parent.left
        anchors.top: parent.top
        width:  dragframe
        height: dragframe

        enabled: !fixedWidth || !fixedHeight
        
        hoverEnabled: true
        onEntered: {
            if(!(fixedWidth && fixedHeight)) {
                cursorItem.cursor = Qt.SizeFDiagCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                //interfaceitem.setAnchorIndicator(false);
            }
        }
                
        onPressed: {
            interfaceitem.resizeDragItem.x = interfaceitem.x;
            interfaceitem.resizeDragItem.y = interfaceitem.y;
        }
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
                
        drag.target: interfaceitem.resizeDragItem
        drag.minimumX: 0;
        drag.maximumX: interfaceitem.x + interfaceitem.width - interfaceitem.minWidth;
        drag.minimumY: 0;
        drag.maximumY: interfaceitem.y + interfaceitem.height - interfaceitem.totalMinHeight;
                 
        drag.onActiveChanged: {
            interfaceitem.setAnchorIndicator(true);
            if(drag.active && (!(fixedWidth && fixedHeight))) {
                var x = interfaceitem.x + interfaceitem.width;
                var y = interfaceitem.y + interfaceitem.height;
                var mode = 5 - ((fixedWidth) ? 0 : ((fixedHeight) ? 1 : 2));
                if(!fixedWidth)
                    interfaceitem.setupResize({x:mouseX, y:mouseY}, x, y, 'right', 'left', mode);
                if(!fixedHeight)
                    interfaceitem.setupResize({x:mouseX, y:mouseY}, x, y, 'bottom', 'top', mode)
            }
            else if(!(fixedWidth && fixedHeight)) {
                if(!fixedWidth)
                    interfaceitem.clearResize('right', 'left');
                if(!fixedHeight)
                    interfaceitem.clearResize('bottom', 'top');
                
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
    }
    
    //this is the bottom right drag area
    MouseArea {
        id: bottomrightResizeArea
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width:  dragframe
        height: dragframe

        enabled: !fixedWidth || !fixedHeight
        
        hoverEnabled: true
        onEntered: {
            if(!(fixedWidth && fixedHeight)){
                cursorItem.cursor = Qt.SizeFDiagCursor
                //if(!drag.active) interfaceitem.setAnchorIndicator(true);
            }
        }
        onExited:  {
            if(!drag.active) {
                cursorItem.cursor = Qt.ArrowCursor
                //interfaceitem.setAnchorIndicator(false);
            }
        }
                
        onPressed: {
            interfaceitem.resizeDragItem.x = interfaceitem.x + interfaceitem.width;
            interfaceitem.resizeDragItem.y = interfaceitem.y + interfaceitem.height;
        }
        onPositionChanged: if(drag.active) interfaceitem.resizeMove(mouse);
                
        drag.target: interfaceitem.resizeDragItem
        drag.minimumX: interfaceitem.x + interfaceitem.minWidth;
        drag.minimumY: interfaceitem.y + interfaceitem.totalMinHeight;
                  
        drag.onActiveChanged: {
            interfaceitem.setAnchorIndicator(true);
            if(drag.active && (!(fixedWidth && fixedHeight))) {
                drag.maximumY = interfaceitem.parent.height;
                drag.maximumX = interfaceitem.parent.width;
                var y = interfaceitem.y;
                var mode = 5 - ((fixedWidth) ? 0 : ((fixedHeight) ? 1 : 2));
                if(!fixedWidth)
                        interfaceitem.setupResize({x:mouseX, y:mouseY}, interfaceitem.x, y, 'left', 'right', mode);
                if(!fixedHeight)
                    interfaceitem.setupResize({x:mouseX, y:mouseY}, interfaceitem.x, y, 'top', 'bottom', mode)
            }
            else if(!(fixedWidth && fixedHeight)) {
                if(!fixedWidth)
                    interfaceitem.clearResize('left', 'right');
                if(!fixedHeight)
                    interfaceitem.clearResize('top', 'bottom');
                
                cursorItem.cursor = Qt.ArrowCursor
                interfaceitem.setAnchorIndicator(false);
            }
        }
    }
    
    function drawAnchorIndicator(draw) {
        
        if(draw) {
            if(interfaceitem.getActiveAnchorObjectFor('top') != undefined) {
                if(!indicatorTop.visible) indicatorTop.visible = true;
            }
            else
                indicatorTop.visible = false;
            
            if(interfaceitem.getActiveAnchorObjectFor('bottom') != undefined)  {
                if(!indicatorBottom.visible) {
                    indicatorBottom.visible = true;
                 }
            }
            else
                indicatorBottom.visible = false;
            
            if(interfaceitem.getActiveAnchorObjectFor('left') != undefined) {
                if(!indicatorLeft.visible) indicatorLeft.visible = true;
            }
            else
                indicatorLeft.visible = false;
            
            if(interfaceitem.getActiveAnchorObjectFor('right') != undefined) {
                if(!indicatorRight.visible) indicatorRight.visible = true;
            }
            else
                indicatorRight.visible = false;
        }
        else {
            indicatorBottom.visible = false;
            indicatorLeft.visible = false;
            indicatorRight.visible = false;
            indicatorTop.visible = false;
        }
    }
}