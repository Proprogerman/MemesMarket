#ifndef SERVERCONNECTION_H
#define SERVERCONNECTION_H

#include<QSqlDatabase>
#include<QSqlQuery>
#include<QSqlError>
#include<QSqlRecord>
#include<QString>
#include<QObject>

#include<QQmlEngine>
#include<QJSEngine>

#include<QDebug>

class ServerConnection: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getName WRITE setName)
    Q_PROPERTY(QString user_password READ getPassword WRITE setPassword)
    //Q_PROPERTY(QString user_token READ userToken WRITE setToken)
public:
    explicit ServerConnection(QObject *parent = 0);

    void setName(const QString &name);
    void setPassword(const QString &password);
    //void setToken(const QString &token);

    QString getName();
    QString getPassword();
    QString userToken();

    static QObject *qobject_singleton_provider(QQmlEngine *engine, QJSEngine *scriptEngine);
private:
    QSqlDatabase database;

    QString user_name;
    QString user_password;
    QString user_token;
public slots:
    void signUp();
    //bool checkName(const QString &name);
signals:
    void nameIsExist();
    void nameIsCorrect();
};


#endif // SERVERCONNECTION_H
