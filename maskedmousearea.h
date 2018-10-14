#ifndef MASKEDMOUSEAREA_H
#define MASKEDMOUSEAREA_H

#include <QImage>
#include <QQuickItem>


class MaskedMouseArea : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(bool pressed READ isPressed NOTIFY pressedChanged)
    Q_PROPERTY(bool containsMouse READ containsMouse NOTIFY containsMouseChanged)
    Q_PROPERTY(QObject* maskSource WRITE setMaskSource NOTIFY maskSourceChanged)
    Q_PROPERTY(qreal alphaThreshold READ alphaThreshold WRITE setAlphaThreshold NOTIFY alphaThresholdChanged)

public:
    MaskedMouseArea(QQuickItem *parent = 0);

    bool contains(const QPointF &point) const;

    bool isPressed() const { return m_pressed; }
    bool containsMouse() const { return m_containsMouse; }

    void setMaskSource(QObject *maskObject);

    qreal alphaThreshold() const { return m_alphaThreshold; }
    void setAlphaThreshold(qreal threshold);

    Q_INVOKABLE void resetMaskSource();
signals:
    void pressed();
    void released();
    void clicked();
    void canceled();
    void pressedChanged();
    void maskSourceChanged();
    void containsMouseChanged();
    void alphaThresholdChanged();

protected:
    void setPressed(bool pressed);
    void setContainsMouse(bool containsMouse);
    void mousePressEvent(QMouseEvent *event);
    void mouseReleaseEvent(QMouseEvent *event);
    void hoverEnterEvent(QHoverEvent *event);
    void hoverLeaveEvent(QHoverEvent *event);
    void mouseUngrabEvent();

private:
    bool m_pressed;
    QImage m_maskImage;
    QPointF m_pressPoint;
    qreal m_alphaThreshold;
    bool m_containsMouse;
};

#endif // MASKEDMOUSEAREA_H
