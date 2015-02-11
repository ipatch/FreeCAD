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

import QtQuick 1.0

Item {
    id: mdiarea
        
    property int current: 0
    property Item nav
    
    onCurrentChanged: {
        viewActivated(mdiarea.children[current])
        setVisibilities()
    }
    
    Component.onCompleted: setVisibilities()

    function setVisibilities() {
        for (var i = 0; i < mdiarea.children.length; ++i) {
            mdiarea.children[i].visible = (i == current ? true : false)
        }
    }
    
    signal viewActivated(variant item);

    clip: true
    
    function activateView(id) {
        current = id
        nav.index = id
    }
    
    function closeView(next, id) {
        current = next
        nav.index = next
        var item = children[id]
        item.parent = nav  //just need to reparent to update model first, no matter who parent is
        item.requestDestroy(item)
    }
    
    function closeAciveView() {
    
        var next = (current == (children.length-1)) ? current - 1 : current
        next = (next<0) ? 0 : next
        closeView(next, current);
    }
    
    function activateNextView() {
    
        var next = (current < (children.length-1)) ? current + 1 : current
        nav.index = next;
        current = next;
    }
    
    function activatePreviousView() {
        
        var next = (current > 0) ? current - 1 : current
        nav.index = next;
        current = next;
    }
}
