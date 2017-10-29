#include<serverConnection.h>

#include <QApplication>

#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
    setlocale(LC_ALL,"Russian");
    QApplication app(argc, argv);
//    VPApplication vplay;
    QQmlApplicationEngine engine;

    // Use platform-specific fonts instead of V-Play's default font
//    vplay.setPreservePlatformFonts(true);

//    QQmlApplicationEngine engine;
//    vplay.initialize(&engine);

    // use this during development
    // for PUBLISHING, use the entry point below
//    vplay.setMainQmlFileName(QStringLiteral("qrc:/qml/main.qml"));
    //engine.setMainQmlFileName(QStringLiteral("qrc:/qml/main.qml"));

    // use this instead of the above call to avoid deployment of the qml files and compile them into the binary with qt's resource system qrc
    // this is the preferred deployment option for publishing games to the app stores, because then your qml files and js files are protected
    // to avoid deployment of your qml files and images, also comment the DEPLOYMENTFOLDERS command in the .pro file
    // also see the .pro file for more details
    // vplay.setMainQmlFileName(QStringLiteral("qrc:/qml/Main.qml"));

//    qmlRegisterType<ServerConnection>("io.qt.ServerConnection", 1, 0,"ServerConnection");

//    qmlRegisterSingletonType(QUrl("qrc:/qml/SingletonConnection.qml"),
//                             "io.qt.SingletonConnection",1,0,"ServerConnection");


    qmlRegisterSingletonType<ServerConnection>("io.qt.SingletonConnection",1,0,"ServerConnection",
                                               ServerConnection::qmlInstance);

    engine.load(QUrl("qrc:/qml/main.qml"));

    return app.exec();
}
