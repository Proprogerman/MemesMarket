#ifndef TRANSLATOR_H
#define TRANSLATOR_H

#include <QObject>
#include <QTranslator>
#include <QApplication>

class Translator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString emptyString READ getEmptyString NOTIFY languageChanged)
public:
    explicit Translator(QObject *parent = nullptr);
    QString getEmptyString();
    Q_INVOKABLE void selectLanguage(QString language);
signals:
    void languageChanged();
private:
    QString emptyString;
    QTranslator *enTranslator;
};

#endif // TRANSLATOR_H
