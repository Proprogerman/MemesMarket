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
    Meme(QString memeName, QVector<int> memeValues, QString memeImagePath);

    void setName(QString memeName);
    void setPopValues(QVector<int> memePopValues);
private:
    QString name;
    QVector<int> popValues;
    QString imagePath;
};

#endif // MEME_H
