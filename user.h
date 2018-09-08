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

#include <QTimer>

#include <QSettings>

#include <QThreadPool>

#include <QNetworkAccessManager>
#include <QNetworkReply>

#include "meme.h"
#include "ad.h"

class User: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getName WRITE setName NOTIFY nameChanged)
    Q_PROPERTY(int pop_values READ getUserPopValue NOTIFY popValueChanged)
    Q_PROPERTY(int creativity READ getCreativity NOTIFY creativityChanged)
    Q_PROPERTY(int shekels READ getShekels NOTIFY shekelsChanged)
public:
    explicit User(QObject *parent = 0);
    ~User();

    QString getName();
    int getUserPopValue();
    int getCreativity();
    int getShekels();

    Q_INVOKABLE void checkName(const QString &name);
    Q_INVOKABLE void signUp(const QString &name, const QString &password);
    Q_INVOKABLE void signIn(const QString &name, const QString &password);
    Q_INVOKABLE void autoSignIn();
    Q_INVOKABLE void signOut();
    Q_INVOKABLE void getUserData();
    Q_INVOKABLE void setExistingMemeListWithCategory(const QString &category);
    Q_INVOKABLE void setExistingAdList();
    Q_INVOKABLE void getMemeListWithCategory(const QString &category);
    Q_INVOKABLE void getAdList();
    Q_INVOKABLE void getMemeData(const QString &memeName);
    Q_INVOKABLE void getMemesCategories();
    Q_INVOKABLE void getUsersRating();
    Q_INVOKABLE void forceMeme(const QString &memeName, const int &contributedCreativity, const int &startPopValue);
    Q_INVOKABLE void unforceMeme(const QString &memeName);
    Q_INVOKABLE void increaseLikesQuantity(const QString &memeName, const int &investedShekels);
    Q_INVOKABLE void acceptAd(const QString &adName);

    Q_INVOKABLE bool memesWithCategoryIsEmpty(const QString &category);
    Q_INVOKABLE bool adsIsEmpty();

    Q_INVOKABLE void localUpdateUserData();
    Q_INVOKABLE void localUpdateMeme(const QString &memeName);

    void setName(const QString &name);
    void setPasswordHash(const QString &hash);
    void setUserData(const QJsonObject &userData);
    void imageToThread(const QJsonObject &jsonObj);
    void setMemeImage(const QJsonObject &jsonObj);
    void setAdImage(const QJsonObject &jsonObj);
    void setUserImage(const QJsonObject &jsonObj);
    void setMemesWithCategory(const QVariantList &memeList, const QString &category);
    void setAdList(const QVariantList &adList);
    void setMemeData(const QJsonObject &obj);
    void setUsersRating(const QJsonArray &userList, const int &userRating);

    void setMeme(const QString &memeName, const QVector<int> &memeValues, const QString &memeImageName,
                 const QString &memeCategory, const int &memeLoyalty, const int &memeCreativity,
                 const bool &forced, const int &memeStartPopValue);

    void processingResponse(QJsonObject &jsonObj);

    void toOtherThread(const QJsonObject &jsonObj);

    Q_INVOKABLE bool findMeme(const QString &name);
    Q_INVOKABLE bool findCategoryMeme(const QString &name, const QString &category);
    Q_INVOKABLE bool findAd(const QString &name);

    int getAdIndex(const QString &name);

    Q_INVOKABLE void rewardUserWithShekels();

    QString hashPassword(const QString &password, const QString &login);

    Q_INVOKABLE void connectToHost();
    bool socketIsReady();
    bool writeData(const QByteArray &data);

    quint32 arrayToInt(QByteArray dataSize);
    QByteArray intToArray(const quint32 &dataSize);

    QJsonArray getLocalImagesList();

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

private:
    QString user_name;
    QString passwordHash;
    QString user_imageName;
    int pop_value = 0;
    int creativity = 0;
    int shekels = 0;

    QVector<Meme> memes;
    QVector<Ad> ads;

    QVariantList categories;

    QTcpSocket *clientSocket = nullptr;
    QTimer *timer;

    QSettings *settings;

    QThreadPool *imgPool;

    QNetworkAccessManager *mngr;
signals:
    void nameExist();
    void nameDoesNotExist();

    void nameChanged();
    void popValueChanged();
    void creativityChanged();
    void shekelsChanged();

    void signAnswered(QString name, bool progress);

    void imageReceived(QString type, QString name, QString imageName);
    void memeReceived(QString memeName, QVector<int> popValues, int loyalty, QString category = "", QString imageName = "",
                      int memeCreativity = 0, int startPopValue = 0);
    void adReceived(QString adName, QString imageName, QString reputation, int profit, int discontented,
                    int secondsToReady = 0);
    void memePopValuesUpdated(QString memeName, QVector<int> popValues, int loyalty);
    void memesCategoriesReceived(QVariantList memesCategories);
    void usersRatingReceived(QVariantList usersList, int userRating);
    void memeUnforced(QString memeName);
public slots:
    void onReadyRead();
    void onDisconnected();
    void storeUserSettings(QString name, bool isSigned);
    void getImageFromVk(QNetworkReply *reply, QString type, QString itemName, QString imageName);
};


#endif // USER_H
