#ifndef SERVERCONNECTION_H
#define SERVERCONNECTION_H

#include<QSqlDatabase>
#include<QSqlQuery>
#include<QSqlError>
#include<QSqlRecord>

#include<QDebug>


class ServerConnection: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user_name READ userName WRITE signUp)
public:
    explicit ServerConnection(QObject *parent = 0);
    bool signUp(QString &name, QString &password);
    QString userName();
private:
    QSqlDatabase database;

    QString user_name;
public slots:
};

#endif // SERVERCONNECTION_H
