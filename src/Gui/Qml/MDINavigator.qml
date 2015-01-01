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

Item {
    id: navigator
    default property alias model: list.model
    property int  tabwidth: 120
    property Item mdiArea
        
    height: 20
    width:  3*tabwidth
   
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    
    ListView {
        id: list
        highlightFollowsCurrentItem: true
        orientation: ListView.Horizontal 
        anchors.fill: parent
        delegate: Rectangle {
            width:  tabwidth
            height: 20
            color: "#600000FF"

            Text {
                width:  tabwidth
                height: 20
                elide: Text.ElideRight
                text: model.modelData.proxy.windowTitle
            }
            MouseArea {
                    anchors.fill: parent
                    onClicked: mdiArea.current = index
            }
        }
    }
    
    onModelChanged: console.debug("Mdi ListView model changed, count: ", list.model.count)
}