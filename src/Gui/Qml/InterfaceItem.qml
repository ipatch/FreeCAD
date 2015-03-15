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

FloatItem {
      
    id: interfaceitem
    //all children are added to the childarea by default
    default property alias content: interfaceitem.ccontent
    
    //shade stuff
    property bool shade: false
    property int  hShadeSize:0
    property int  wShadeSize: 0
    property bool autoShade: false
    property int  shadeDelay: 0
    property int  unshadeDelay: 0
    property bool shadeHor: false
    property int  shadeWidth: 0
    property bool shadeVer: true
    property int  shadeHeight: 0
     
    width:  200
    floatMode: 3
  
    Settings {
        id: settings
        trackedObject: interfaceitem.objectName
    }    
    
    controlsDelegate: Row {
        Button {
            width:  20
            height: 20
            id: menuButton
            icon: ":/icons/preferences-system.svg"
            
            onActivated: area.setSettingsMode(interfaceitem);
        }
        TitleButton{
            width:  20
            height: 20
            id: shadeButton
            styleIcon: shade ? TitleButton.Unshade : TitleButton.Shade
            
            onActivated: toggleShade();
        }
        TitleButton{
            width:  20
            height: 20
            id: closeButton
            styleIcon: TitleButton.Close
            
            onActivated: {
                if(interfaceitem.visible)
                    interfaceitem.show(false)
            }
        }
    }
        
    //let's save everything
    Component.onDestruction: {
        settings.setBool('visible', interfaceitem.visible)        
        settings.setBool('shade', interfaceitem.shade)
        settings.setInt('hShadeSize', interfaceitem.hShadeSize)
        settings.setInt('wShadeSize', interfaceitem.wShadeSize)
        settings.setBool('shadeHor', interfaceitem.shadeHor)
        settings.setBool('shadeVer', interfaceitem.shadeVer)
        settings.setInt('shadeHeight', interfaceitem.shadeHeight)
        settings.setInt('shadeWidth', interfaceitem.shadeWidth)
        settings.setBool('autoShade', interfaceitem.autoShade)
        settings.setInt('shadeDelay', interfaceitem.shadeDelay)
        settings.setInt('unshadeDelay', interfaceitem.unshadeDelay)
    }
    
    //signals that we want the interfaceiten context menu
    signal contextMenu();
    
    function setup() {
        interfaceitem.visible = settings.getBool('visible', false);
        interfaceitem.shade = settings.getBool('shade', false);
        interfaceitem.hShadeSize = settings.getInt('hShadeSize', 0);
        interfaceitem.wShadeSize = settings.getInt('wShadeSize', 0);
        interfaceitem.shadeHor = settings.getBool('shadeHor', false)
        interfaceitem.shadeVer = settings.getBool('shadeVer', true)
        interfaceitem.shadeHeight = settings.getInt('shadeHeight', 0)
        interfaceitem.shadeWidth= settings.getInt('shadeWidth', 0)        
        interfaceitem.autoShade = settings.getBool('autoShade', false)
        interfaceitem.shadeDelay = settings.getInt('shadeDelay', 0)
        interfaceitem.unshadeDelay = settings.getInt('unshadeDelay', 0)

        setupFloating()
    } 
    
    /*******************************************************************************************
     *                                          Shading
     * *****************************************************************************************/
    SequentialAnimation {
        id: shadeAnimation
        property alias toHeight: hanim.to
        property alias toWidth: wanim.to
        property alias delay: pause.duration;
        
        PauseAnimation { 
            id: pause
            duration: 0
        }
        ParallelAnimation {
            PropertyAnimation { 
                id:hanim            
                target: interfaceitem
                properties: 'height'
                to: 0
                duration: 200
                easing.type: Easing.InOutCubic
            }
            PropertyAnimation { 
                id:wanim            
                target: interfaceitem
                properties: 'width'
                to: 0
                duration: 200
                easing.type: Easing.InOutCubic
            }
        }
    }
    
    function setShade(sh) {
        if(shade != sh) {
            var running = shadeAnimation.running;
            shadeAnimation.stop()
            if(!shade) {
                if(!running || hShadeSize==0)
                    hShadeSize = interfaceitem.height;
                
                if(!running || wShadeSize==0)
                    wShadeSize = interfaceitem.width;
                
                if(shadeVer)
                    shadeAnimation.toHeight = titleBarHeight + interfaceitem.shadeHeight
                else
                    shadeAnimation.toHeight = hShadeSize
                        
                if(shadeHor)
                    shadeAnimation.toWidth  = /*buttons.width +*/ interfaceitem.shadeWidth
                else 
                    shadeAnimation.toWidth = wShadeSize
                
                if(autoShade)
                    shadeAnimation.delay = interfaceitem.shadeDelay
                else
                    shadeAnimation.delay = 0
                        
                shade = true;
            }
            else {
                shadeAnimation.toHeight = hShadeSize
                shadeAnimation.toWidth =  wShadeSize
                
                if(autoShade)
                    shadeAnimation.delay = interfaceitem.unshadeDelay;
                else
                    shadeAnimation.delay = 0
                shade = false;
            }        
            shadeAnimation.start()            
        }
    }
    
    function toggleShade() {
        setShade(!shade);
    }
    
    //auto shade stuff
    function onEnter() {
        if(autoShade) setShade(false);
    }
    function onLeave() {
        if(autoShade) setShade(true);
    }
       
    signal show(bool shw);
    
    SequentialAnimation {
        id: showanimation;
        property bool vis: true;
        
        PropertyAnimation {
            target: interfaceitem;
            property: "opacity";
            from: showanimation.vis ? 0 : 1;
            to: showanimation.vis ? 1 : 0;
        }
        PropertyAction {
            target: interfaceitem;
            property: "visible";
            value: showanimation.vis;
        }
        PropertyAction {
            target: interfaceitem;
            properties: "x,y";
            value: 300;
        }
        
        onRunningChanged: {
            
            //clear settings and all values if we got hidden
            if(!vis) {     
                console.debug("clear")
                settings.clear();
                interfaceitem.shade = false
                interfaceitem.hShadeSize = 0
                interfaceitem.wShadeSize = 0
                interfaceitem.shadeHor = false
                interfaceitem.shadeVer = true
                interfaceitem.shadeHeight = 0
                interfaceitem.shadeWidth= 0        
                interfaceitem.autoShade = false
                interfaceitem.shadeDelay = 0
                interfaceitem.unshadeDelay = 0  
                interfaceitem.x = 0
                interfaceitem.y = 0
                interfaceitem.width = interfaceitem.minWidth
                interfaceitem.height = interfaceitem.minHeight
                interfaceitem.hideTitlebar = false
            }
        }
    }        
        
    onShow: {
        //reset anchor, position and size state
        if(!shw) {
            removeActiveAnchors(true);
            removePassiveAnchors(true);
            removeActiveAnchors(false);
            removePassiveAnchors(false);
            setAnchorIndicator(false);
        }
        
        showanimation.vis = shw;
        showanimation.start();
    }
}