#include "meme.h"
#include <QDebug>

Meme::Meme()
{

}

Meme::Meme(QString memeName, QVector<int> memeValues, QString memeImagePath): name(memeName),
    popValues(memeValues), imagePath(memeImagePath)
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
