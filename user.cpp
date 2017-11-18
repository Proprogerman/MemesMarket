#include "user.h"

User::User(QObject *parent):
    QObject(parent)
{
    qDebug()<<"User constructor";
    clientSocket = new QTcpSocket();

    connect(clientSocket, &QTcpSocket::readyRead, this, &User::onReadyRead);
    connect(clientSocket, &QTcpSocket::disconnected, this, &User::onDisconnected);
}

void User::checkName(const QString &name){
    //clientSocket = new QTcpSocket(this);
    clientSocket->connectToHost("127.0.0.1", 1234);

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
}

void User::setPassword(const QString &password){
    user_password = password;
}

//void ServerConnection::setToken(const QString &token)
//{
//    //загрузка токена из БД!!!!
//}

void User::signUp()
{
    clientSocket = new QTcpSocket(this);
    clientSocket->connectToHost("127.0.0.1", 1234);

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
    qDebug()<<"onReadyRead()";
    QByteArray byteArr = clientSocket->readAll();
    QJsonObject jsonObj = QJsonDocument::fromBinaryData(byteArr).object();

    processingResponse(jsonObj);

}

void User::onDisconnected()
{
    qDebug()<<"onDisconnected()";
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
        //обработка других ответов от сервера
//    }
}

QObject* User::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new User;
}

void User::getMemeList()
{
    clientSocket = new QTcpSocket(this);
    clientSocket->connectToHost("127.0.0.1", 1234);

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
    clientSocket = new QTcpSocket(this);
    clientSocket->connectToHost("127.0.0.1", 1234);

    if(clientSocket->waitForConnected(3000)){

        QJsonObject jsonObj {
                                {"requestType", "getMeme"},
                                {"meme_name", meme_name}
                            };

        clientSocket->write(QJsonDocument(jsonObj).toBinaryData());
        clientSocket->waitForBytesWritten(3000);
    }
}

