#include <QJsonArray>
#include <QList>
#include <QVector>
#include <QVariant>
#include <QByteArray>
#include <QThread>

#include <QImage>

#include "user.h"
#include "independentconnection.h"


User::User(QObject *parent):
    QObject(parent)
{
    setName("KingOfMemes");                                                 // while testing
    clientSocket = new QTcpSocket();
    clientSocket->connectToHost("127.0.0.1", 1234);
    clientSocket->setSocketOption(QAbstractSocket::LowDelayOption, 1);

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
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
    }
}

void User::setName(const QString &name){
    user_name = name;
    emit nameChanged();
}

void User::setPassword(const QString &password){
    user_password = password;
}

void User::setUserData(const QJsonObject &userData)
{
    int tempPopValue = userData["pop_value"].toInt();
    int tempCreativity = userData["creativity"].toInt();
    int tempShekels = userData["shekels"].toInt();
    if(pop_value != tempPopValue){
        pop_value = tempPopValue;
        emit popValueChanged();
    }
    if(creativity != tempCreativity){
        creativity = tempCreativity;
        emit creativityChanged();
    }
    if(shekels != tempShekels){
        shekels = tempShekels;
        emit shekelsChanged();
    }
    QVariantList memeList = userData["memeList"].toArray().toVariantList();
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
        if(!findMeme(memeName)){
            qDebug()<<"KKKKIIIEEEKK";
            QString imageName = memeObj.value("imageName").toString();
//            QByteArray encoded = memeObj.value("imageData").toString().toLatin1();
//            QImage memeImage;
//            memeImage.loadFromData(QByteArray::fromBase64(encoded), "JPG");
//            memeImage.save("C:/Development/clientImages/" + imageName, "JPG");
            //qDebug() << "MEMEDATA: " << memeName << " - " << memeValues;
            //int crsDir = memeValues[memeValues.length() - 1] -  memeValues[memeValues.length() - 2];
            memes.append(Meme(memeName, memeValues, imageName, startPopValue));
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
            memes[indexOfMeme].setPopValues(memeValues);
            //int crsDir = memeValues[memeValues.size() - 1] - startPopValue;
            emit memePopValuesForUserUpdated(memeName, memeValues, startPopValue);
            continue;
        }
    }
}

bool User::findMeme(const QString &name){
    foreach(Meme memeCont, memes){
        if(memeCont.getName() == name)
            return true;
    }
    return false;
}

void User::setMemeImage(const QJsonObject &jsonObj)
{
    QString memeName = jsonObj.value("memeName").toString();
    QString imageName = jsonObj.value("imageName").toString();
    QByteArray encoded = jsonObj.value("imageData").toString().toLatin1();
    QImage memeImage;
    memeImage.loadFromData(QByteArray::fromBase64(encoded), "JPG");
    memeImage.save("C:/Development/clientImages/" + imageName, "JPG");
    //qDebug() << "MEMEDATA: " << memeName << " - " << memeValues;
    //int crsDir = memeValues[memeValues.length() - 1] -  memeValues[memeValues.length() - 2];
    emit memeImageReceived(memeName, imageName);
    qDebug()<<"SET MEME IMAGE";
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
        if(!findCategoryMeme(memeName, category)){
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
            memesWithCategory[category][indexOfMeme].setPopValues(memeValues);
            memePopValuesWithCategoryUpdated(memeName, memeValues, category);
            continue;
        }

    }
}

void User::setMemeDataForUser(const QJsonObject &obj)
{
    qDebug()<<"responseType == getMemeDataForUserResponse";
    QVariantList tempPop = obj["popValues"].toArray().toVariantList();
    int startPopValue = obj["startPopValue"].toInt();
    QVector<int> memeValues;
    for(int i = 0; i < tempPop.size(); i++){
        memeValues.push_back(tempPop[i].toInt());
    }
    if(!memeValues.isEmpty()){
        int courseDir = memeValues[memeValues.size() - 1] - startPopValue;
        for(int i = 0; i < memes.size(); i++){
            if(memes[i].getName() == obj["memeName"].toString())
                memes[i].setPopValues(memeValues);
        }
        emit memePopValuesForUserUpdated(obj["memeName"].toString(), memeValues, startPopValue);
    }
    qDebug()<<"MEME VALUES:::::::::::::::::::::::::::: " << memeValues << "::::::" << tempPop;
}

