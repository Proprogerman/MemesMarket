#include "imageprovider.h"
#include <QDebug>

ImageProvider::ImageProvider(): QQuickImageProvider(QQuickImageProvider::Pixmap)
{
    qDebug()<<"IMAGE PROVIDER CONSTRUCTOR";
}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug()<<"IMAGE PROVIDER REQUEST PIXMAP --------- "<<"C:/Development/clientImages/" + id;
    QPixmap result;
    result.load("C:/Development/clientImages/" + id);
    return result;
}

