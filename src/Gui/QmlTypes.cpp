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
#include "MainWindow.h"
#include "Application.h"

#include <QGraphicsSceneMouseEvent>
#include <QStyleOptionToolButton>
#include <QPainter>
#include <QApplication>

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
    m_proxy->setMinimumSize(QSize(0,0));
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

    opt.icon = MainWindow::getInstance()->style()->standardIcon(QStyle::StandardPixmap(m_styleIcon));
    opt.subControls = 0;
    opt.activeSubControls = 0;
    opt.features = QStyleOptionToolButton::None;
    opt.arrowType = Qt::NoArrow;
    opt.toolButtonStyle = Qt::ToolButtonIconOnly;
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

QmlMouseCursor::QmlMouseCursor(QDeclarativeItem* parent): QDeclarativeItem(parent)
{

}

Qt::CursorShape QmlMouseCursor::cursor()
{
    return m_current;
}

void QmlMouseCursor::setCursor(Qt::CursorShape c)
{
    m_current = c;
    QApplication::setOverrideCursor(QCursor(c));
}

QmlSettings::QmlSettings(): QObject()
{
    m_grp = NULL;
    m_tracked.clear();
}

QmlSettings::~QmlSettings()
{
    if(m_grp.isValid())
        m_grp->Detach(this);
}


void QmlSettings::setTrackedObject(QString s)
{
    m_tracked = s;
    if(m_grp.isValid())
        m_grp->Detach(this);
    
    QString path = QString::fromAscii("User parameter:BaseApp/MainWindow/GlobalInterface/") + s;
    m_grp = App::GetApplication().GetParameterGroupByPath(path.toStdString().c_str());
    m_grp->Attach(this);
}

QString QmlSettings::trackedObject()
{
    return m_tracked;
}

void QmlSettings::OnChange(Base::Subject< const char* >& rCaller, const char* rcReason)
{
    valueChanged(QString::fromAscii(rcReason));
}

void QmlSettings::setBool(QString Name, bool value)
{
    m_grp->SetBool(Name.toStdString().c_str(), value);
}

bool QmlSettings::getBool(QString Name, bool defaultvalue)
{
    return m_grp->GetBool(Name.toStdString().c_str(), defaultvalue);
}

void QmlSettings::setInt(QString Name, int value)
{
    m_grp->SetInt(Name.toStdString().c_str(), value);
}

int QmlSettings::getInt(QString Name, int defaultvalue)
{
    return m_grp->GetInt(Name.toStdString().c_str(), defaultvalue);
}

void QmlSettings::setString(QString Name, QString value)
{
    m_grp->SetASCII(Name.toStdString().c_str(), value.toStdString().c_str());
}

QString QmlSettings::getString(QString Name, QString defaultvalue)
{
    return QString::fromStdString(m_grp->GetASCII(Name.toStdString().c_str(), defaultvalue.toStdString().c_str()));
}

void QmlSettings::valueChanged(QString name){}



#include "moc_QmlTypes.cpp"