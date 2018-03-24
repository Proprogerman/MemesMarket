#include "imageprovider.h"
#include <QDebug>

ImageProvider::ImageProvider(): QQuickImageProvider(QQuickImageProvider::Pixmap){}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    qDebug()<<"IMAGE PROVIDER REQUEST PIXMAP --------- "<<"C:/Development/clientImages/" + id;
    QPixmap result;
    if(!result.load("C:/Development/clientImages/" + id)){
        result.load("C:/Development/clientImages/loader.png");
        qDebug()<<"НЕ НАЙДЕНО ИЗОБРАЖЕНИЕ!!!!";
    }
    return result;
}

