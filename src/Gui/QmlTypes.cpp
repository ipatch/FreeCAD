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


QmlProxy::QmlProxy(QDeclarativeItem* parent): QDeclarativeItem(parent), m_mimicCursor(false)
{
    m_proxy = new QGraphicsProxyWidget(this);
    m_proxy->installEventFilter(this);
    m_partialSizeHint = QRect(-1,-1,0,0);
}

QWidget* QmlProxy::proxy()
{
    return m_proxy->widget();
}

void QmlProxy::setProxy(QWidget* w)
{
    m_proxy->setWidget(w);
    w->installEventFilter(this);
    m_proxy->setMinimumSize(QSize(0,0));
    Q_FOREACH(QObject* obj, m_proxy->children()) {
        if(obj->isWidgetType())
            static_cast<QWidget*>(obj)->setMinimumSize(QSize(0,0));
    }
    
    //check if we have a partialSize signal and connect to it when possible
    if(w->metaObject()->indexOfSignal("partialSizeHint(QRectF)") >= 0) {
        connect(w, SIGNAL(partialSizeHint(QRectF)), this, SLOT(setPartialSizeHint(QRectF)));       
        QMetaObject::invokeMethod(w, "calculatePartialSize");
    }
}

void QmlProxy::geometryChanged(const QRectF& newGeometry, const QRectF& oldGeometry)
{
    //respect partial size hints
    QRectF ng = newGeometry;
    if(m_partialSizeHint.x() >= 0) 
        ng.setWidth(std::min(ng.width(), m_partialSizeHint.width()));
    if(m_partialSizeHint.y() >= 0) 
        ng.setHeight(std::min(ng.height(), m_partialSizeHint.height()));   

    //setting the geometry directly created problems with the hover and selection events
    m_proxy->setMaximumSize(ng.size());
    m_proxy->setMinimumSize(ng.size());
    
    QDeclarativeItem::geometryChanged(newGeometry, oldGeometry);  
}

bool QmlProxy::eventFilter(QObject* o, QEvent* e)
{
    if((e->type() == QEvent::CursorChange) && m_mimicCursor) {
        setCursor(proxy()->cursor());
    }
    if(e->type() == QEvent::GraphicsSceneHoverEnter)
        Q_EMIT enter();
    if(e->type() == QEvent::GraphicsSceneHoverLeave)
        Q_EMIT leave();
      
    return false;
}

void QmlProxy::setPartialSizeHint(QRectF hint)
{    
    m_partialSizeHint = hint;
    geometryChanged(QRect(0, 0, width(), height()), QRect(0, 0, width(), height()));
}

bool QmlProxy::mimicCursor() {
    return m_mimicCursor;
}

void QmlProxy::setMimicCursor(bool onoff) {
    m_mimicCursor = onoff;
}

QmlHoverItem::QmlHoverItem(QDeclarativeItem* parent) : QDeclarativeItem(parent) 
{
    setAcceptHoverEvents(true);
}

void QmlHoverItem::hoverEnterEvent(QGraphicsSceneHoverEvent* event)
{
    Q_EMIT enter();
    QGraphicsItem::hoverEnterEvent(event);
}

void QmlHoverItem::hoverLeaveEvent(QGraphicsSceneHoverEvent* event)
{
    Q_EMIT leave();
    QGraphicsItem::hoverLeaveEvent(event);
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

Qt::CursorShape QmlMouseCursor::cursorShape()
{
    return m_current;
}

void QmlMouseCursor::setCursorShape(Qt::CursorShape c)
{
    m_current = c;
    setCursor(QCursor(c));
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

QString QmlSettings::tracked()
{
    return m_tracked;
}

void QmlSettings::setTrackedPreference(QString s)
{
    m_tracked = s;
    if(m_grp.isValid())
        m_grp->Detach(this);
    
    QString path = QString::fromAscii("User parameter:BaseApp/Preferences/") + s;
    m_grp = App::GetApplication().GetParameterGroupByPath(path.toStdString().c_str());
    m_grp->Attach(this);
}


void QmlSettings::OnChange(Base::Subject< const char* >& rCaller, const char* rcReason)
{
    Q_EMIT valueChanged(QString::fromAscii(rcReason));
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

QVector3D QmlSettings::getColor(QString name, QString defaultvalue)
{
    QColor color(defaultvalue);
    unsigned long text = (color.red() << 24) | (color.green() << 16) | (color.blue() << 8);
    unsigned long background = m_grp->GetUnsigned(name.toStdString().c_str(),text); // default color (white)
    int r,g,b;
    r = ((background >> 24) & 0xff);
    g = ((background >> 16) & 0xff);
    b = ((background >> 8) & 0xff);
    return QVector3D(r, g, b);
}

void QmlSettings::setColor(QString name, QString value)
{
    QColor color(value);
    unsigned long text = (color.red() << 24) | (color.green() << 16) | (color.blue() << 8);
    m_grp->SetUnsigned(name.toStdString().c_str(), text);
}


QmlInterfaceItemSettings::QmlInterfaceItemSettings(): QmlProxy(), m_item(NULL)
{
    QWidget* w = new QWidget(NULL);
    ui.setupUi(w);
    setProxy(w);
    
    connect(ui.buttons, SIGNAL(accepted()), this, SLOT(onButtonAccepted()));
    connect(ui.buttons, SIGNAL(rejected()), this, SLOT(onButtonRejected()));
    
}

QObject* QmlInterfaceItemSettings::item()
{
    return m_item;
}

void QmlInterfaceItemSettings::setItem(QObject* o) 
{
    m_item = o;
    ui.titleBar->setChecked(m_item->property("hideTitlebar").value<bool>());    
    ui.autoShade->setChecked(m_item->property("autoShade").value<bool>());  
    ui.shadeDelay->setValue(m_item->property("shadeDelay").value<int>());  
    ui.unshadeDelay->setValue(m_item->property("unshadeDelay").value<int>());  
    ui.shadeHor->setChecked(m_item->property("shadeHor").value<bool>());
    ui.shadeWidth->setValue(m_item->property("shadeWidth").value<int>());
    ui.shadeVer->setChecked(m_item->property("shadeVer").value<bool>());
    ui.shadeHeight->setValue(m_item->property("shadeHeight").value<int>());
}

void QmlInterfaceItemSettings::onButtonAccepted()
{
    m_item->setProperty("hideTitlebar", ui.titleBar->isChecked());
    m_item->setProperty("autoShade", ui.autoShade->isChecked());
    m_item->setProperty("shadeDelay", ui.shadeDelay->value());
    m_item->setProperty("unshadeDelay", ui.unshadeDelay->value());    
    m_item->setProperty("shadeHor", ui.shadeHor->isChecked());
    m_item->setProperty("shadeWidth", ui.shadeWidth->value());
    m_item->setProperty("shadeVer", ui.shadeVer->isChecked());
    m_item->setProperty("shadeHeight", ui.shadeHeight->value());
    
    Q_EMIT accepted();
}

void QmlInterfaceItemSettings::onButtonRejected()
{
    Q_EMIT rejected();
}

#include "moc_QmlTypes.cpp"