#include "serverConnection.h"

ServerConnection::ServerConnection(QObject *parent):
    QObject(parent)
{
    qDebug()<<"ServerConnection constructor";
    clientSocket = new QTcpSocket();

    connect(clientSocket, &QTcpSocket::readyRead, this, &ServerConnection::onReadyRead);
    connect(clientSocket, &QTcpSocket::disconnected, this, &ServerConnection::onDisconnected);
}

void ServerConnection::checkName(const QString &name){
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

void ServerConnection::setName(const QString &name){
    user_name = name;
}

void ServerConnection::setPassword(const QString &password){
    user_password = password;
}

//void ServerConnection::setToken(const QString &token)
//{
//    //загрузка токена из БД!!!!
//}

void ServerConnection::signUp()
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

void ServerConnection::onReadyRead()
{
    qDebug()<<"onReadyRead()";
    QByteArray byteArr = clientSocket->readAll();
    QJsonObject jsonObj = QJsonDocument::fromBinaryData(byteArr).object();

    processingResponse(jsonObj);

}

void ServerConnection::onDisconnected()
{
    qDebug()<<"onDisconnected()";
    clientSocket->close();
    clientSocket->deleteLater();
}

QString ServerConnection::getName(){
    return user_name;
}

QString ServerConnection::getPassword(){
    return user_password;
}

QString ServerConnection::userToken()
{
    return user_token;
}

void ServerConnection::processingResponse(QJsonObject &jsonObj)
{
//    switch(jsonObj["responseType"]){
//        case "checkNameResponse":
//        {
    if(jsonObj["responseType"] == "checkNameResponse"){
            qDebug()<<"responseType == checkNameResponse";
            if(jsonObj["nameAvailability"] == true){
                qDebug()<<"emit nameIsCorrect();";
                emit nameIsCorrect();
            }
            else if(jsonObj["nameAvailability"] == false){
                qDebug()<<"emit nameIsExist();";
                emit nameIsExist();
            }
        }
        //обработка других ответов от сервера
//    }
}

QObject* ServerConnection::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new ServerConnection;
}

