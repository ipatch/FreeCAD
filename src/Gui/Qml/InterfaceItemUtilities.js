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

//used to store the x and y anchor list
var anchors;

//object to store all hitpoint arrays
var hitPoints;

//current drag data
var dragItem;
var initMousePos;

function setupHitPositions(item, mouse) {
    
    hitPoints = new Object();
    hitPoints.top = new Array();
    hitPoints.bottom = new Array();
    hitPoints.verticalCenter = new Array();
    
    hitPoints.left = new Array();
    hitPoints.right = new Array();
    hitPoints.horizontalCenter = new Array();
    
    //the frame anchors have priority so add them first
    hitPoints.top[hitPoints.top.length] = {item:item.parent, rect:Qt.rect(0,0,item.parent.width, sr)};
    hitPoints.bottom[hitPoints.bottom.length] = {item:item.parent, rect:Qt.rect(0,item.parent.height-sr, item.parent.width, sr)};
    hitPoints.verticalCenter[hitPoints.verticalCenter.length] = {item:item.parent, rect:Qt.rect(0,item.parent.height/2-sr/2, 2*sr, sr)};
    hitPoints.verticalCenter[hitPoints.verticalCenter.length] = {item:item.parent, rect:Qt.rect(item.parent.width-2*sr,item.parent.height/2-sr/2, 2*sr, sr)};
    
    hitPoints.left[hitPoints.left.length] = {item:item.parent, rect: Qt.rect(0, 0, sr, item.parent.height)};
    hitPoints.right[hitPoints.right.length] = {item:item.parent, rect: Qt.rect(item.parent.width-sr, 0, sr, item.parent.height)};
    hitPoints.horizontalCenter[hitPoints.horizontalCenter.length] = {item:item.parent, rect: Qt.rect(item.parent.width/2-sr/2, 0, sr, sr)};
    hitPoints.horizontalCenter[hitPoints.horizontalCenter.length] = {item:item.parent, rect: Qt.rect(item.parent.width/2-sr/2, item.parent.height-sr, sr, sr)};
    
    //now add all posible child hitpoints
    for (var i = 0; i < item.parent.children.length; ++i) {
        var cur = item.parent.children[i];
        if(cur != item) {
            hitPoints.top[hitPoints.top.length] = {item:cur, rect:Qt.rect(cur.x-sr, cur.y-sr, cur.width+2*sr, 2*sr)};
            hitPoints.bottom[hitPoints.bottom.length] = {item:cur, rect:Qt.rect(cur.x-sr, cur.y+cur.height-sr, cur.width+2*sr, 2*sr)};
                        
            hitPoints.left[hitPoints.left.length] = {item:cur, rect: Qt.rect(cur.x-sr, cur.y-sr, 2*sr, cur.height+2*sr)};
            hitPoints.right[hitPoints.right.length] = {item:cur, rect: Qt.rect(cur.x+cur.width+sr, cur.y-sr, 2*sr, cur.height+2*sr)};
        }
    }
    
    dragItem = item;
    initMousePos = {x:mouse.x, y:mouse.y};
}

function setAnchorsForPosition(mousePos) {

    if(anchors.anchorYlist.length == 0) {
        
        //search for a possible y anchor, start with top
        if( setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y-sr, dragItem.width+2*sr, 2*sr), 'top', ['top', 'bottom'])
         || setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y+dragItem.height-sr, dragItem.width+2*sr, 2*sr), 'bottom', ['top', 'bottom'])
         || setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y+dragItem.height/2-sr/2, 2*sr, sr), 'verticalCenter', ['verticalCenter'])
         || setPossibleAnchor(Qt.rect(dragItem.x+dragItem.width-2*sr, dragItem.y+dragItem.height/2-sr/2, 2*sr, sr), 'verticalCenter', ['verticalCenter']))
            return;

    }
    else if(Math.abs(initMousePos.y - mousePos.y) > reset) {
        dragItem.removeAnchors(true)
    }
    
    if(anchors.anchorXlist.length == 0) {
        
        //search for a possible x anchor, start with left
        if(setPossibleAnchor(Qt.rect(dragItem.x-sr, dragItem.y-sr, 2*sr, dragItem.height+2*sr), 'left', ['left', 'right'])
          || setPossibleAnchor(Qt.rect(dragItem.x+dragItem.width+sr, dragItem.y-sr, 2*sr, dragItem.height+2*sr), 'right', ['left', 'right'])
          || setPossibleAnchor(Qt.rect(dragItem.x + dragItem.width/2-sr/2, dragItem.y-sr/2, sr, sr), 'horizontalCenter', ['horizontalCenter'])
          || setPossibleAnchor(Qt.rect(dragItem.x + dragItem.width/2-sr/2, dragItem.y + dragItem.height-sr, sr, 2*sr), 'horizontalCenter', ['horizontalCenter']))
            return;
    }
    else if(Math.abs(initMousePos.x - mousePos.x) > reset) {
        dragItem.removeAnchors(false)
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