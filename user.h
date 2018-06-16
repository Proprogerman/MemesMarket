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

#include "meme.h"
#include "ad.h"

class User: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString user_name READ getName WRITE setName NOTIFY nameChanged)
//    Q_PROPERTY(QString user_password READ getPassword WRITE setPassword)
    Q_PROPERTY(int pop_values READ getUserPopValue NOTIFY popValueChanged)
    Q_PROPERTY(int creativity READ getCreativity NOTIFY creativityChanged)
    Q_PROPERTY(int shekels READ getShekels NOTIFY shekelsChanged)
public:
    explicit User(QObject *parent = 0);

    QString getName();
    QString getPassword();
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
    Q_INVOKABLE void getMemeDataForUser(const QString &memeName);
    Q_INVOKABLE void getMemeData(const QString &memeName);
    Q_INVOKABLE void getMemesCategories();
    Q_INVOKABLE void getUsersRating();
    Q_INVOKABLE void forceMeme(const QString &memeName, const int &contributedCreativity, const int &startPopValue,
                               const QString &category);
    Q_INVOKABLE void unforceMeme(const QString &memeName);
    Q_INVOKABLE void increaseLikesQuantity(const QString &memeName, const int &investedShekels);
    Q_INVOKABLE void acceptAd(const QString &adName);

    Q_INVOKABLE bool memesWithCategoryIsEmpty(const QString &category);
    Q_INVOKABLE bool adsIsEmpty();

    Q_INVOKABLE void localUpdateUserData();

    void setName(const QString &name);
    void setPasswordHash(const QString &hash);
    void setUserData(const QJsonObject &userData);
    void setMemeImage(const QJsonObject &jsonObj);
    void setAdImage(const QJsonObject &jsonObj);
    //void setUpdatedDataForMemeOfUser(const QJsonObject);
    void setMemesWithCategory(const QVariantList &memeList, const QString &category);
    void setAdList(const QVariantList &adList);
    void setMemeDataForUser(const QJsonObject &obj);
    void setMemeData(const QJsonObject &obj);
    void setUsersRating(const QJsonArray &userList, const int &userRating);

    void processingResponse(QJsonObject &jsonObj);

    void toOtherThread(const QJsonObject &jsonObj);

    Q_INVOKABLE bool findMeme(const QString &name);
    Q_INVOKABLE bool findCategoryMeme(const QString &name, const QString &category);
    Q_INVOKABLE bool findAd(const QString &name);

    int getAdIndex(const QString &name);

    Q_INVOKABLE void rewardUserWithShekels();

    QString hashPassword(const QString &password, const QString &login);

    static QObject* qmlInstance(QQmlEngine *engine, QJSEngine *scriptEngine);

private:
    QString user_name;
    QString passwordHash;
    int pop_value = 0;
    int creativity = 0;
    int shekels = 0;

    QVector<Meme> memes;
    QVector<Ad> ads;

    QVariantList categories;
    QMap<QString, QVector<Meme>> memesWithCategory;

    QTcpSocket *clientSocket;

    QSettings *settings;
signals:
    void nameExist();
    void nameDoesNotExist();

    void nameChanged();
    void popValueChanged();
    void creativityChanged();
    void shekelsChanged();

    void signUpAnswered(QString name, bool created);
    void signInAnswered(QString name, bool accessed);

    void memeForUserReceived(QString memeName, QString imageName, QVector<int> popValues, int startPopValue,
                             double memeFeedbackRate, int memeCreativity);
    void memeImageReceived(QString memeName, QString imageName);
    void adImageReceived(QString adName, QString imageName);
    void memeReceived(QString memeName, QString imageName, QVector<int> popValues);
    void memeWithCategoryReceived(QString memeName, QString imageName, QVector<int> popValues, QString category);
    void adReceived(QString adName, QString imageName, QString reputation, int profit, int discontented,
                    int secondsToReady = 0);
    void memePopValuesForUserUpdated(QString memeName, QVector<int> popValues, int startPopValue,
                                     double memeFeedbackRate, int memeCreativity);
    void memePopValuesUpdated(QString memeName, QVector<int> popValues);
    void memePopValuesWithCategoryUpdated(QString memeName, QVector<int> popValues, QString category);
    void adUpdated(QString adName, QString reputation, int profit, int discontented, int secondsToReady = 0);
    void memesCategoriesReceived(QVariantList memesCategories);
    void usersRatingReceived(QVariantList usersList, int userRating);
    void memeUnforced(QString memeName);
public slots:
    void onReadyRead();
    void onDisconnected();
    void storeUserSettings(QString name, bool isSigned);
};


#endif // USER_H