void User::setMemeData(const QJsonObject &obj)
{
    qDebug()<<"responseType == getMemeDataResponse";
    QVariantList tempPop = obj["popValues"].toArray().toVariantList();
    QVector<int> memeValues;
    for(int i = 0; i < tempPop.size(); i++){
        memeValues.push_back(tempPop[i].toInt());
    }
    if(!memeValues.isEmpty()){
        for(int i = 0; i < memes.size(); i++){
            if(memes[i].getName() == obj["memeName"].toString())
                memes[i].setPopValues(memeValues);
        }
        emit memePopValuesUpdated(obj["memeName"].toString(), memeValues);
    }
    qDebug()<<"MEME VALUES:::::::::::::::::::::::::::: " << memeValues << "::::::" << tempPop;
}

bool User::findCategoryMeme(const QString &name, const QString &category){
    foreach(Meme memeCont, memesWithCategory[category]){
        if(memeCont.getName() == name)
            return true;
    }
    return false;
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
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
    }
}

void User::getUserData()
{
    QJsonArray memesToUpdate;
    if(!memes.isEmpty()){
        for(int i = 0; i < memes.size(); i++){
            QImage memeImage;
            if(memeImage.load("C:/Development/clientImages/" + memes[i].getImageName()))
                memesToUpdate.append(memes[i].getName());
        }
    }
    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getUserData"},
                                {"user_name", user_name},
                                {"updateOnlyPopValues", memesToUpdate}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
    }
}

void User::onReadyRead(){
    QByteArray byteArr = clientSocket->readAll();
    QJsonObject jsonObj = QJsonDocument::fromBinaryData(byteArr).object();
    qDebug()<<"RESPONSE TYPE: "<<jsonObj.value("responseType").toString();
    //qDebug()<<"JSON OBJ: "<<jsonObj;
    processingResponse(jsonObj);
}

void User::onDisconnected(){
    clientSocket->close();
    clientSocket->deleteLater();
}

QString User::getName(){
    return user_name;
}

QString User::getPassword(){
    return user_password;
}

int User::getUserPopValue(){
    return pop_value;
}

int User::getCreativity(){
    return creativity;
}

int User::getShekels(){
    return shekels;
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
    else if(responseType == "getUserDataResponse"){
        setUserData(jsonObj);
    }
    else if(responseType == "getMemeDataForUserResponse"){
        setMemeDataForUser(jsonObj);
    }
    else if(responseType == "memeImageResponse"){
        setMemeImage(jsonObj);
//        toOtherThread(jsonObj);
    }
    else if(responseType == "getMemeDataResponse"){
        setMemeData(jsonObj);
    }
    else if(responseType == "getMemeListWithCategoryResponse"){
        setMemesWithCategory(jsonObj["memeList"].toArray().toVariantList(), jsonObj["category"].toString());
    }
    else if(responseType == "getMemesCategoriesResponse"){
        categories = jsonObj["categories"].toArray().toVariantList();
        emit memesCategoriesReceived(categories);
    }
}

void User::toOtherThread(const QJsonObject &jsonObj)
{
    IndependentConnection* indep = new IndependentConnection();
    connect(indep, &IndependentConnection::memeImageReceived, this, &User::memeImageReceived);
    QThread* thread = new QThread();
    indep->moveToThread(thread);

    connect(thread, &QThread::started, [=](){indep->processingResponse(jsonObj);});
    connect(indep, &IndependentConnection::finished, thread, &QThread::quit);
    connect(indep, &IndependentConnection::finished, indep, &IndependentConnection::deleteLater);
    thread->start();
    return;
}

QObject* User::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine){
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new User;
}

