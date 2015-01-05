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


#ifndef GUI_QML_TYPES_H
#define GUI_QML_TYPES_H

#include "PreCompiled.h"
#include <QGraphicsProxyWidget>
#include <QDeclarativeItem>

namespace Gui {

class GuiExport QmlProxy : public QDeclarativeItem {
    
    Q_OBJECT;
    Q_PROPERTY(QWidget* proxy READ proxy WRITE setProxy)
  
public:
    QmlProxy(QDeclarativeItem* parent = 0);
    
    QWidget* proxy();
    void setProxy(QWidget*);
    
protected:
    virtual void geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry);
    
private:
    QGraphicsProxyWidget* m_proxy;
};


} // namespace Gui

#endif // GUI_MAINWINDOW_H
