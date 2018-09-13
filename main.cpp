#include <user.h>

#include <QApplication>
#include <QQmlApplicationEngine>

#include <QSettings>
#include <QScreen>

#include "imageprovider.h"


int main(int argc, char *argv[])
{
    setlocale(LC_ALL, "Russian");
    QApplication app(argc, argv);

    app.setOrganizationName("KlimeSoft");
    app.setApplicationName("MemesMarket");

    QQmlApplicationEngine engine;

    qmlRegisterSingletonType<User>("KlimeSoft.SingletonUser", 1, 0, "User", User::qmlInstance);

    engine.addImageProvider("meme", new ImageProvider());

    QSettings settings;
    settings.setValue("device/screen/width", QApplication::screens().at(0)->size().width());
    settings.setValue("device/screen/height", QApplication::screens().at(0)->size().height());
    engine.load(QUrl("qrc:/qml/main.qml"));

    return app.exec();
}
