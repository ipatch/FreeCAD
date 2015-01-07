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

var top;
var bottom;
var verticalCenter;
var activeYAnchor;

var left;
var right;
var horizontalCenter;
var activeXAnchor;

var dragItem;
var initMousePos;

function setupHitPositions(item, mouse) {
    
    top = new Array();
    bottom = new Array();
    verticalCenter = new Array();
    
    left = new Array();
    right = new Array();
    horizontalCenter = new Array();
    
    //the frame anchors have priority so add them first
    top[top.length] = {item:item.parent, pos:0};
    bottom[bottom.length] = {item:item.parent, pos:item.parent.height};
    verticalCenter[verticalCenter.length] = {item:item.parent, pos:item.parent.height/2};
    
    left[left.length] = {item:item.parent, pos:0};
    right[right.length] = {item:item.parent, pos:item.parent.width};
    horizontalCenter[horizontalCenter.length] = {item:item.parent, pos:item.parent.width/2};
    
    //now add all posible child hitpoints
    for (var i = 0; i < item.parent.children.length; ++i) {
        var cur = item.parent.children[i];
        if(cur != item) {
            top[top.length] = {item:cur, pos:cur.y};
            bottom[bottom.length] = {item:cur, pos:cur.y+cur.height};
            verticalCenter[verticalCenter.length] = {item:cur, pos:cur.y+cur.height/2};
            
            left[left.length] = {item:cur, pos:cur.x};
            right[right.length] = {item:cur, pos:cur.x+cur.width};
            horizontalCenter[horizontalCenter.length] = {item:cur, pos:cur.x+cur.width/2};
        }
    }
    
    dragItem = item;
    activeYAnchor = undefined;
    activeXAnchor = undefined;
    initMousePos = {x:mouse.x, y:mouse.y};
}

function setAnchorsForPosition(mousePos) {
    
    if(activeYAnchor == undefined) {
        
        //search for a possible y anchor, start with top
        if(setPossibleAnchor(dragItem.y, 'top')) {
            activeYAnchor = 'top';
            return;
        }
        if(setPossibleAnchor(dragItem.y+dragItem.height, 'bottom')) {
            activeYAnchor = 'bottom';
            return;
        }
        if(setPossibleAnchor(dragItem.y+dragItem.height/2, 'verticalCenter')) {
            activeYAnchor = 'verticalCenter';
            return;
        }
    }
    else if(Math.abs(initMousePos.y - mousePos.y) > 50) {
        //clear the vertical anchor
        if('top' == activeYAnchor) {
            dragItem.anchors.top = undefined;
            activeYAnchor = undefined;
            return;
        }
        if('verticalCenter' == activeYAnchor) {
            console.debug("set undefined")
            dragItem.anchors.verticalCenter = undefined;
            activeYAnchor = undefined;
            return;
        }
        if('bottom' == activeYAnchor) {
            dragItem.anchors.bottom = undefined;
            activeYAnchor = undefined;
            return;
        }
    }
    
    if(activeXAnchor == undefined) {
        
        //search for a possible y anchor, start with top
        if(setPossibleAnchor(dragItem.x, 'left')) {
            activeXAnchor = 'left';
            return;
        }
        if(setPossibleAnchor(dragItem.x+dragItem.width, 'right')) {
            activeXAnchor = 'right';
            return;
        }
        if(setPossibleAnchor(dragItem.x+dragItem.width/2, 'horizontalCenter')) {
            activeXAnchor = 'horizontalCenter';
            return;
        }
    }
    else if(Math.abs(initMousePos.x - mousePos.x) > 50) {
        //clear the vertical anchor
        if('left' == activeXAnchor) {
            dragItem.anchors.left = undefined;
            activeXAnchor = undefined;
            return;
        }
        if('horizontalCenter' == activeXAnchor) {
            dragItem.anchors.horizontalCenter = undefined;
            activeXAnchor = undefined;
            return;
        }
        if('right' == activeXAnchor) {
            dragItem.anchors.right = undefined;
            activeXAnchor = undefined;
            return;
        }
    }
}

function setPossibleAnchor(position, anchor) {
    
    if(anchor == 'top' || anchor == 'bottom' || anchor == 'verticalCenter') {
        if(singleAnchorHelper(top, position, anchor, 'top'))
            return true;
        
        if(singleAnchorHelper(bottom, position, anchor, 'bottom')) 
            return true;
        
        if(singleAnchorHelper(verticalCenter, position, anchor, 'verticalCenter'))
            return true;
    }
    else {
        if(singleAnchorHelper(left, position, anchor, 'left'))
            return true;
        
        if(singleAnchorHelper(right, position, anchor, 'right')) 
            return true;
        
        if(singleAnchorHelper(horizontalCenter, position, anchor, 'horizontalCenter'))
            return true;
    }
    
    return false;
}

function singleAnchorHelper(hitPositions, position, anchorItem, anchorSecond) {
    
    for (var i = 0; i < hitPositions.length; ++i) {
        
         if(Math.abs(hitPositions[i].pos-position) < 10) {
             dragItem.anchors[anchorItem] = hitPositions[i].item[anchorSecond];
             return true;
         }
    }
    return false;
}