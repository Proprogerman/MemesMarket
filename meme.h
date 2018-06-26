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
    Meme(QString memeName, QVector<int> memeValues, QString memeImageName, QString memeCategory, int memeLoyalty,
         int memeCreativity, bool memeForced, int memeStartPopValue = 0);

    void setName(const QString &memeName);
    void setPopValues(const QVector<int> &memePopValues);
    void setImageName(const QString &memeImageName);
    void setCategory(const QString &memeCategory);
    void setLoyalty(const int &memeLoyalty);
    void setCreativity(const int &memeCreativity);
    void setForced(const bool &memeForced);
    void setStartPopValue(const int &memeStartPopValue);

    QString getName();
    QVector<int> getPopValues();
    QString getImageName();
    QString getCategory();
    int getLoyalty();
    int getCreativity();
    bool getForced();
    int getStartPopValue();
private:
    QString name;
    QVector<int> popValues;
    QString imageName;
    QString category;
    int loyalty;
    int creativity;
    bool forced;
    int startPopValue;
};

#endif // MEME_H
