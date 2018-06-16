#ifndef AD_H
#define AD_H

#include <QObject>

class Ad
{
public:
    Ad();
    Ad(QString adName, QString adImageName, QString adReputation, int adProfit, int adDiscontented, int adSecondsToReady);

    void setName(const QString &mName);
    void setImageName(const QString &mImageName);
    void setReputation(const QString &mReputation);
    void setProfit(const int &mProfit);
    void setDiscontented(const int &mDiscontented);
    void setSecondsToReady(const int mSecondsToReady);

    QString getName();
    QString getImageName();
    QString getReputation();
    int getProfit();
    int getDiscontented();
    int getSecondsToReady();
private:
    QString name;
    QString imageName;
    QString reputation;
    int profit;
    int discontented;
    int secondsToReady;
};

#endif // AD_H
