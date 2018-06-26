#ifndef IMAGERUNNABLE_H
#define IMAGERUNNABLE_H

#include <QObject>
#include <QRunnable>
#include <QJsonObject>


class ImageRunnable : public QObject, public QRunnable
{
    Q_OBJECT
public:
    explicit ImageRunnable(QObject *parent = nullptr);
    void run();
    void setMemeImageObj(QJsonObject jsonObj);

private:
    QJsonObject imageObj;
signals:
    void imageReceived(QString type, QString name, QString imageName);
};

#endif // IMAGERUNNABLE_H
