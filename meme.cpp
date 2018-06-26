#include "meme.h"
#include <QDebug>

Meme::Meme()
{

}

Meme::Meme(QString memeName, QVector<int> memeValues, QString memeImageName, QString memeCategory, int memeLoyalty,
           int memeCreativity, int memeShekels, bool memeForced, int memeStartPopValue):
    name(memeName), popValues(memeValues), imageName(memeImageName), category(memeCategory), loyalty(memeLoyalty),
    creativity(memeCreativity), shekels(memeShekels), forced(memeForced), startPopValue(memeStartPopValue)
{

}


void Meme::setName(const QString &memeName){
    name = memeName;
}

void Meme::setPopValues(const QVector<int> &memePopValues){
    popValues = memePopValues;
}

void Meme::setImageName(const QString &memeImageName)
{
    imageName = memeImageName;
    qDebug()<<"image name changed: "<<imageName;
}

void Meme::setCategory(const QString &memeCategory)
{
    category = memeCategory;
}

void Meme::setLoyalty(const int &memeLoyalty){
    loyalty = memeLoyalty;
}

void Meme::setCreativity(const int &memeCreativity)
{
    creativity = memeCreativity;
}

void Meme::setShekels(const int &memeShekels)
{
    shekels = memeShekels;
}

void Meme::setForced(const bool &memeForced)
{
    forced = memeForced;
}

void Meme::setStartPopValue(const int &memeStartPopValue){
    startPopValue = memeStartPopValue;
}


QString Meme::getName(){
    return name;
}

QVector<int> Meme::getPopValues(){
    return popValues;
}

QString Meme::getImageName(){
    return imageName;
}

QString Meme::getCategory()
{
    return category;
}

int Meme::getLoyalty(){
    return loyalty;
}


int Meme::getCreativity(){
    return creativity;
}

int Meme::getShekels()
{
    return shekels;
}

bool Meme::getForced()
{
    return forced;
}

int Meme::getStartPopValue(){
    return startPopValue;
}

