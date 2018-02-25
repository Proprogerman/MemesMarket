#ifndef MEME_H
#define MEME_H

#include <QObject>
#include <QVector>
#include <QList>
#include <QJsonArray>

class Meme
{
public:
    Meme();
    Meme(QString memeName, QVector<int> memeValues, QString memeImageName);

    void setName(QString memeName);
    void setPopValues(QVector<int> memePopValues);
    QString getName();
    QVector<int> getPopValues();
    QString getImageName();
    void updatePopValues(QVector<int> &newPopValues);
private:
    QString name;
    QVector<int> popValues;
    QString imageName;
};

#endif // MEME_H
