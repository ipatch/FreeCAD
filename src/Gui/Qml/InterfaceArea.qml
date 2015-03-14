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

FloatArea {
    id: interfaceArea
    anchors.margins: 3;
   
    //interfaceitem menu area 
    Rectangle {
        id:menu
        visible: false
        color: "#99000000"
        anchors.fill: parent
        z:9999
        
        property alias item: itemSettings.item
        
        //block all mouse events to prevent interaction with the background items
        MouseArea {
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            anchors.fill: parent
        }
        
        Item {
            anchors.centerIn: parent
            width: 400
            height: 250
            ItemSettings {
                id: itemSettings;
                anchors.fill: parent
                
                onAccepted: menu.show(false);
                onRejected: menu.show(false);
            }
        }
        
        function show(show) {
            menuAnimation.stop();
            menuAnimation.hide = !show;
            menuAnimation.start();
        }
        
        SequentialAnimation {
            
            id: menuAnimation
            property bool hide: true
            
            PropertyAction {
                target: menu
                property: 'visible'
                value: true
            }
            PropertyAnimation {
                target: menu
                property: 'opacity'
                from: menuAnimation.hide ? 1 : 0
                to: menuAnimation.hide ? 0 : 1
            }
            PropertyAction {
                target: menu
                property: 'visible'
                value: !menuAnimation.hide
            }
        }
    }
       
    function setSettingsMode(item) {
        menu.item = item;
        menu.show(true)
    }
    
    function loadSettings() {
        
        for(var i=0; i<interfaceArea.children.length; ++i) {
            if('setup' in interfaceArea.children[i])
                interfaceArea.children[i].setup();
        }
        for(var i=0; i<interfaceArea.children.length; ++i) {
            if('setupAnchors' in interfaceArea.children[i]) {
                interfaceArea.children[i].setupAnchors();
            }
        }
    }
}
