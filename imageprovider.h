#ifndef IMAGEPROVIDER_H
#define IMAGEPROVIDER_H

#include <QQuickImageProvider>
#include <QPixmap>

#include "user.h"


class ImageProvider : public QQuickImageProvider
{
public:
    ImageProvider();
    ~ImageProvider();
    QPixmap requestPixmap(const QString &id, QSize *size, const QSize &requestedSize);
private:
    User *user;
};

#endif // IMAGEPROVIDER_H
