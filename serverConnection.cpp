#include "serverConnection.h"

ServerConnection::ServerConnection(QObject *parent):
    QObject(parent)
{
    database = QSqlDatabase::addDatabase("QMYSQL");
    database.setHostName("127.0.0.1");
    database.setDatabaseName("appschema");
    database.setPort(3306);
    database.setUserName("root");
    database.setPassword("root");
    if(!database.open())
        qDebug()<<"database is not open!";
    else
        qDebug()<<"database is open...";
}


void ServerConnection::setName(const QString &name){
    QSqlQuery query(database);
    query.prepare("SELECT * FROM users WHERE name = :name;");
    query.bindValue(":name", name);

    query.exec();

    if(query.size() == 0)
    {
        user_name = name;
        emit nameIsCorrect();
        qDebug()<<"имя "<<user_name<< " свободно";
    }
    else{
        emit nameIsExist();
        qDebug()<<"имя занято!";
    }
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
    QSqlQuery query(database);
    query.prepare("INSERT INTO users (name, password) VALUES(:name, :password);");
    query.bindValue(":name", user_name);
    query.bindValue(":password", user_password);
    query.exec();
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

QObject* ServerConnection::qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)

    return new ServerConnection;
}

