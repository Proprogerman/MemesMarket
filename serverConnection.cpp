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

bool ServerConnection::signUp(const QString &name, const QString &password)
{
    QSqlQuery query(database);
    query.prepare("SELECT * FROM users WHERE user_name = :name;");
    query.bindValue(":name", name);

    query.exec();

    if(query.size() == 0)
    {
        query.prepare("INSERT INTO users (user_name) VALUES(:name, :password);");
        query.bindValue(":name", name);
        query.bindValue(":password", password);
        return true;

        if(!query.exec())
        {
            query.lastError().databaseText();
            query.lastError().driverText();
        }
    }
    else
    {
        qDebug()<<"пользователь с таким именем уже существует, придумайте другое имя!";
        return false;
    }
}
