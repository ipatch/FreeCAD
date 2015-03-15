/***************************************************************************
 *   Copyright (c) 2015 Stefan Tröger <stefantroeger@gmx.net>              *
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


#include "PreCompiled.h"

#ifndef _PreComp_
# include <QRegExp>
# include <memory>
#endif

#include "DlgSettingsInterfaceImp.h"
#include "PrefWidgets.h"

using namespace Gui::Dialog;

DlgSettingsInterfaceImp::DlgSettingsInterfaceImp(QWidget* parent)
    : PreferencePage( parent )
{
    this->setupUi(this);
    connect(replaceMDI, SIGNAL(toggled(bool)), this, SLOT(replaceMDIToggled(bool)));
}

/** 
 *  Destroys the object and frees any allocated resources
 */
DlgSettingsInterfaceImp::~DlgSettingsInterfaceImp()
{
    // no need to delete child widgets, Qt does it all for us
}

void DlgSettingsInterfaceImp::saveSettings()
{
    backgroundColor->onSave();
    backgroundAlpha->onSave();
    replaceMDI->onSave();
    replaceDocker->onSave();
    dragMode->onSave();
    navigatorPosition->onSave();
}

void DlgSettingsInterfaceImp::loadSettings()
{
    backgroundColor->onRestore();
    backgroundAlpha->onRestore();
    replaceMDI->onRestore();
    replaceDocker->onRestore();
    dragMode->onRestore();
    navigatorPosition->onRestore();
    
    if(replaceMDI->isChecked()) {
        dragMode->setEnabled(true);
        navigatorPosition->setEnabled(true);
        replaceDocker->setEnabled(true);
    }
    else {
        replaceDocker->setChecked(false);
        dragMode->setEnabled(false);
        navigatorPosition->setEnabled(false);
        replaceDocker->setEnabled(false);
    }
    
    if(replaceDocker->isChecked())
        navigatorPosition->setEnabled(false);
}

void DlgSettingsInterfaceImp::changeEvent(QEvent* e)
{

}

void DlgSettingsInterfaceImp::replaceMDIToggled(bool value)
{
    if(!value) {
        replaceDocker->setChecked(false);
        navigatorPosition->setEnabled(false);
    }
}


#include "moc_DlgSettingsInterfaceImp.cpp"

