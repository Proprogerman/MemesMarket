#include "user.h"
#include <QJsonArray>
#include <QList>
#include <QVector>
#include <QVariant>
#include <QByteArray>

#include <QImage>



User::User(QObject *parent):
    QObject(parent)
{
    setName("KingOfMemes");
    clientSocket = new QTcpSocket();
    clientSocket->connectToHost("127.0.0.1", 1234);

    connect(clientSocket, &QTcpSocket::readyRead, this, &User::onReadyRead);
    connect(clientSocket, &QTcpSocket::disconnected, this, &User::onDisconnected);
}

void User::checkName(const QString &name){
    if(clientSocket->waitForConnected(3000)){
        QJsonObject jsonObj
        {
            {"requestType", "checkName"},
            {"user_name",   name}
        };
        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

void User::setName(const QString &name){
    user_name = name;
    emit nameChanged();
}

void User::setPassword(const QString &password){
    user_password = password;
}

void User::setMemes(QVariantList memeList)
{
    for(int i = 0; i < memeList.size(); i++)
    {
        QVariantMap memeObj = memeList[i].toMap();
        QString memeName = memeObj.value("memeName").toString();
        QString imageName = memeObj.value("imageName").toString();
        //QVariant popVariant = QVariant(memeObj.value("popValues"));
        QVariantList tempPop = memeObj.value("popValues").value<QVariantList>();
        QVector<int> memeValues;
        for(int i = 0; i < tempPop.size(); i++){
            memeValues.push_back(tempPop[i].toInt());
        }
        QByteArray encoded = memeObj.value("imageData").toString().toLatin1();
        QImage memeImage;
        memeImage.loadFromData(QByteArray::fromBase64(encoded), "JPG");
        memeImage.save("C:/Development/clientImages/" + imageName, "JPG");

        qDebug() << "MEMEDATA: " << memeName << " - " << memeValues;
        int crsDir = memeValues[memeValues.length() - 1] -  memeValues[memeValues.length() - 2];
        memes.append(Meme(memeName, memeValues, "C:/Development/clientImages/" + imageName + ".jpg"));
        emit memesRecieved(memeName, imageName, memeValues, crsDir);
    }
}

void User::signUp()
{
    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "signUp"},
                                {"user_name", user_name},
                                {"user_password", user_password}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

void User::onReadyRead()
{
    QByteArray byteArr = clientSocket->readAll();
    QJsonObject jsonObj = QJsonDocument::fromBinaryData(byteArr).object();

    processingResponse(jsonObj);
}

void User::onDisconnected()
{
    clientSocket->close();
    clientSocket->deleteLater();
}

QString User::getName(){
    return user_name;
}

QString User::getPassword(){
    return user_password;
}

void User::processingResponse(QJsonObject &jsonObj)
{
//    if(user_name.isEmpty()){
        if(jsonObj["responseType"] == "checkNameResponse"){
                qDebug()<<"responseType == checkNameResponse";
                if(jsonObj["nameAvailable"] == true){
                    qDebug()<<"emit nameIsCorrect();";
                    emit nameIsCorrect();
                }
                else if(jsonObj["nameAvailable"] == false){
                    qDebug()<<"emit nameIsExist();";
                    emit nameIsExist();
                }
            }
//    }
    else{
        if(jsonObj["responseType"] == "getMemeListResponse"){
            qDebug()<<"responseType == getMemeListResponse";
            setMemes(jsonObj["memeList"].toArray().toVariantList());
        }
    }
}

QObject* User::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new User;
}

void User::getMemeList()
{
    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMemeList"},
                                {"user_name", user_name}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

void User::getMeme(QString &meme_name)
{
    qDebug()<<"getMeme : "<< meme_name;
    clientSocket = new QTcpSocket(this);

    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMeme"},
                                {"meme_name", meme_name}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

