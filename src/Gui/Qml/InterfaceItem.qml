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
    
    width: 200
    height: 50
        
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
            anchors.right: buttons.left
            elide: Text.ElideRight
        }
        MouseArea {
            anchors.left: titleItem.left
            anchors.right: titleItem.right
            height: titleItem.height
            drag.target: interfaceitem
            drag.minimumX: 0
            drag.maximumX: interfaceitem.parent.width - parent.width
            drag.minimumY: 0
            drag.maximumY: interfaceitem.parent.height - parent.height
            
            onPressed: Util.setupHitPositions(interfaceitem, mouse);
            onPositionChanged: Util.setAnchorsForPosition(mouse);
        }
        Row {
            id:buttons
            anchors.left: titleItem.right
            anchors.right: parent.right
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
        anchors.top:   titlebar.bottom
        anchors.left:  parent.left
        anchors.right: parent.right
    }
    
}