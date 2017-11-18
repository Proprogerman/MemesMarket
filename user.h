#ifndef USER_H
#define USER_H

#include <QString>
#include <QObject>

#include <QQmlEngine>
#include <QJSEngine>

#include <QDebug>

#include <QTcpSocket>

#include <QJsonObject>
#include <QJsonDocument>

class User: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getName WRITE setName)
    Q_PROPERTY(QString user_password READ getPassword WRITE setPassword)
public:
    explicit User(QObject *parent = 0);

    QString getName();
    QString getPassword();

    void setName(const QString &name);
    void setPassword(const QString &password);

    void processingResponse(QJsonObject &jsonObj);

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE void checkName(const QString &name);
    Q_INVOKABLE void signUp();
    Q_INVOKABLE void getMemeList();
    Q_INVOKABLE void getMeme(QString &meme_name);


private:

    QString user_name;
    QString user_password;

    QTcpSocket* clientSocket;
signals:
    void nameIsExist();
    void nameIsCorrect();
public slots:
    void onReadyRead();
    void onDisconnected();

};


#endif // USER_H
