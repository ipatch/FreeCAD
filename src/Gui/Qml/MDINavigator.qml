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
    property int   tabheight: 20
    property int   tabwidth: 140
    property Item  mdiArea        
    property alias index: list.currentIndex
            
    height: tabheight
    anchors.fill: parent
    
    ListView {
        id: list
        model: mdiArea.views
        
        boundsBehavior: Flickable.DragOverBounds
        highlightFollowsCurrentItem: true
        orientation: ListView.Horizontal 
        anchors.fill: parent
        highlightMoveSpeed: 800
        spacing: 4
             
        delegate: Rectangle {
            id: itemDelegate
            width:  tabwidth
            height: tabheight
            radius: 4
            color: "#600000FF"
        
            Settings {
                id: settings
                trackedPreference: "Interface"
                
                onValueChanged: updateSetting(name)
            }
    
            Icon {
                id:image
                anchors.left:   parent.left
                anchors.top:    parent.top
                anchors.bottom: parent.bottom
                anchors.margins: 2
                width: 16
                icon: model.item.icon
            }
            Text {
                id: text
                width:  tabwidth-42
                height: 20
                anchors.left: image.right
                anchors.leftMargin: 2
                elide: Text.ElideRight
                text: model.item.title
            }
            MouseArea {
                id: marea
                width:tabwidth-20
                height: 20
                anchors.left: parent.left
                
                CursorArea {
                    anchors.fill: parent
                    cursor: marea.drag.active ? Qt.SizeAllCursor : Qt.ArrowCursor
                }
                
                onPressed: {
                    list.currentIndex = index
                    mdiArea.currentID = model.item.viewID  
                }
                onDoubleClicked: {
                    mdiArea.toggleFloat(model.item.viewID)
                }
                drag.target: content
                drag.axis: Drag.YAxis
                drag.onActiveChanged: {                    
                    if(drag.active) {
                        list.currentIndex = index
                        mdiArea.currentID = model.item.viewID 
                        var mouse = mapToItem(mdiArea, marea.mouseX, marea.mouseY)
                        mdiArea.toggleFloat(model.item.viewID, mouse)
                        drag.axis = Drag.XandYAxis
                        //mimic the items drag behaviour with our content item
                        model.item.setupDragProxy(content, drag)
                    }
                    else {
                        drag.axis = Drag.YAxis
                        content.x = parent.x + parent.width/2 -200
                        content.y = parent.y + 10
                    }
                    var m = mapToItem(mdiArea, mouseX, mouseY)
                    model.item.areaActivateDrag(drag.active, m)
                }
                
                onPositionChanged: {
                    var m = mapToItem(mdiArea, mouse.x, mouse.y)
                    model.item.areaDragPosition(m)
                    m = mapToItem(mdiArea, content.x, content.y)
                    model.item.x = m.x
                    model.item.y = m.y
                }
                
                Item {
                    id: content
                    x: parent.x + parent.width/2 -200
                    y: parent.y + 10
                }
            }
            Button {
                width: 20
                height: 20
                margin: 1
                icon: ":/icons/delete.svg"
                anchors.left: text.right
                onActivated: closeView(model.item.viewID)
            }
            
            Component.onCompleted: updateSetting("BackgroundColor");
    
            function updateSetting(name) {
            
                if(name == "BackgroundColor" || name == "BackgroundAlpha") {
                    
                    var rgb = settings.getColor("BackgroundColor", "white");
                    var a   = settings.getInt("BackgroundAlpha", 1);
                    itemDelegate.color = Qt.rgba(rgb.x/255, rgb.y/255, rgb.z/255, a/255);            
                }
            }
            
            function getViewID() {
                return model.item.viewID
            }
        }
        
        highlight: Rectangle {
            width:  tabwidth
            height: 20
            radius: 4
            color: "#40FF0000"
            z:100
        }
        
        onCountChanged: {
            if(list.model.count > 0) {
                list.currentIndex = list.model.count-1
                mdiArea.currentID = list.currentItem.getViewID()
            }
        }
    }
    
    function indexForId(id) {
        for (var i = 0; i < list.model.count; ++i) {
            if(list.model.get(i).item.viewID == id)
                return i;
        }
    }
    
    function closeView(id) {
        var idx = indexForId(id);
        var next = (list.currentIndex == idx ? list.currentIndex - 1 : list.currentIndex)
        next = (next<0) ? 0 : next
        mdiArea.closeView(list.model.get(next).item.viewID, id);
    }
    
    function nextView() {
        var next = (list.currentIndex < (list.model.count-1)) ? list.currentIndex + 1 : list.currentIndex
        list.currentIndex = next;
        mdiArea.currentID = list.model.get(next).item.viewID;
    }
    
    function previousView() {        
        var next = (list.currentIndex > 0) ? list.currentIndex - 1 : list.currentIndex
        list.currentIndex = next;
        mdiArea.currentID = list.model.get(next).item.viewID;
    }
}