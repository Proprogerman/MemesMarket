#include "meme.h"
#include <QDebug>

Meme::Meme()
{

}

Meme::Meme(QString memeName, QVector<int> memeValues, QString memeImageName): name(memeName),
    popValues(memeValues), imageName(memeImageName)
{
    qDebug() << "Meme constructor:\n" << "name: "<< name << "\npopValues:" << popValues;
}

void Meme::setName(QString memeName)
{
    name = memeName;
}

void Meme::setPopValues(QVector<int> memePopValues)
{
    popValues = memePopValues;
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

void Meme::updatePopValues(QVector<int> &newPopValues)
{
    popValues = newPopValues;
}
