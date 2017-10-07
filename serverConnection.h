#ifndef SERVERCONNECTION_H
#define SERVERCONNECTION_H

#include <QString>
#include <QObject>

#include <QQmlEngine>
#include <QJSEngine>

#include <QDebug>

#include <QTcpSocket>

#include <QJsonObject>
#include <QJsonDocument>

class ServerConnection: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getName WRITE setName)
    Q_PROPERTY(QString user_password READ getPassword WRITE setPassword)
    //Q_PROPERTY(QString user_token READ userToken WRITE setToken)
public:
    explicit ServerConnection(QObject *parent = 0);
    Q_INVOKABLE
    void checkName(const QString &name);
    void setName(const QString &name);
    void setPassword(const QString &password);
    //void setToken(const QString &token);

    QString getName();
    QString getPassword();
    QString userToken();

    void processingResponse(QJsonObject &jsonObj);

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

private:

    QString user_name;
    QString user_password;
    QString user_token;

    QTcpSocket* clientSocket;
signals:
    void nameIsExist();
    void nameIsCorrect();
public slots:
    void signUp();
    void onReadyRead();
    void onDisconnected();
    //bool checkName(const QString &name);

};


#endif // SERVERCONNECTION_H
