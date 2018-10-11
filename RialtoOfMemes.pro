QT += network sql charts qml quick svg
TRANSLATIONS = t1_en.ts

QTFIREBASE_SDK_PATH = C:/Development/firebase_cpp_sdk

include(deployment.pri)

RESOURCES += \
    assets/qrc.qrc \
    qmlres/qml.qrc \
    data.qrc

SOURCES += main.cpp \
    user.cpp \
    meme.cpp \
    imageprovider.cpp \
    ad.cpp \
    translator.cpp

android {
    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
    OTHER_FILES += android/AndroidManifest.xml       android/build.gradle
    DISTFILES += android/google-services.json
}

ios {
    QMAKE_INFO_PLIST = ios/Project-Info.plist
    OTHER_FILES += $$QMAKE_INFO_PLIST
}

win32 {
    RC_FILE += win/app_icon.rc
}
macx {
    ICON = macx/app_icon.icns
}

HEADERS += \
    user.h \
    meme.h \
    imageprovider.h \
    ad.h \
    translator.h

DISTFILES += \
    android/AndroidManifest.xml \
    android/gradle/wrapper/gradle-wrapper.jar \
    android/gradlew \
    android/res/values/libs.xml \
    android/build.gradle \
    android/gradle/wrapper/gradle-wrapper.properties \
    android/gradlew.bat \
    appData.json


GIT_VERSION_ROOT = $$PWD/..
include(extensions/gitversion.pri)

QTFIREBASE_CONFIG += analytics messaging admob remote_config auth database
include(extensions/QtFirebase/qtfirebase.pri)
