#ifndef MEME_H
#define MEME_H

#include <QObject>
#include <QVector>

class Meme : public QObject
{
    Q_OBJECT
public:
    explicit Meme(QObject *parent = nullptr);

    //Q_PROPERTY(QString memeName)

private:
    QString memeName;
    QVector<int> popValues;

signals:

public slots:
};

#endif // MEME_H
