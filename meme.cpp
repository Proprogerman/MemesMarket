#include "meme.h"
#include <QDebug>

Meme::Meme()
{

}

Meme::Meme(QString memeName, QVector<int> memeValues, QString memeImageName, int memeStartPopValue,
           double memeCreativity, double memeFeedbackRate):
    name(memeName), popValues(memeValues), imageName(memeImageName),
    startPopValue(memeStartPopValue), creativity(memeCreativity), feedbackRate(memeFeedbackRate)
{
    qDebug() << "Meme constructor:\n" << "name: "<< name << "\npopValues:" << popValues;
}

void Meme::setName(const QString &memeName)
{
    name = memeName;
}

void Meme::setPopValues(const QVector<int> &memePopValues)
{
    popValues = memePopValues;
    qDebug()<<"MEME: "<<getName()<<"SET POP VALUES: "<<memePopValues;
}

void Meme::setStartPopValue(const int &memeStartPopValue)
{
    startPopValue = memeStartPopValue;
}

QString Meme::getName()
{
    return name;
}

QVector<int> Meme::getPopValues()
{
    return popValues;
}

QString Meme::getImageName()
{
    return imageName;
}

int Meme::getStartPopValue()
{
    return startPopValue;
}

int Meme::getCreativity()
{
    return creativity;
}

double Meme::getFeedbackRate()
{
    return feedbackRate;
}
