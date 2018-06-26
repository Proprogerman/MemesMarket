#include <user.h>

#include <QApplication>

#include <QQmlApplicationEngine>
#include <QtQuickControls2>
#include <QQuickStyle>

#include "imageprovider.h"


int main(int argc, char *argv[])
{
    setlocale(LC_ALL,"Russian");
    QApplication app(argc, argv);

    app.setOrganizationName("KlimeSoft");
    app.setApplicationName("MemesMarket");

    QQmlApplicationEngine engine;

//    QQuickStyle::setStyle("Material");

    qmlRegisterSingletonType<User>("KlimeSoft.SingletonUser", 1, 0, "User", User::qmlInstance);

    engine.load(QUrl("qrc:/qml/main.qml"));

    engine.addImageProvider("meme", new ImageProvider());

    return app.exec();
}
