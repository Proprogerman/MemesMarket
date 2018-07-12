#include <QStandardPaths>
#include <QDir>

#include "imageprovider.h"

ImageProvider::ImageProvider(): QQuickImageProvider(QQuickImageProvider::Pixmap){}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QPixmap result;
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
    QDir imgs(homePath + "/imgs");
    if(!imgs.exists())
        imgs.mkpath(imgs.path());
    if(!result.load(imgs.path() + '/' + id)){
        result.load(":/photo/memePlaceholder.png");
    }
    return result;
}

