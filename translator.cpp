#include "translator.h"
#include <QDebug>

Translator::Translator(QObject *parent) : QObject(parent)
{
    enTranslator = new QTranslator(this);
}

QString Translator::getEmptyString()
{
    return "";
}

void Translator::selectLanguage(QString language)
{
    if(language == QString("en")){
        enTranslator->load("t1_en", ":/translations/");
        qApp->installTranslator(enTranslator);
    }
    else if(language == QString("ru")){
        qApp->removeTranslator(enTranslator);
    }
    emit languageChanged();
}
