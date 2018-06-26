#include <QJsonArray>
#include <QList>
#include <QVector>
#include <QVariant>
#include <QByteArray>
#include <QThread>

#include <QCryptographicHash>

#include <QImage>
#include <QStandardPaths>
#include <QDir>

#include "user.h"
#include "imagerunnable.h"



User::User(QObject *parent): QObject(parent), settings(new QSettings()), imgPool(new QThreadPool(this))
{
    if(!settings->value("user/name").toString().isEmpty())
        user_name = settings->value("user/name").toString();
    connectToHost();
    timer = new QTimer();
    timer->start(19000);

    connect(timer, &QTimer::timeout, [=](){ connectToHost(); });
    connect(this, &User::signAnswered, this, &User::storeUserSettings);
}

User::~User(){
    delete clientSocket;
    delete timer;
    delete settings;
    delete imgPool;
}

void User::checkName(const QString &name){
    if(socketIsReady()){
        QJsonObject jsonObj
        {
            {"requestType", "checkName"},
            {"user_name",   name}
        };
        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::setName(const QString &name){
    user_name = name;
    emit nameChanged();
}

void User::setPasswordHash(const QString &hash){
    passwordHash = hash;
}

void User::setUserData(const QJsonObject &userData)
{
    if(userData.contains("pop_value") || userData.contains("creativity") || userData.contains("shekels")){
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
    }
    QVariantList memeList = userData["memeList"].toArray().toVariantList();
    for(int i = 0; i < memeList.size(); i++)
    {
        QVariantMap memeObj = memeList[i].toMap();
        QString memeName = memeObj.value("memeName").toString();
        QVariantList tempPop = memeObj.value("popValues").value<QVariantList>();
        const int startPopValue = memeObj.value("startPopValue").toInt();
        const int memeCreativity = memeObj.value("creativity").toInt();
        const int loyalty = memeObj.value("loyalty").toInt();
        const QString category = memeObj.value("category").toString();
        QString imageName = memeObj.value("imageName").toString();
        QVector<int> memeValues;
        for(int i = 0; i < tempPop.size(); i++){
            memeValues.push_back(tempPop[i].toInt());
        }
        setMeme(memeName, memeValues, imageName, category, loyalty, memeCreativity, 0, true, startPopValue);
    }
}

void User::imageToThread(const QJsonObject &jsonObj)
{
    ImageRunnable *imgRun = new ImageRunnable();
    connect(imgRun, &ImageRunnable::imageReceived,
            [this](QString type, QString name, QString imageName){ emit imageReceived(type, name, imageName); });
    imgRun->setMemeImageObj(jsonObj);
    imgPool->start(imgRun);
}

bool User::findMeme(const QString &name){
    foreach(Meme memeCont, memes)
        if(memeCont.getName() == name)
            return memeCont.getForced();
    return false;
}

void User::setMemeImage(const QJsonObject &jsonObj)
{
    QString memeName = jsonObj.value("memeName").toString();
    QString imageName = jsonObj.value("imageName").toString();
    QByteArray encoded = jsonObj.value("imageData").toString().toLatin1();
    QImage memeImage;
    memeImage.loadFromData(QByteArray::fromBase64(encoded), "JPG");
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
    QDir imgs(homePath + "/imgs");
    if(!imgs.exists())
        imgs.mkpath(imgs.path());

    memeImage.save(imgs.path() + '/' + imageName, "JPG");
    emit imageReceived("meme", memeName, imageName);
}

void User::setAdImage(const QJsonObject &jsonObj)
{
    QString adName = jsonObj["adName"].toString();
    QString imageName = jsonObj["imageName"].toString();
    QByteArray encoded = jsonObj.value("imageData").toString().toLatin1();
    QImage adImage;
    adImage.loadFromData(QByteArray::fromBase64(encoded), "PNG");
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
    QDir imgs(homePath + "/imgs");
    if(!imgs.exists())
        imgs.mkpath(imgs.path());
    adImage.save(imgs.path() + '/' + imageName, "PNG");
    emit imageReceived("ad", adName, imageName);
}

void User::setMemesWithCategory(const QVariantList &memeList, const QString &category)
{
    for(int i = 0; i < memeList.size(); i++)
    {
        QVariantMap memeObj = memeList[i].toMap();
        QString memeName = memeObj["memeName"].toString();
        QVariantList tempPop = memeObj["popValues"].value<QVariantList>();
        int loyalty = memeObj["loyalty"].toInt();
        int memeCreativity = memeObj["creativity"].toInt();
        bool forced = memeObj["forced"].toBool();
        int startPopValue = memeObj["startPopValue"].toInt();
        QString imageName = memeObj["imageName"].toString();
        QVector<int> memeValues;
        for(int i = 0; i < tempPop.size(); i++){
            memeValues.push_back(tempPop[i].toInt());
        }
        setMeme(memeName, memeValues, imageName, category, loyalty, memeCreativity, 0, forced, startPopValue);
    }
}

void User::setAdList(const QVariantList &adList)
{
    for(int i = 0; i < adList.size(); i++){
        QVariantMap adObj = adList[i].toMap();
        QString adName = adObj["adName"].toString();
        QString imageName = adObj["imageName"].toString();
        QString adReputation = adObj["reputation"].toString();
        int adProfit = adObj["profit"].toInt();
        int adDiscontented = adObj["discontented"].toInt();
        int adSecondsToReady = adObj["secondsToReady"].toInt();
        int indexOfAd = getAdIndex(adName);
        if(indexOfAd != -1){
            ads.replace(indexOfAd, Ad(adName, imageName, adReputation, adProfit, adDiscontented, adSecondsToReady));
            emit adUpdated(adName, adReputation, adProfit, adDiscontented, adSecondsToReady);
        }
        else{
            ads.append(Ad(adName, imageName, adReputation, adProfit, adDiscontented, adSecondsToReady));
            emit adReceived(adName, imageName, adReputation, adProfit, adDiscontented, adSecondsToReady);
        }
    }
}

void User::setMemeData(const QJsonObject &obj)
{
    QVariantList tempPop = obj["popValues"].toArray().toVariantList();
    const QString memeName = obj["memeName"].toString();
    const int startPopValue = obj["startPopValue"].toInt();
    const double loyalty = obj["loyalty"].toDouble();
    const QString category = obj["category"].toString();
    const int memeCreativity = obj["creativity"].toInt();
    const QString memeImageName = obj["imageName"].toString();
    const bool forced = obj["forced"].toBool();
    QVector<int> memeValues;
    for(int i = 0; i < tempPop.size(); i++){
        memeValues.push_back(tempPop[i].toInt());
    }
    setMeme(memeName, memeValues, memeImageName, category, loyalty, memeCreativity, 0, forced, startPopValue);
}

void User::setUsersRating(const QJsonArray &userList, const int &userRating)
{
    emit usersRatingReceived(userList.toVariantList(), userRating);
}

void User::setMeme(const QString &memeName, const QVector<int> &memeValues, const QString &memeImageName,
                   const QString &memeCategory, const int &memeLoyalty, const int &memeCreativity, const int &memeShekels,
                   const bool &forced, const int &memeStartPopValue)
{
    for(int i = 0; i < memes.size(); i++){
        if(memes[i].getName() == memeName){
            memes[i].setPopValues(memeValues);
            memes[i].setImageName(memeImageName);
            memes[i].setCategory(memeCategory);
            memes[i].setLoyalty(memeLoyalty);
            memes[i].setCreativity(memeCreativity);
            memes[i].setShekels(memeShekels);
            memes[i].setForced(forced);
            memes[i].setStartPopValue(memeStartPopValue);
            emit memeReceived(memeName, memeValues, memeLoyalty, memeCategory, memeImageName, memeStartPopValue, memeCreativity);
            return;
        }
    }
    memes.append(Meme(memeName, memeValues, memeImageName, memeCategory, memeLoyalty, memeCreativity,
                      memeShekels, forced, memeStartPopValue));
    emit memeReceived(memeName, memeValues, memeLoyalty, memeCategory, memeImageName, memeStartPopValue, memeCreativity);
}


bool User::findCategoryMeme(const QString &name, const QString &category){
    foreach(Meme memeCont, memes){
        if(memeCont.getCategory() == category && memeCont.getName() == name)
            return true;
    }
    return false;
}

bool User::findAd(const QString &name)
{
    foreach(Ad adCont, ads){
        if(adCont.getName() == name)
            return true;
    }
    return false;
}

int User::getAdIndex(const QString &name)
{
    for(int i = 0; i < ads.size(); i++){
        if(ads[i].getName() == name)
            return i;
    }
    return -1;
}

void User::rewardUserWithShekels()
{
    if(socketIsReady()){

        QJsonObject jsonObj {
                                {"requestType", "rewardUserWithShekels"},
                                {"user_name", getName()},
                                {"shekels", 100}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

QString User::hashPassword(const QString &password, const QString &login){
    QByteArray passwordHash = QCryptographicHash::hash(password.toUtf8(), QCryptographicHash::Sha224);

    for(int i = 0; i < 4; i++){
        passwordHash = QCryptographicHash::hash(login.toUtf8() + passwordHash, QCryptographicHash::Sha224);
    }

    return QString::fromStdString(passwordHash.toHex().toStdString());
}

void User::connectToHost()
{
    if(clientSocket == nullptr){
        clientSocket = new QTcpSocket(this);
//        clientSocket->setSocketOption(QAbstractSocket::LowDelayOption, 1);
        connect(clientSocket, &QTcpSocket::readyRead, this, &User::onReadyRead);
        connect(clientSocket, &QTcpSocket::disconnected, this, &User::onDisconnected);
    }
    if(clientSocket->state() != QTcpSocket::ConnectedState)
        clientSocket->connectToHost("127.0.0.1", 1234);
//        clientSocket->connectToHost("10.0.3.2", 1234);
}

bool User::socketIsReady()
{
    return clientSocket == nullptr ? false : clientSocket->waitForConnected(3000);
}

bool User::writeData(const QByteArray &data)
{
    if(clientSocket->state() == QAbstractSocket::ConnectedState){
        clientSocket->write(intToArray(data.size()));
        clientSocket->write(data);
        return clientSocket->waitForBytesWritten();
    }
    else
        return false;
}

quint32 User::arrayToInt(QByteArray dataSize)
{
    quint32 temp;
    QDataStream stream(&dataSize, QIODevice::ReadWrite);
    stream >> temp;
    return temp;
}

QByteArray User::intToArray(const quint32 &dataSize)
{
    QByteArray temp;
    QDataStream stream(&temp, QIODevice::ReadWrite);
    stream << dataSize;
    return temp;
}

void User::signUp(const QString &name, const QString &password)
{
    if(socketIsReady()){
        passwordHash = hashPassword(password, name);

        QJsonObject jsonObj {
                                {"requestType", "signUp"},
                                {"user_name", name},
                                {"passwordHash", passwordHash}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::signIn(const QString &name, const QString &password)
{
    if(socketIsReady()){
        passwordHash = hashPassword(password, name);

        QJsonObject jsonObj {
                                {"requestType", "signIn"},
                                {"user_name", name},
                                {"passwordHash", passwordHash}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::autoSignIn()
{
    if(socketIsReady()){
        passwordHash = settings->value("user/passwordHash").toString();

        QJsonObject jsonObj {
                                {"requestType", "signIn"},
                                {"user_name", settings->value("user/name").toString()},
                                {"passwordHash", settings->value("user/passwordHash").toString()}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::signOut()
{
    settings->setValue("user/name", "");
    settings->setValue("user/passwordHash", "");
    settings->sync();
    setName("");
    setPasswordHash("");
    pop_value = 0;
    creativity = 0;
    shekels = 0;
    memes.clear();

    if(socketIsReady()){
        QJsonObject jsonObj {
                                {"requestType", "signOut"},
                                {"user_name", user_name}
        };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::getUserData()
{
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
    QDir imgs(homePath + "/imgs");
    QJsonArray memesToUpdate = QJsonArray::fromStringList(imgs.entryList());
    if(socketIsReady()){

        QJsonObject jsonObj {
                                {"requestType", "getUserData"},
                                {"user_name", user_name},
                                {"updateOnlyPopValues", memesToUpdate}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::onReadyRead(){
    while(clientSocket->bytesAvailable()){
        QByteArray byteArr;

        quint32 dataSize = arrayToInt(clientSocket->read(sizeof(quint32)));
        byteArr = clientSocket->read(dataSize);

        while(byteArr.size() < dataSize){
            clientSocket->waitForReadyRead();
            byteArr.append(clientSocket->read(dataSize - byteArr.size()));
        }

        QJsonObject jsonObj = QJsonDocument::fromBinaryData(byteArr).object();

        processingResponse(jsonObj);
    }
}

void User::onDisconnected(){
    clientSocket->close();
    clientSocket->deleteLater();
    clientSocket = nullptr;
}

void User::storeUserSettings(QString name, bool isSigned){
    if(isSigned){
        settings->setValue("user/name", name);
        settings->setValue("user/passwordHash", passwordHash);
        settings->sync();
    }
}

QString User::getName(){
    return user_name;
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
    if(responseType == "")
        qDebug()<<jsonObj;
    qDebug()<<responseType;
    if(responseType == "checkNameResponse"){
        if(jsonObj["nameAvailable"] == true){
            emit nameDoesNotExist();
        }
        else if(jsonObj["nameAvailable"] == false){
            emit nameExist();
        }
    }
    else if(responseType == "signUpResponse"){
        emit signAnswered(jsonObj["user_name"].toString(), jsonObj["created"].toBool());
    }
    else if(responseType == "signInResponse"){
        emit signAnswered(jsonObj["user_name"].toString(), jsonObj["accessed"].toBool());
    }
    else if(responseType == "getUserDataResponse"){
        setUserData(jsonObj);
    }
    else if(responseType == "getMemeDataResponse"){
        setMemeData(jsonObj);
    }
    else if(responseType == "memeImageResponse"){
        imageToThread(jsonObj);
    }
    else if(responseType == "adImageResponse"){
        imageToThread(jsonObj);
    }
    else if(responseType == "getMemeListWithCategoryResponse"){
        setMemesWithCategory(jsonObj["memeList"].toArray().toVariantList(), jsonObj["category"].toString());
    }
    else if(responseType == "getAdListResponse"){
        setAdList(jsonObj["adList"].toArray().toVariantList());
    }
    else if(responseType == "getMemesCategoriesResponse"){
        categories = jsonObj["categories"].toArray().toVariantList();
        emit memesCategoriesReceived(categories);
    }
    else if(responseType == "getUsersRatingResponse"){
        setUsersRating(jsonObj["usersList"].toArray(), jsonObj["user_rating"].toInt());
    }
}

QObject* User::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine){
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new User;
}

void User::setExistingMemeListWithCategory(const QString &category)
{
    foreach(Meme memeCont, memes){
        if(memeCont.getCategory() == category)
            emit memeReceived(memeCont.getName(), memeCont.getPopValues(), memeCont.getLoyalty(), category,
                                memeCont.getImageName(), memeCont.getStartPopValue(), memeCont.getCreativity());
    }
}

void User::setExistingAdList()
{
    foreach(Ad adCont, ads){
        emit adReceived(adCont.getName(), adCont.getImageName(), adCont.getReputation(), adCont.getProfit(),
                        adCont.getDiscontented(), adCont.getSecondsToReady());
    }
}

void User::getMemeListWithCategory(const QString &category)
{
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
    QDir imgs(homePath + "/imgs");
    QJsonArray memesToUpdate = QJsonArray::fromStringList(imgs.entryList());
    qDebug()<<memesToUpdate;

    if(socketIsReady()){

        QJsonObject jsonObj {
                                {"requestType", "getMemeListWithCategory"},
                                {"user_name", getName()},
                                {"category", category},
                                {"updateOnlyPopValues", memesToUpdate}
        };
        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::getAdList()
{
    QString homePath = QStandardPaths::standardLocations(QStandardPaths::HomeLocation)[0];
    QDir imgs(homePath + "/imgs");
    QJsonArray adsWithImages = QJsonArray::fromStringList(imgs.entryList());

    if(socketIsReady()){

        QJsonObject jsonObj {
                                {"requestType", "getAdList"},
                                {"adsWithImages", adsWithImages},
                                {"user_name", getName()}
        };
        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::getMemeData(const QString &memeName)
{
    if(socketIsReady()){

        QJsonObject jsonObj {
                                {"requestType", "getMemeData"},
                                {"meme_name", memeName},
                                {"user_name", getName()}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::getMemesCategories()
{
    if(socketIsReady()){

        QJsonObject jsonObj {
                                {"requestType", "getMemesCategories"}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::getUsersRating()
{
    if(socketIsReady()){

        QJsonObject jsonObj {
                                {"requestType", "getUsersRating"},
                                {"user_name", user_name}
                            };

        writeData(QJsonDocument(jsonObj).toBinaryData());
    }
}

void User::forceMeme(const QString &memeName, const int &contributedCreativity, const int &startPopValue, const QString &category)
{
    if(socketIsReady()){
        QJsonObject jsonObj {
                                {"requestType", "forceMeme"},
                                {"meme_name", memeName},
                                {"user_name", user_name},
                                {"startPopValue", startPopValue},
                                {"creativity", contributedCreativity}
                            };
        writeData(QJsonDocument(jsonObj).toBinaryData());
        for(int i = 0; i < memes.size(); i++){
            if(memes[i].getName() == memeName){
                memes[i].setForced(true);
                memes[i].setCreativity(memes[i].getCreativity() + contributedCreativity);
                memes[i].setStartPopValue(startPopValue);
            }

        }

        creativity -= contributedCreativity;
        emit creativityChanged();
    }
}

void User::unforceMeme(const QString &memeName)
{
    if(socketIsReady()){
        QJsonObject jsonObj {
                                {"requestType", "unforceMeme"},
                                {"meme_name", memeName},
                                {"user_name", user_name}
                            };
        writeData(QJsonDocument(jsonObj).toBinaryData());
        for(int i = 0; i< memes.size(); i++){
            if(memes[i].getName() == memeName){
                memes[i].setForced(false);
                memes[i].setStartPopValue(-1);
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
    if(socketIsReady()){
        QJsonObject jsonObj {
                                {"requestType", "increaseLikesQuantity"},
                                {"meme_name", memeName},
                                {"currentPopValues", QJsonArray::fromVariantList(variantValues)},
                                {"shekels", investedShekels},
                                {"user_name", user_name}
                            };
        writeData(QJsonDocument(jsonObj).toBinaryData());

        const int likeIncrement = memeValues.last() + investedShekels;

        if(memeValues.size() == 12){
            for(int i = 0; i < memeValues.size() - 1; i++){
                memeValues[i] = memeValues[i + 1];
            }
            memeValues.last() = likeIncrement;
        }
        else{
            memeValues.append(likeIncrement);
        }
        memes[indexOfMeme].setPopValues(memeValues);
        emit memeReceived(memes[indexOfMeme].getName(), memeValues, memes[indexOfMeme].getLoyalty(),
                          memes[indexOfMeme].getCategory(), memes[indexOfMeme].getImageName(),
                          memes[indexOfMeme].getStartPopValue(), memes[indexOfMeme].getCreativity());
        shekels -= investedShekels;
        emit shekelsChanged();
    }
}

void User::acceptAd(const QString &adName)
{
    Ad  tempAd;
    foreach(Ad adCont, ads){
        if(adCont.getName() == adName){
            tempAd = adCont;
            break;
        }
    }
    QJsonObject jsonObj {
                            {"requestType", "acceptAd"},
                            {"user_name", getName()},
                            {"adName", adName},
                            {"adProfit", tempAd.getProfit()},
                            {"adDiscontented", tempAd.getDiscontented()}
                        };
    writeData(QJsonDocument(jsonObj).toBinaryData());
}

int User::getMemeCreativity(const QString &memeName)
{
    foreach(Meme memeCont, memes)
        if(memeCont.getName() == memeName)
            return memeCont.getCreativity();
}

bool User::memesWithCategoryIsEmpty(const QString &category){
    foreach(Meme memeCont, memes)
        if(memeCont.getCategory() == category)
            return false;
    return true;
}

bool User::adsIsEmpty()
{
    return ads.isEmpty();
}

void User::localUpdateUserData()
{
    foreach(Meme memeCont, memes){
        emit memeReceived(memeCont.getName(), memeCont.getPopValues(), memeCont.getLoyalty(),
                          memeCont.getCategory(), memeCont.getImageName(), memeCont.getStartPopValue(),
                          memeCont.getCreativity());
    }
    emit creativityChanged();
    emit shekelsChanged();
    emit popValueChanged();
}

void User::localUpdateMeme(const QString &memeName)
{
    foreach(Meme memeCont, memes){
        if(memeCont.getName() == memeName){
            emit memeReceived(memeName, memeCont.getPopValues(), memeCont.getLoyalty(), memeCont.getCategory(),
                              memeCont.getImageName(), memeCont.getStartPopValue(), memeCont.getCreativity());
            return;
        }
    }
}

