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

void User::setMemesOfUser(const QVariantList &memeList)
{
    for(int i = 0; i < memeList.size(); i++)
    {
        QVariantMap memeObj = memeList[i].toMap();
        QString memeName = memeObj.value("memeName").toString();
        QVariantList tempPop = memeObj.value("popValues").value<QVariantList>();
        int startPopValue = memeObj.value("startPopValue").toInt();
        QVector<int> memeValues;
        for(int i = 0; i < tempPop.size(); i++){
            memeValues.push_back(tempPop[i].toInt());
        }
        if(memeObj.find("imageName") != memeObj.end()){
            qDebug()<<"KKKKIIIEEEKK";
            QString imageName = memeObj.value("imageName").toString();
            QByteArray encoded = memeObj.value("imageData").toString().toLatin1();
            QImage memeImage;
            memeImage.loadFromData(QByteArray::fromBase64(encoded), "JPG");
            memeImage.save("C:/Development/clientImages/" + imageName, "JPG");
            //qDebug() << "MEMEDATA: " << memeName << " - " << memeValues;
            //int crsDir = memeValues[memeValues.length() - 1] -  memeValues[memeValues.length() - 2];
            memes.append(Meme(memeName, memeValues, imageName));
            emit memeForUserReceived(memeName, imageName, memeValues, startPopValue);
        }
        else{
            qDebug()<<"LLLOOOOOLL";
            int indexOfMeme;
            for(int j = 0; j < memes.size(); j++){
                if(memes[j].getName() == memeName){
                    indexOfMeme = j;
                    break;
                }
            }
            memes[indexOfMeme].updatePopValues(memeValues);
            //int crsDir = memeValues[memeValues.size() - 1] - startPopValue;
            emit memePopValuesForUserUpdated(memeName, memeValues, startPopValue);
            continue;
        }
    }
}

void User::setMemesWithCategory(const QVariantList &memeList, const QString &category)
{
    for(int i = 0; i < memeList.size(); i++)
    {
        qDebug()<<"SET MEMES WITH CATEGORY";
        QVariantMap memeObj = memeList[i].toMap();
        QString memeName = memeObj.value("memeName").toString();
        QVariantList tempPop = memeObj.value("popValues").value<QVariantList>();
        QVector<int> memeValues;
        for(int i = 0; i < tempPop.size(); i++){
            memeValues.push_back(tempPop[i].toInt());
        }
        if(memeObj.find("imageName") != memeObj.end()){
            qDebug()<<"KKKKIIIEEEKK";
            QString imageName = memeObj.value("imageName").toString();
            QByteArray encoded = memeObj.value("imageData").toString().toLatin1();
            QImage memeImage;
            memeImage.loadFromData(QByteArray::fromBase64(encoded), "JPG");
            memeImage.save("C:/Development/clientImages/" + imageName, "JPG");
            //qDebug() << "MEMEDATA: " << memeName << " - " << memeValues;
            //int crsDir = memeValues[memeValues.length() - 1] -  memeValues[memeValues.length() - 2];
            memesWithCategory[category].append(Meme(memeName, memeValues, imageName));
            emit memeWithCategoryReceived(memeName, imageName, memeValues, category);
        }
        else{
            qDebug()<<"LLLOOOOOLL";
            int indexOfMeme;
            for(int j = 0; j < memesWithCategory[category].size(); j++){
                if(memesWithCategory[category][j].getName() == memeName){
                    indexOfMeme = j;
                    break;
                }
            }
            memesWithCategory[category][indexOfMeme].updatePopValues(memeValues);
            memePopValuesWithCategoryUpdated(memeName, memeValues, category);
            continue;
        }

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
    const QString responseType = jsonObj["responseType"].toString();
    qDebug() << "RESPONSE: " << responseType;
    if(responseType == "checkNameResponse"){
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
    else if(responseType == "getMemeListOfUserResponse"){
        qDebug()<<"responseType == getMemeListOfUserResponse";
        setMemesOfUser(jsonObj["memeList"].toArray().toVariantList());
    }
    else if(responseType == "getMemeDataForUserResponse"){
        qDebug()<<"responseType == getMemeDataForUserResponse";
        QVariantList tempPop = jsonObj["popValues"].toArray().toVariantList();
        int startPopValue = jsonObj["startPopValue"].toInt();
        QVector<int> memeValues;
        for(int i = 0; i < tempPop.size(); i++){
            memeValues.push_back(tempPop[i].toInt());
        }
        if(!memeValues.isEmpty()){
            //int courseDir = memeValues[memeValues.size() - 1] - startPopValue;
            emit memePopValuesForUserUpdated(jsonObj["memeName"].toString(), memeValues, startPopValue);
        }
        qDebug()<<"MEME VALUES:::::::::::::::::::::::::::: " << memeValues << "::::::" << tempPop;
    }
    else if(responseType == "getMemeListWithCategoryResponse"){
        setMemesWithCategory(jsonObj["memeList"].toArray().toVariantList(), jsonObj["category"].toString());
    }
    else if(responseType == "getMemesCategoriesResponse"){
        categories = jsonObj["categories"].toArray().toVariantList();
        emit memesCategoriesReceived(categories);
    }
}

QObject* User::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new User;
}

void User::getMemeListOfUser()
{
    QJsonArray memesToUpdate;
    if(!memes.isEmpty()){
        for(int i = 0; i < memes.size(); i++){
            memesToUpdate.append(memes[i].getName());
            qDebug() << "MEME ON DEVICE: " << memes[i].getName();
        }
    }

    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMemeListOfUser"},
                                {"user_name", user_name},
                                {"updateOnlyPopValues", memesToUpdate}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

void User::setExistingMemeListWithCategory(const QString &category)
{
    QVector<Meme> tempMemes = memesWithCategory[category];
    for(int i = 0; i < tempMemes.size(); i++){
        emit memeWithCategoryReceived(tempMemes[i].getName(), tempMemes[i].getImageName(), tempMemes[i].getPopValues(), category);
    }
}

void User::getMemeListWithCategory(const QString &category)
{
    qDebug() << "getMeme List With Category: " << category;
    QJsonArray memesToUpdate;
    if(!memesWithCategory[category].isEmpty()){
        for(int i = 0; i < memesWithCategory[category].size(); i++){
            memesToUpdate.append(memesWithCategory[category][i].getName());
            qDebug() << "MEME ON DEVICE: " << memesWithCategory[category][i].getName();
        }
    }

    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMemeListWithCategory"},
                                {"category", category},
                                {"updateOnlyPopValues", memesToUpdate}
        };
        qDebug() << "MEMES TO UPDATE: " << memesToUpdate;
        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

void User::getMemeDataForUser(const QString &meme_name)
{
    qDebug() << "getMeme : "<< meme_name;

    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMemeDataForUser"},
                                {"meme_name", meme_name},
                                {"user_name", getName()}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

void User::getMemesCategories()
{
    qDebug() << "get categories";

    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMemesCategories"}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

bool User::memesWithCategoryIsEmpty(const QString &category){
    return memesWithCategory[category].isEmpty();
}

