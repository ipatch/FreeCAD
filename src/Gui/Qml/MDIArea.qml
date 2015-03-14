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

FloatArea {
    id: mdiarea
    property alias views: viewModel
    property int   currentID: 0
    property int   uniqueID: 0
    property Item nav
    
    anchors.margins: 0
    
    ListModel {
        id: viewModel
    }
    
    onCurrentIDChanged: {
        viewActivated(viewForID(currentID).proxy)
        setVisibilities()
    }
    
    onChildrenChanged: {
        //fill up the model
        viewModel.clear();               
        for(var i=0; i<mdiarea.children.length; ++i) {
            var child = mdiarea.children[i];
            if(child["viewID"] != undefined)
                viewModel.append({item:child})
        }
        
        //sort the model as the children may be shifted in position
        var n;
        var i;
        for (n=0; n < viewModel.count; n++) {            
            for (i=n+1; i < viewModel.count; i++) {                
                if (viewModel.get(n).item.viewID > viewModel.get(i).item.viewID){
                    viewModel.move(i, n, 1);
                    n=0; // Repeat at start since I can't swap items i and n
                }
            }
        }
    }
    
    Component.onCompleted: setVisibilities()
    
    function viewForID(id) {
        
        for (var i = 0; i < views.count; ++i) {
            if(views.get(i).item.viewID == id)
                return views.get(i).item
        }
        return undefined
    }
    
    function setVisibilities() {
       
        if( views.count == 0 )
            return
            
        var currentItem = viewForID(currentID);
        
        var backwards = views.count;
        var forwards = 0;
        //keep a backward slot open if the currentID item is floating
        if(currentItem.floating)
            --backwards
        
        //reorder all views
        var toplevelFull = -1
        for (var i = 0; i < views.count; ++i) {
            if(views.get(i).item.floating && (views.get(i).item.viewID != currentID)) {
                views.get(i).item.z = backwards--
                views.get(i).item.visible = true
            }
            else if(views.get(i).item.viewID != currentID) {                
                views.get(i).item.z = forwards++
                views.get(i).item.visible = false
                toplevelFull = i
            }
        }
        //now make the currentID view visible, toplevel if floating and toplevel of all non-floting else
        if(currentItem.floating) {
            currentItem.z = views.count;
            currentItem.visible = true
            views.get(toplevelFull).item.visible = true
        }
        else {
            currentItem.z = forwards++
            currentItem.visible = true
        }
    }
    
    signal viewActivated(variant item);

    clip: true
    
    function activateView(id) {
        console.debug("activateView called")
        currentID = id
        nav.index = nav.indexForId(id)
    }
    
    function closeView(next, id) {
        currentID = next
        nav.index = next
        var item = viewForID(id)
        item.parent = nav  //just need to reparent to update model first, no matter who parent is
        item.requestDestroy(item)
    }
    
    function closeAciveView() {
    
        var next = (currentID == (children.length-1)) ? currentID - 1 : currentID
        next = (next<0) ? 0 : next
        closeView(next, currentID);
    }
    
    function activateNextView() {    
        mdiarea.nav.nextView();
    }
    
    function activatePreviousView() {
        mdiarea.nav.previousView();
    }
    
    function toggleFloat(id) {
        var view = viewForID(id)
        if( !view.floating ) {
            view.anchors.fill = undefined
            view.x = 100
            view.y = 100
            view.height = 400
            view.width  = 400
            view.floating = true
        }
        else {
            view.anchors.fill = mdiarea
            view.floating = false
        }
        setVisibilities()
    }
}
