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
    id: navigator
    property int  tabwidth: 120
    property Item mdiArea
        
    height: 20
    width:  3*tabwidth + 3*list.spacing
    anchors.fill: parent
    
    ListView {
        id: list
        model: mdiArea.children
        
        boundsBehavior: Flickable.DragOverBounds
        highlightFollowsCurrentItem: true
        orientation: ListView.Horizontal 
        anchors.fill: parent
        highlightMoveSpeed: 800
        spacing: 4
             
        highlight: Rectangle {
            width:  tabwidth
            height: 20
            radius: 4
            color: "#60FF0000"
        }
        delegate: Rectangle {
            width:  tabwidth
            height: 20
            radius: 4
            color: "#600000FF"

            Icon {
                id:image
                width: 20
                height: 20
                icon: model.modelData.proxy.windowIcon
            }
            Text {
                id: text
                width:  tabwidth-42
                height: 20
                anchors.left: image.right
                anchors.leftMargin: 2
                elide: Text.ElideRight
                text: model.modelData.proxy.windowTitle
            }
            MouseArea {
                width:tabwidth-20
                height: 20
                anchors.left: parent.left
                onClicked: {
                    mdiArea.current = index
                    list.currentIndex = index;
                }
            }
            Button {
                width: 20
                height: 20
                margin: 1
                icon: ":/icons/delete.svg"
                anchors.left: text.right
                onActivated: closeView(index)
            }
        }
        
        onModelChanged: {
            mdiArea.current = list.model.length-1
            list.currentIndex = list.model.length-1
        }
    }
    
    //needed to reparent a view before deletion
    Item {
        id: dummy
    }
    
    function closeView(id) {
        var next = (list.currentIndex == id ? list.currentIndex - 1 : list.currentIndex)
        next = (next<0) ? 0 : next
        mdiArea.current = next
        list.currentIndex = next
        var item = mdiArea.children[id]
        item.parent = dummy
        item.requestDestroy(item)
    }
}