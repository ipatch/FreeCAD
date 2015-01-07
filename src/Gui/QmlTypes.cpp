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

#include "QmlTypes.h"
#include "BitmapFactory.h"

#include <QStyle>
#include <QGraphicsSceneMouseEvent>
#include <QStyleOptionToolButton>
#include <QPainter>

using namespace Gui;


QmlProxy::QmlProxy(QDeclarativeItem* parent): QDeclarativeItem(parent)
{
    m_proxy = new QGraphicsProxyWidget(this);
}

QWidget* QmlProxy::proxy()
{
    return m_proxy->widget();
}

void QmlProxy::setProxy(QWidget* w)
{
    m_proxy->setWidget(w);
}

void QmlProxy::geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry)
{
    m_proxy->setGeometry(newGeometry);
    QDeclarativeItem::geometryChanged(newGeometry, oldGeometry);
}

QmlButton::QmlButton(QDeclarativeItem* parent) : QDeclarativeItem(parent),
    hovered(false), pressed(false), m_margin(0)
{
    setFlag(QGraphicsItem::ItemHasNoContents, false);
    setAcceptedMouseButtons(Qt::LeftButton);
    setAcceptHoverEvents(true);
}

bool QmlButton::isHoverd()
{
    return hovered;
}

bool QmlButton::isPressed()
{
    return pressed;
}


void QmlButton::paint(QPainter* p, const QStyleOptionGraphicsItem* op, QWidget* w)
{

    QStyleOptionToolButton opt;
    opt.initFrom(w);
    opt.rect = QRect(QPoint(m_margin, m_margin), QSize(op->rect.size()-QSize(2*m_margin,2*m_margin)));
    opt.state = QStyle::State_AutoRaise | op->state;

     
    if(isHoverd() && !isPressed()) {
        opt.state |= QStyle::State_Raised;
    }

    if(isPressed()) {
        opt.state |= QStyle::State_Sunken;
    }

    w->style()->drawPrimitive(QStyle::PE_PanelButtonTool, &opt, p, w);
 
    opt.icon = BitmapFactory().pixmap(m_icon.toStdString().c_str());
    opt.subControls = 0;
    opt.activeSubControls = 0;
    opt.features = QStyleOptionToolButton::None;
    opt.arrowType = Qt::NoArrow;
    int size = w->style()->pixelMetric(QStyle::PM_SmallIconSize, 0, w);
    size -= 2;
    opt.iconSize = QSize(size, size);
    w->style()->drawComplexControl(QStyle::CC_ToolButton, &opt, p, w);
}

void QmlButton::hoverEnterEvent(QGraphicsSceneHoverEvent* event)
{
    hovered = true;
    this->update();
}

void QmlButton::hoverLeaveEvent(QGraphicsSceneHoverEvent* event)
{
    hovered = false;
    this->update();
}

void QmlButton::mousePressEvent(QGraphicsSceneMouseEvent* event)
{
    pressed = true;
    update();
    event->accept();
}

void QmlButton::mouseReleaseEvent(QGraphicsSceneMouseEvent* event)
{
    if(hovered)
        activated();
    
    pressed = false;
    event->accept();
    update();
}

QmlTitleButton::QmlTitleButton(QDeclarativeItem* parent) : QmlButton(parent)
{

}

void QmlTitleButton::paint(QPainter* p, const QStyleOptionGraphicsItem* op, QWidget* w)
{
    QStyleOptionToolButton opt;
    opt.initFrom(w);
    opt.rect = QRect(QPoint(m_margin, m_margin), QSize(op->rect.size()-QSize(2*m_margin,2*m_margin)));
    opt.state = QStyle::State_AutoRaise | op->state;

    if(w->style()->styleHint(QStyle::SH_DockWidget_ButtonsHaveFrame, 0, w))
    {
        
        if(isHoverd() && !isPressed()) {
            opt.state |= QStyle::State_Raised;
        }

        if(isPressed()) {
            opt.state |= QStyle::State_Sunken;
        }

        w->style()->drawPrimitive(QStyle::PE_PanelButtonTool, &opt, p, w);
    }

    opt.icon = w->style()->standardIcon(QStyle::SP_TitleBarCloseButton);
    opt.subControls = 0;
    opt.activeSubControls = 0;
    opt.features = QStyleOptionToolButton::None;
    opt.arrowType = Qt::NoArrow;
    int size = w->style()->pixelMetric(QStyle::PM_SmallIconSize, 0, w);
    opt.iconSize = QSize(size, size);
    w->style()->drawComplexControl(QStyle::CC_ToolButton, &opt, p, w);
}

QmlIcon::QmlIcon(QDeclarativeItem* parent): QDeclarativeItem(parent)
{
    setFlag(QGraphicsItem::ItemHasNoContents, false);
}

void QmlIcon::paint(QPainter* p, const QStyleOptionGraphicsItem* op, QWidget* w)
{
    m_icon.paint(p, op->rect);
}



#include "moc_QmlTypes.cpp"