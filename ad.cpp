#include "ad.h"
#include <QDebug>

Ad::Ad()
{

}

Ad::Ad(QString adName, QString adImageName, QString adReputation, int adProfit, int adDiscontented, int adSecondsToReady):
    name(adName), imageName(adImageName), reputation(adReputation), profit(adProfit), discontented(adDiscontented),
    secondsToReady(adSecondsToReady)
{
    qDebug()<<secondsToReady;
}

void Ad::setName(const QString &mName)
{
    name = mName;
}

void Ad::setImageName(const QString &mImageName)
{
    imageName = mImageName;
}

void Ad::setReputation(const QString &mReputation)
{
    reputation = mReputation;
}

void Ad::setProfit(const int &mProfit)
{
    profit = mProfit;
}

void Ad::setDiscontented(const int &mDiscontented)
{
    discontented = mDiscontented;
}

void Ad::setSecondsToReady(const int mSecondsToReady)
{
    secondsToReady = mSecondsToReady;
}

QString Ad::getName()
{
    return name;
}

QString Ad::getImageName()
{
    return imageName;
}

QString Ad::getReputation()
{
    return reputation;
}

int Ad::getProfit()
{
    return profit;
}

int Ad::getDiscontented(){
    return discontented;
}

int Ad::getSecondsToReady()
{
    return secondsToReady;
}
