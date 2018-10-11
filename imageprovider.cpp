#include <QStandardPaths>
#include <QDir>
#include <QDebug>

#include "imageprovider.h"


ImageProvider::ImageProvider(): QQuickImageProvider(QQuickImageProvider::Pixmap),
    user(User::getInstance())
{

}

ImageProvider::~ImageProvider()
{

}

QPixmap ImageProvider::requestPixmap(const QString &id, QSize *size, const QSize &requestedSize)
{
    QPixmap result;
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];

    QDir imgs(homePath + "/imgs");

    int tIndx = 0;
    while(id.at(tIndx) != '_')
        ++tIndx;
    QStringRef type(&id, 0, tIndx);
    QString path = imgs.path() + '/' + type + '/';
    QString name = id.right(id.size() - tIndx - 1);
    if(type == "meme"){
        path.append(user->getMemeCategory(name) + '/');
    }

    if(!imgs.exists())
        imgs.mkpath(imgs.path());
    if(!result.load(path + name)){
        result.load(":/photo/memePlaceholder.png");
    }
    return result;
}

