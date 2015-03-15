/***************************************************************************
 *   Copyright (c) 2015 StefanTroeger <stefantroeger@gmx.net>              *
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
    id: floatArea
    property bool allTitlebars: false   
    
    Item {
        id: fixItem 
        width:  0
        height: 0
    }
    
    Item {
        id: dragItem 
        width:  0
        height: 0
    }
    
    Rectangle {
        id: tileIndicator
        color: "#EEEEEEEE"
        border.width: 2
        border.color: "#AAAAAAAA"
        radius: 5
        z:999999
    }
       
    function setupFloatItem(item) {
        item.resizeDragItem    = dragItem;
        item.resizeFixItem     = fixItem;
        item.tileIndicatorItem = tileIndicator;
    }
      
    signal showAllTitlebars(bool satb)
    
    onShowAllTitlebars: {
        floatArea.allTitlebars = satb;
        for(var i=0; i<floatArea.children.length; ++i) {
            
            if('overrideHideToolbar' in floatArea.children[i])
                floatArea.children[i].overrideHideToolbar = satb
        }
    }
}
