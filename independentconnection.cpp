#include <QByteArray>
#include <QImage>
#include <QDebug>
#include "independentconnection.h"


IndependentConnection::IndependentConnection(QObject *parent): QObject(parent)
{

}

void IndependentConnection::setMemeImage(const QJsonObject &jsonObj)
{
    QString memeName = jsonObj.value("memeName").toString();
    QString imageName = jsonObj.value("imageName").toString();
    QByteArray encoded = jsonObj.value("imageData").toString().toLatin1();
    QImage memeImage;
    memeImage.loadFromData(QByteArray::fromBase64(encoded), "JPG");
    memeImage.save("C:/Development/clientImages/" + imageName, "JPG");
    emit memeImageReceived(memeName, imageName);
    qDebug()<<"SET MEME IMAGE";
}

void IndependentConnection::processingResponse(const QJsonObject &jsonObj)
{
    qDebug()<<"THREAD";
    if(jsonObj.value("responseType").toString() == "memeImageResponse")
        setMemeImage(jsonObj);

    emit finished();
}
