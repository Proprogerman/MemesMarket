#include "imagerunnable.h"

#include <QByteArray>
#include <QImage>
#include <QDir>
#include <QStandardPaths>
#include <QDebug>

ImageRunnable::ImageRunnable(QObject *parent): QObject(parent)
{

}

void ImageRunnable::run()
{
    QString imageName = imageObj.value("imageName").toString();
    QByteArray encoded = imageObj.value("imageData").toString().toLatin1();
    QImage img;
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
    QDir imgs(homePath + "/imgs");
    if(!imgs.exists())
        imgs.mkpath(imgs.path());
    if(imageObj.value("responseType").toString() == "memeImageResponse"){
        img.loadFromData(QByteArray::fromBase64(encoded), "JPG");
        img.save(imgs.path() + '/' + imageName, "JPG");
        emit imageReceived("meme", imageObj.value("memeName").toString(), imageName);
    }
    else if(imageObj.value("responseType").toString() == "adImageResponse"){
        img.loadFromData(QByteArray::fromBase64(encoded), "PNG");
        img.save(imgs.path() + '/' + imageName, "PNG");
        emit imageReceived("ad", imageObj.value("adName").toString(), imageName);
    }
}

void ImageRunnable::setMemeImageObj(QJsonObject jsonObj)
{
    imageObj = jsonObj;
}