void User::setExistingMemeListWithCategory(const QString &category)
{
    QVector<Meme> tempMemes = memesWithCategory[category];
    for(int i = 0; i < tempMemes.size(); i++){
        emit memeWithCategoryReceived(tempMemes[i].getName(), tempMemes[i].getImageName(),
                                      tempMemes[i].getPopValues(), category);
    }
}

void User::getMemeListWithCategory(const QString &category)
{
    qDebug() << "getMeme List With Category: " << category;
    QJsonArray memesToUpdate;
    if(!memesWithCategory[category].isEmpty()){
        for(int i = 0; i < memesWithCategory[category].size(); i++){
            QImage memeImage;
            if(memeImage.load("C:/Development/clientImages/" + memesWithCategory[category][i].getImageName()))
                memesToUpdate.append(memesWithCategory[category][i].getName());
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
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
    }
}

void User::getMemeData(const QString &memeName)
{
    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMemeData"},
                                {"meme_name", memeName}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
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
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
    }
}

void User::forceMeme(const QString &memeName, const int &endowedCreativity, const int &startPopValue, const QString &category)
{
    if(clientSocket->waitForConnected(3000)){
        QJsonObject jsonObj {
                                {"requestType", "forceMeme"},
                                {"meme_name", memeName},
                                {"user_name", user_name},
                                {"startPopValue", startPopValue},
                                {"creativity", endowedCreativity}
                            };
        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
        foreach(Meme memeCont, memesWithCategory[category]){
            if(memeCont.getName() == memeName){
                memes.append(Meme(memeName, memeCont.getPopValues(), memeCont.getImageName(),
                                  memeCont.getPopValues().last()));
                break;
            }
        }
        creativity -= endowedCreativity;
        emit creativityChanged();
    }
}

void User::unforceMeme(const QString &memeName)
{
    if(clientSocket->waitForConnected(3000)){
        QJsonObject jsonObj {
                                {"requestType", "unforceMeme"},
                                {"meme_name", memeName},
                                {"user_name", user_name}
                            };
        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);
        for(int i = 0; i < memes.size(); i++){
            if(memes[i].getName() == memeName){
                memes.remove(i);
                emit memeUnforced(memeName);
                break;
            }
        }
    }
}

void User::increaseLikesQuantity(const QString &memeName, const int &investedShekels)
{
    int indexOfMeme;
    for(int j = 0; j < memes.size(); j++){
        if(memes[j].getName() == memeName){
            indexOfMeme = j;
            break;
        }
    }
    QVector<int> memeValues = memes[indexOfMeme].getPopValues();
    QVariantList variantValues;
    foreach(int value, memeValues){
        variantValues.append(value);
    }
    if(clientSocket->waitForConnected(3000)){
        QJsonObject jsonObj {
                                {"requestType", "increaseLikesQuantity"},
                                {"meme_name", memeName},
                                {"currentPopValues", QJsonArray::fromVariantList(variantValues)},
                                {"shekels", investedShekels},
                                {"user_name", user_name}
                            };
        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->flush();
        clientSocket->waitForBytesWritten(3000);
        QThread::msleep(100);

        const int likeIncrement = memeValues.last() + investedShekels;

        if(memeValues.size() == 12){
            for(int i = 0; i < memeValues.size() - 1; i++){
                memeValues[i] = memeValues[i + 1];
            }
            memeValues.last() = likeIncrement;
            qDebug()<<"РАВНО 12";
        }
        else{
            memeValues.append(likeIncrement);
            qDebug()<<"НЕ РАВНО 12";
        }

        memes[indexOfMeme].setPopValues(memeValues);
        emit memePopValuesUpdated(memes[indexOfMeme].getName(), memeValues);
        shekels -= investedShekels;
        emit shekelsChanged();
    }
}

bool User::memesWithCategoryIsEmpty(const QString &category){
    return memesWithCategory[category].isEmpty();
}

void User::localUpdateUserData()
{
    foreach(Meme memeCont, memes){
        emit memeForUserReceived(memeCont.getName(), memeCont.getImageName(), memeCont.getPopValues(),
                                 memeCont.getStartPopValue());
    }
    emit creativityChanged();
    emit shekelsChanged();
}
