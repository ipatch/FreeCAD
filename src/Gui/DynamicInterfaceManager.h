/***************************************************************************
 *   Copyright (c) 2015 Stefan Troeger <stefantroeger@gmx.net>             *
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

#ifndef GUI_DYNAMICINTERFACEMANAGER_H
#define GUI_DYNAMICINTERFACEMANAGER_H

#include "PreCompiled.h"

#include "MDIView.h"
#include <QDeclarativeView>

namespace Gui {
    
class GuiExport DynamicInterfaceManager : public QObject
{
    Q_OBJECT
    
public:
    enum Position {
        Bottom = 0,
        Top,
        Left,
        Right,
    };
    
    DynamicInterfaceManager();
    ~DynamicInterfaceManager();
    
    QDeclarativeView* managedInterfaceViewer();
    virtual void setManagedInterfaceViewer(QDeclarativeView* view);
    
    void addInterfaceItem(QWidget* widget, QString name, bool permanent = false);
    QWidget* getInterfaceItem(QString objectname);
    void setupInterfaceItems();    
    void positionInterfaceItem(QString name, Position pos);
    
    QList<QAction*> getInterfaceItemToggleActions();
    QMenu*          getInterfaceItemContextMenu();
    
    bool interfaceActivated();
    bool hasInterfaceItems();
    
public Q_SLOTS:
    void interfaceitemContextMenu();
    
protected:
    QDeclarativeView* m_view;
    QList<QDeclarativeItem*> m_interfaceitems;
    bool m_interfaceActivated;
};

//Singleton for the global user interface
class GuiExport GlobalDynamicInterfaceManager : public DynamicInterfaceManager {
  
    Q_OBJECT
    
public:
    static GlobalDynamicInterfaceManager* get();
    
    QDeclarativeView* managedViewViewer();
    virtual void setManagedViewViewer(QDeclarativeView* view);
    
    void addView(MDIView* view);
    void closeView(MDIView* view);
    
    QList<MDIView*> views();
    void activateView(MDIView* view);
    void activateNextView();
    void activatePreviousView();
    void closeActiveView();
    
    void setNavigatorFixed(Position pos);
    bool hasViews();
    bool viewsActivated();
    
Q_SIGNALS:
    void viewActivated(MDIView*);
    
public Q_SLOTS:
    //destroy cpp items
    void destroy(QVariant item);
    //activated MDIView
    void activate(QVariant item);
    
private:    
    GlobalDynamicInterfaceManager();
    ~GlobalDynamicInterfaceManager();
    
    static GlobalDynamicInterfaceManager* instance;
    QList<QDeclarativeItem*> m_views;
    bool m_viewsActivated;
    
};

}//Gui

#endif // GUI_DYNAMICINTERFACEMANAGER_H
