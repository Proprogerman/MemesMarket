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

#include <QVector>

#include "meme.h"

class User: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(QString user_password READ getPassword WRITE setPassword)
public:
    explicit User(QObject *parent = 0);

    QString getName();
    QString getPassword();

    void setName(const QString &name);
    void setPassword(const QString &password);
    void setMemesOfUser(const QVariantList &memeList);
    void setUpdatedDataForMemeOfUser(const QJsonObject);
    void setMemesWithCategory(const QVariantList &memeList, const QString &category);

    void processingResponse(QJsonObject &jsonObj);

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

    Q_INVOKABLE void checkName(const QString &name);
    Q_INVOKABLE void signUp();
    Q_INVOKABLE void getMemeListOfUser();
    Q_INVOKABLE void setExistingMemeListWithCategory(const QString &category);
    Q_INVOKABLE void getMemeListWithCategory(const QString &category);
    Q_INVOKABLE void getMemeDataForUser(const QString &memeName);
    Q_INVOKABLE void getMemesCategories();

    Q_INVOKABLE bool memesWithCategoryIsEmpty(const QString &category);

private:

    QString user_name;
    QString user_password;

    QVector<Meme> memes;
    QVariantList categories;
    QMap<QString, QVector<Meme>> memesWithCategory;

    QTcpSocket* clientSocket;
signals:
    void nameIsExist();
    void nameIsCorrect();

    void nameChanged();

    void memeForUserReceived(QString memeName, QString imageName, QVector<int> popValues, int startPopValue);
    void memeWithCategoryReceived(QString memeName, QString imageName, QVector<int> popValues, QString category);
    void memePopValuesForUserUpdated(QString memeName, QVector<int> popValues, int startPopValue);
    void memePopValuesWithCategoryUpdated(QString memeName, QVector<int> popValues, QString category);
    void memesCategoriesReceived(QVariantList memesCategories);
public slots:
    void onReadyRead();
    void onDisconnected();
};


#endif // USER_H
