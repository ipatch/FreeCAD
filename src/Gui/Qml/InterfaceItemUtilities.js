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

//settings
var sr = 8;    //snap radius around the items
var reset = 50; //reset radius 

//enumerations
var DragMode = {
    DragXY: 0,
    DragX:  1,
    DragY:  2,
    SizeXY: 3,
    SizeX:  4,
    SizeY:  5,
    Nonde:  6
};

//used to store the x and y anchor list and numerous anchor information
var anchors;

//object to store all hitpoint arrays
var hitPoints;

//current drag data
var dragItem;
var initMousePos;
var dragMode;

function setupDrag(item, mouse, mode, resizeAnchor) {
    
    hitPoints = new Object();
    dragItem = item;
    dragMode = mode;
    initMousePos = {x:mouse.x, y:mouse.y};
    anchors.resizeAnchor = resizeAnchor;   //undefined for drag
    
    var ylist = [];
    var xlist = [];
    getPassiveYItemChain(ylist);
    getPassiveXItemChain(xlist);
    setupHitPositions(xlist, ylist);
    
    console.debug("setup drag mode: ", dragMode)
}

function setupHitPositions(xlist, ylist) {

    hitPoints.top = new Array();
    hitPoints.bottom = new Array();
    hitPoints.verticalCenter = new Array();
    
    hitPoints.left = new Array();
    hitPoints.right = new Array();
    hitPoints.horizontalCenter = new Array();
    
    //the frame anchors have priority so add them first
    hitPoints.top.push({item:dragItem.parent, rect:Qt.rect(0,0,dragItem.parent.width, sr)});
    hitPoints.bottom.push({item:dragItem.parent, rect:Qt.rect(0,dragItem.parent.height-sr, dragItem.parent.width, sr)});
    hitPoints.verticalCenter.push({item:dragItem.parent, rect:Qt.rect(0,dragItem.parent.height/2-sr/2, 2*sr, sr)});
    hitPoints.verticalCenter.push({item:dragItem.parent, rect:Qt.rect(dragItem.parent.width-2*sr,dragItem.parent.height/2-sr/2, 2*sr, sr)});
    
    hitPoints.left.push({item:dragItem.parent, rect: Qt.rect(0, 0, sr, dragItem.parent.height)});
    hitPoints.right.push({item:dragItem.parent, rect: Qt.rect(dragItem.parent.width-sr, 0, sr, dragItem.parent.height)});
    hitPoints.horizontalCenter.push({item:dragItem.parent, rect: Qt.rect(dragItem.parent.width/2-sr/2, 0, sr, sr)});
    hitPoints.horizontalCenter.push({item:dragItem.parent, rect: Qt.rect(dragItem.parent.width/2-sr/2, dragItem.parent.height-sr, sr, sr)});
    
    //now add all posible child hitpoints
    for (var i = 0; i < dragItem.parent.children.length; ++i) {
        var cur = dragItem.parent.children[i];
        if(cur != dragItem && cur.width>0 && !contains(ylist, cur) && !contains(xlist, cur)) { //drag resize items have width 0
            hitPoints.top.push({item:cur, rect:Qt.rect(cur.x-sr, cur.y-sr, cur.width+2*sr, 2*sr)});
            hitPoints.bottom.push({item:cur, rect:Qt.rect(cur.x-sr, cur.y+cur.height-sr, cur.width+2*sr, 2*sr)});
            hitPoints.left.push({item:cur, rect: Qt.rect(cur.x-sr, cur.y-sr, 2*sr, cur.height+2*sr)});
            hitPoints.right.push({item:cur, rect: Qt.rect(cur.x+cur.width+sr, cur.y-sr, 2*sr, cur.height+2*sr)});
        }
    }   
}

function getPassiveYItemChain(list) {
    
    for (var i=0; i<anchors.anchorYlist.length; ++i) {
        if(anchors.anchorYlist[i].passive == dragItem) {
            list.push(anchors.anchorYlist[i].active);
            anchors.anchorYlist[i].active.getPassiveYItemChain(list)
        }
    }    
}

