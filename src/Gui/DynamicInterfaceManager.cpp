/*
 * <one line to give the library's name and an idea of what it does.>
 * Copyright (C) 2015  Stefan Tröger <stefantroeger@gmx.net>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#include "DynamicInterfaceManager.h"

#include "Base/Console.h"
#include <QDeclarativeItem>
#include <QDeclarativeEngine>
#include <QMenu>
#include <QApplication>

using namespace Gui;

DynamicInterfaceManager::DynamicInterfaceManager() {
    m_view = NULL;
}

DynamicInterfaceManager::~DynamicInterfaceManager(){
    
}

QDeclarativeView* DynamicInterfaceManager::managedView()
{
    return m_view;
}

void DynamicInterfaceManager::setManagedView(QDeclarativeView* view)
{
    if(m_view)
        return;
    
    m_view = view;
    
    //some items are added to the qml files directly. process them here to ensure they work like
    //c++ added items
    QObject* nav = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("Navigator"));
    connect(nav, SIGNAL(contextMenu()), this, SLOT(interfaceitemContextMenu()));
    m_interfaceitems.push_back(qobject_cast<QDeclarativeItem*>(nav));
    
}

void DynamicInterfaceManager::addInterfaceItem(QWidget* widget, QString name, bool permanent)
{
    if(!m_view)
        return;
    
    widget->setParent(NULL);
    
    //create the component and set the view proxy
    QDeclarativeComponent* component = new QDeclarativeComponent(m_view->engine(), 
                                    QString::fromAscii("/home/stefan/Projects/FreeCAD_sf_master/src/Gui/Qml/InterfaceProxyItem.qml"));
    QDeclarativeItem* item = qobject_cast<QDeclarativeItem*>(component->create());
      
    //add proxy
    item->setProperty("proxy", QVariant::fromValue(widget));

    //make sure we can destroy it from within qml 
    if(!permanent)
        m_view->engine()->setObjectOwnership(item, QDeclarativeEngine::JavaScriptOwnership);
        
    //add it to the scene
    QObject* interface = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("Area"));
    if(interface) {
        item->setParentItem(qobject_cast<QDeclarativeItem*>(interface)); 
        item->setProperty("area", QVariant::fromValue(interface));    
    }
    else {
        Base::Console().Error("No interface area found, item can not be added to layout");
        return;
    } 
    
    //ensure a proper item size
    QObject* proxyItem = item->findChild<QObject*>(QString::fromAscii("proxy"));
    if(proxyItem) {
        proxyItem->setProperty("width", widget->width());
        proxyItem->setProperty("height", widget->height());
    }
    item->setProperty("minWidth", widget->minimumSizeHint().width());
    item->setProperty("minHeight", widget->minimumSizeHint().height());
    
    item->setProperty("title", widget->objectName());
    item->setObjectName(name);
    connect(item, SIGNAL(contextMenu()), this, SLOT(interfaceitemContextMenu()));
    
    //and change some view properties
    widget->setAttribute(Qt::WA_TranslucentBackground, true);
    
    m_interfaceitems.push_back(item);
}

QWidget* DynamicInterfaceManager::getInterfaceItem(QString objectname)
{
    if(!m_view)
        return NULL;
    
    QDeclarativeItem* item = NULL;
    for(QList<QDeclarativeItem*>::iterator it = m_interfaceitems.begin(); it!=m_interfaceitems.end(); ++it) {
        if((*it)->objectName() == objectname) {
            item = *it;
            break;
        }
    }
    
    if(!item) {
        Base::Console().Message("no item with name %s\n", objectname.toStdString().c_str());
        return NULL;
    }
    
    QVariant proxy = item->property("proxy");    
    if(!proxy.isValid()) {
        Base::Console().Message("no valid proxy\n");
        return NULL;
    }
    
    return proxy.value<QWidget*>();
}

void DynamicInterfaceManager::setupInterfaceItems()
{
    QObject* interface = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("Area"));
    QMetaObject::invokeMethod(interface, "loadSettings");
}

QList< QAction* > DynamicInterfaceManager::getInterfaceItemToggleActions()
{
    QList< QAction* > list;
    for(QList<QDeclarativeItem*>::iterator it = m_interfaceitems.begin(); it!=m_interfaceitems.end(); ++it) {

        QAction* act = new QAction((*it)->property("title").toString(), NULL);
        act->setCheckable(true);
        act->setChecked((*it)->property("visible").value<bool>());
        connect(act, SIGNAL(toggled(bool)), *it, SLOT(show(bool)));
        
        act->setToolTip(tr("Toggles this interface item"));
        act->setStatusTip(tr("Toggles this interface item"));
        act->setWhatsThis(tr("Toggles this interface item"));
        act->setData(QVariant::fromValue(*it));
        
        list.push_back(act);
    }

    QAction* act = new QAction(tr("Show all title bars"), NULL);
    act->setToolTip(tr("Show all titlebars ignoring the individual setting"));    
    QObject* interface = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("Area"));
    connect(act, SIGNAL(toggled(bool)), interface, SLOT(showAllTitlebars(bool)));
    act->setCheckable(true);
    act->setChecked(interface->property("allTitlebars").value<bool>());
    
    list.push_back(act);
    
    return list;
}

QMenu* DynamicInterfaceManager::getInterfaceItemContextMenu()
{
    QMenu* menu = new QMenu();
    QList<QAction*> list = GlobalDynamicInterfaceManager::get()->getInterfaceItemToggleActions();
    Q_FOREACH(QAction* action, list) {
        action->setParent(menu);
        menu->addAction(action);
    }
    
    return menu;
}


void DynamicInterfaceManager::interfaceitemContextMenu()
{
    QMenu* menu = getInterfaceItemContextMenu();
    menu->exec(QCursor::pos());
}




GlobalDynamicInterfaceManager* GlobalDynamicInterfaceManager::instance = NULL;

GlobalDynamicInterfaceManager::GlobalDynamicInterfaceManager(){}
GlobalDynamicInterfaceManager::~GlobalDynamicInterfaceManager(){
    if(m_view) {
        QObject* mdiview = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("mdiarea"));
        disconnect(mdiview, SIGNAL(viewActivated(QVariant)), this, SLOT(activate(QVariant)));
    }
}

void GlobalDynamicInterfaceManager::setManagedView(QDeclarativeView* view)
{
    Gui::DynamicInterfaceManager::setManagedView(view);
    //connect the view signals
    QObject* mdiview = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("mdiarea"));
    connect(mdiview, SIGNAL(viewActivated(QVariant)), this, SLOT(activate(QVariant)));
}

GlobalDynamicInterfaceManager* GlobalDynamicInterfaceManager::get()
{
    if(!instance)
        instance = new GlobalDynamicInterfaceManager;
    
    return instance;
}

void GlobalDynamicInterfaceManager::addView(MDIView* view)
{
    //create the component and set the view proxy
    QDeclarativeComponent* component = new QDeclarativeComponent(m_view->engine(), 
                                         QString::fromAscii("/home/stefan/Projects/FreeCAD_sf_master/src/Gui/Qml/MDIView.qml"));
    QDeclarativeItem* item = qobject_cast<QDeclarativeItem*>(component->create());
    item->setProperty("proxy", QVariant::fromValue(static_cast<QWidget*>(view)));
   
    //make sure we can destroy it from within qml. This is a workaround for giving the ownership to 
    //javascript as this randomly destroyed the view when dragging interfaceitems.
    connect(item, SIGNAL(requestDestroy(QVariant)), this, SLOT(destroy(QVariant)));
        
    //add it to the scene
    QObject* mdiview = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("mdiarea"));
    if(mdiview) {
        item->setParentItem(qobject_cast<QDeclarativeItem*>(mdiview)); 
    }
    else {
        Base::Console().Error("No mdiview found, view can not be added to layout");
        return;
    } 
    m_views.push_back(item);
}

void GlobalDynamicInterfaceManager::closeView(MDIView* view)
{
    Base::Console().Message("remove Windwow\n");
}

QList< MDIView* > GlobalDynamicInterfaceManager::views()
{
    QList< MDIView* > list;
    Q_FOREACH(QDeclarativeItem* item, m_views) {
        list.push_back(static_cast<MDIView*>(item->property("proxy").value<QWidget*>()));
    }
    return list;
}


void GlobalDynamicInterfaceManager::destroy(QVariant item)
{
    item.value<QObject*>()->disconnect();
    item.value<QObject*>()->deleteLater();
    m_views.removeAll(static_cast<QDeclarativeItem*>(item.value<QObject*>()));
}

void GlobalDynamicInterfaceManager::activate(QVariant item)
{
    if(item.isValid())
        Q_EMIT viewActivated(static_cast<MDIView*>(item.value<QObject*>()->property("proxy").value<QWidget*>()));
}

void GlobalDynamicInterfaceManager::activateView(MDIView* view)
{
    int c = 0;
    QObject* mdiview = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("mdiarea"));
    Q_FOREACH(QDeclarativeItem* item, m_views) {
        if(static_cast<MDIView*>(item->property("proxy").value<QWidget*>()) == view) {
            QMetaObject::invokeMethod(mdiview, "activateView", Q_ARG(QVariant, c));
        }
         
        ++c;
    }
}


void GlobalDynamicInterfaceManager::closeActiveView()
{
    QObject* mdiview = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("mdiarea"));
    QMetaObject::invokeMethod(mdiview, "closeActiveView");
}

void GlobalDynamicInterfaceManager::activateNextView()
{
    QObject* mdiview = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("mdiarea"));
    QMetaObject::invokeMethod(mdiview, "activateNextView");
}

void GlobalDynamicInterfaceManager::activatePreviousView()
{
    QObject* mdiview = m_view->rootObject()->findChild<QObject*>(QString::fromAscii("mdiarea"));
    QMetaObject::invokeMethod(mdiview, "activatePreviousView");
}


#include "moc_DynamicInterfaceManager.cpp"