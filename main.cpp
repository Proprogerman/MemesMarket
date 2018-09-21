#include <user.h>

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QSettings>
#include <QScreen>

#include "imageprovider.h"
#include "translator.h"


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

    Translator trans;
    QString userLang = settings.value("user/language").toString();
    QString systemLang = QLocale::system().name().left(2) == "ru" ? "ru" : "en";
    QString lang = userLang.isNull() ? systemLang : userLang;
    settings.setValue("user/language", lang);
    trans.selectLanguage(lang);
    engine.rootContext()->setContextProperty("translator", (QObject*)&trans);

    engine.load(QUrl("qrc:/qml/main.qml"));

    return app.exec();
}
