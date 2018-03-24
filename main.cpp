#include<user.h>

#include <QApplication>

#include <QQmlApplicationEngine>

#include "imageprovider.h"


int main(int argc, char *argv[])
{
    setlocale(LC_ALL,"Russian");
    QApplication app(argc, argv);

    QQmlApplicationEngine engine;

//    qmlRegisterType<ServerConnection>("io.qt.ServerConnection", 1, 0,"ServerConnection");

//    qmlRegisterSingletonType(QUrl("qrc:/qml/SingletonConnection.qml"),
//                             "io.qt.SingletonConnection",1,0,"ServerConnection");


    qmlRegisterSingletonType<User>("KlimeSoft.SingletonUser",1,0,"User", User::qmlInstance);

    engine.load(QUrl("qrc:/qml/main.qml"));

    engine.addImageProvider("meme", new ImageProvider());

    return app.exec();
}
