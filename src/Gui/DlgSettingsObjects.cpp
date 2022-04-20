/****************************************************************************
 *   Copyright (c) 2021 Zheng Lei (realthunder) <realthunder.dev@gmail.com> *
 *                                                                          *
 *   This file is part of the FreeCAD CAx development system.               *
 *                                                                          *
 *   This library is free software; you can redistribute it and/or          *
 *   modify it under the terms of the GNU Library General Public            *
 *   License as published by the Free Software Foundation; either           *
 *   version 2 of the License, or (at your option) any later version.       *
 *                                                                          *
 *   This library  is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of         *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the          *
 *   GNU Library General Public License for more details.                   *
 *                                                                          *
 *   You should have received a copy of the GNU Library General Public      *
 *   License along with this library; see the file COPYING.LIB. If not,     *
 *   write to the Free Software Foundation, Inc., 59 Temple Place,          *
 *   Suite 330, Boston, MA  02111-1307, USA                                 *
 *                                                                          *
 ****************************************************************************/

#include "PreCompiled.h"

/*[[[cog
import DlgSettingsObjects
DlgSettingsObjects.define()
]]]*/

#ifndef _PreComp_
#   include <QApplication>
#   include <QLabel>
#   include <QGroupBox>
#   include <QGridLayout>
#   include <QVBoxLayout>
#endif
#include <Gui/PrefWidgets.h>
#include "DlgSettingsObjects.h"
#include <App/GroupParams.h>

using namespace Gui::Dialog;

/* TRANSLATOR Gui::Dialog::DlgSettingsObjects */

DlgSettingsObjects::DlgSettingsObjects(QWidget* parent)
    : PreferencePage( parent )
{

    auto layout = new QVBoxLayout(this);
    // Auto generated code. See class document of DlgSettingsObjects.
    groupGroupObjects = new QGroupBox(this);
    auto layoutGroupObjects = new QGridLayout(groupGroupObjects);
    layout->addWidget(groupGroupObjects);
    // Auto generated code. See class document of DlgSettingsObjects.
    checkBoxClaimAllChildren = new Gui::PrefCheckBox(this);
    layoutGroupObjects->addWidget(checkBoxClaimAllChildren, 0, 0);
    checkBoxClaimAllChildren->setChecked(true);
    checkBoxClaimAllChildren->setEntryName("ClaimAllChildren");
    checkBoxClaimAllChildren->setParamGrpPath("Group");
    // Auto generated code. See class document of DlgSettingsObjects.
    checkBoxKeepHiddenChildren = new Gui::PrefCheckBox(this);
    layoutGroupObjects->addWidget(checkBoxKeepHiddenChildren, 1, 0);
    checkBoxKeepHiddenChildren->setChecked(true);
    checkBoxKeepHiddenChildren->setEntryName("KeepHiddenChildren");
    checkBoxKeepHiddenChildren->setParamGrpPath("Group");
    // Auto generated code. See class document of DlgSettingsObjects.
    checkBoxExportChildren = new Gui::PrefCheckBox(this);
    layoutGroupObjects->addWidget(checkBoxExportChildren, 2, 0);
    checkBoxExportChildren->setChecked(true);
    checkBoxExportChildren->setEntryName("ExportChildren");
    checkBoxExportChildren->setParamGrpPath("Group");
    // Auto generated code. See class document of DlgSettingsObjects.
    checkBoxCreateOrigin = new Gui::PrefCheckBox(this);
    layoutGroupObjects->addWidget(checkBoxCreateOrigin, 3, 0);
    checkBoxCreateOrigin->setChecked(false);
    checkBoxCreateOrigin->setEntryName("CreateOrigin");
    checkBoxCreateOrigin->setParamGrpPath("Group");
    layout->addItem(new QSpacerItem(40, 20, QSizePolicy::Fixed, QSizePolicy::Expanding));
    retranslateUi();
}

DlgSettingsObjects::~DlgSettingsObjects()
{
}


void DlgSettingsObjects::saveSettings()
{
    // Auto generated code. See class document of DlgSettingsObjects.
    checkBoxClaimAllChildren->onSave();
    checkBoxKeepHiddenChildren->onSave();
    checkBoxExportChildren->onSave();
    checkBoxCreateOrigin->onSave();
}

void DlgSettingsObjects::loadSettings()
{
    // Auto generated code. See class document of DlgSettingsObjects.
    checkBoxClaimAllChildren->onRestore();
    checkBoxKeepHiddenChildren->onRestore();
    checkBoxExportChildren->onRestore();
    checkBoxCreateOrigin->onRestore();
}

void DlgSettingsObjects::retranslateUi()
{
    // Auto generated code. See class document of DlgSettingsObjects.
    setWindowTitle(QObject::tr("Objects"));
    groupGroupObjects->setTitle(QObject::tr("Group objects"));
    checkBoxClaimAllChildren->setText(QObject::tr("Claim all children"));
    checkBoxClaimAllChildren->setToolTip(QApplication::translate(
                                    "GroupParams",
                                    App::GroupParams::docClaimAllChildren()));
    checkBoxKeepHiddenChildren->setText(QObject::tr("Remember hidden children"));
    checkBoxKeepHiddenChildren->setToolTip(QApplication::translate(
                                    "GroupParams",
                                    App::GroupParams::docKeepHiddenChildren()));
    checkBoxExportChildren->setText(QObject::tr("Export children by visibility"));
    checkBoxExportChildren->setToolTip(QApplication::translate(
                                    "GroupParams",
                                    App::GroupParams::docExportChildren()));
    checkBoxCreateOrigin->setText(QObject::tr("Always create origin features in origin group"));
    checkBoxCreateOrigin->setToolTip(QApplication::translate(
                                    "GroupParams",
                                    App::GroupParams::docCreateOrigin()));
}

void DlgSettingsObjects::changeEvent(QEvent *e)
{
    // Auto generated code. See class document of DlgSettingsObjects.
    if (e->type() == QEvent::LanguageChange) {
        retranslateUi();
    }
    else {
        QWidget::changeEvent(e);
    }
}

#include "moc_DlgSettingsObjects.cpp"
//[[[end]]]
