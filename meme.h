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
    Meme(QString memeName, QVector<int> memeValues, QString memeImageName, int memeStartPopValue = 0,
         double memeCreativity = 0, double memeFeedbackRate = 0);

    void setName(const QString &memeName);
    void setPopValues(const QVector<int> &memePopValues);
    void setStartPopValue(const int &memeStartPopValue);

    QString getName();
    QVector<int> getPopValues();
    QString getImageName();
    int getStartPopValue();
    int getCreativity();
    double getFeedbackRate();
private:
    QString name;
    QVector<int> popValues;
    QString imageName;
    int startPopValue;
    int creativity;
    double feedbackRate;
};

#endif // MEME_H