function getPassiveXItemChain(list) {
    
    for (var i=0; i<anchors.anchorXlist.length; ++i) {
        if(anchors.anchorXlist[i].passive == dragItem) {
            list.push(anchors.anchorXlist[i].active);
            anchors.anchorXlist[i].active.getPassiveXItemChain(list)
        }
    }    
}

function setAnchorsForPosition(mousePos) {

    if(dragMode == DragMode.DragXY || dragMode == DragMode.DragY 
         || dragMode == DragMode.SizeXY || dragMode == DragMode.SizeY) {

        if(getActiveAnchorObjectFor('top') == undefined) {
            if(setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y-sr, dragItem.width+2*sr, 2*sr), 'top', ['top', 'bottom']))
                return;
        }
        if(getActiveAnchorObjectFor('bottom') == undefined) {
            if(setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y+dragItem.height-sr, dragItem.width+2*sr, 2*sr), 'bottom', ['top', 'bottom']))
                return
        }
        if(getActiveAnchorObjectFor('verticalCenter') == undefined) {
            if(setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y+dragItem.height/2-sr/2, 2*sr, sr), 'verticalCenter', ['verticalCenter']))
                return; 
            
            if(setPossibleAnchor(Qt.rect(dragItem.x+dragItem.width-2*sr, dragItem.y+dragItem.height/2-sr/2, 2*sr, sr), 'verticalCenter', ['verticalCenter']))
                return;   
        }
        if(Math.abs(initMousePos.y - mousePos.y) > reset) {
            dragItem.removeAnchors(true, anchors.resizeAnchor)
        }
    }
    
    if(dragMode == DragMode.DragXY || dragMode == DragMode.DragX 
         || dragMode == DragMode.SizeXY || dragMode == DragMode.SizeX) {

        if(getActiveAnchorObjectFor('left') == undefined) {
            if(setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y-sr, 2*sr, dragItem.height+2*sr), 'left', ['left', 'right']))
                return;
        }
        if(getActiveAnchorObjectFor('right') == undefined) {
            if(setPossibleAnchor(Qt.rect(dragItem.x+dragItem.width+sr, dragItem.y-sr, 2*sr, dragItem.height+2*sr), 'right', ['left', 'right']))
                return;
        }
        if(getActiveAnchorObjectFor('horizontalCenter') == undefined) {
            if(setPossibleAnchor(Qt.rect(dragItem.x + dragItem.width/2-sr/2, dragItem.y-sr/2, sr, sr), 'horizontalCenter', ['horizontalCenter']))
                return;
    
            if(setPossibleAnchor(Qt.rect(dragItem.x + dragItem.width/2-sr/2, dragItem.y + dragItem.height-sr, sr, 2*sr), 'horizontalCenter', ['horizontalCenter']))
                return;
        }
        if(Math.abs(initMousePos.x - mousePos.x) > reset) {
            dragItem.removeAnchors(false, anchors.resizeAnchor)
        }
    }
}

function setPossibleAnchor(position, anchor, hitanchors) {
    
    for(var i=0; i<hitanchors.length; ++i) {
                
        var hitPos = hitPoints[hitanchors[i]];
        var hitAnchor = hitanchors[i];
        
        for (var j=0; j<hitPos.length; ++j) {

            if(doRectsOverlap(hitPos[j].rect, position)) {

                dragItem.setupAnchor(anchor, hitPos[j].item, hitAnchor);                
                return true;
            }
        }
    }
    
    return false;
}

function doRectsOverlap(r1, r2) {

    return !( (r1.y+r1.height) < r2.y || r1.y > (r2.y+r2.height) || (r1.x+r1.width) < r2.x || r1.x > (r2.x+r2.width) );
}

function contains(a, obj) {
    var i = a.length;
    while (i--) {
       if (a[i] === obj) {
           return true;
       }
    }
    return false;
}
