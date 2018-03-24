#ifndef INDEPENDENTCONNECTION_H
#define INDEPENDENTCONNECTION_H

#include <QObject>
#include <QJsonObject>

class IndependentConnection : public QObject
{
    Q_OBJECT
public:
    explicit IndependentConnection(QObject *parent = nullptr);

    void setMemeImage(const QJsonObject &jsonObj);

private:

signals:
    void finished();
    void memeImageReceived(QString memeName, QString imageName);

public slots:
    void processingResponse(const QJsonObject &jsonObj);
};

#endif // INDEPENDENTCONNECTION_H
