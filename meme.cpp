#include "meme.h"
#include <QDebug>

Meme::Meme()
{

}

Meme::Meme(QString memeName, QVector<int> memeValues, QString memeImageName, QString memeCategory, int memeLoyalty,
           int memeCreativity,  bool memeForced, int memeStartPopValue):
    name(memeName), popValues(memeValues), imageName(memeImageName), category(memeCategory), loyalty(memeLoyalty),
    creativity(memeCreativity), forced(memeForced), startPopValue(memeStartPopValue)
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

int Meme::getCreativity()
{
    return creativity;
}

bool Meme::getForced()
{
    return forced;
}

int Meme::getStartPopValue(){
    return startPopValue;
}

