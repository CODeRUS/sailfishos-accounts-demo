TARGET = sailfishos-accounts-demo

CONFIG += sailfishapp
PKGCONFIG += \
    accounts-qt5 \
    libsignon-qt5

SOURCES += src/sailfishos-accounts-demo.cpp \
    src/demoaccount.cpp

HEADERS += \
    src/demoaccount.h

DISTFILES += qml/sailfishos-accounts-demo.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/sailfishos-accounts-demo.spec \
    sailfishos-accounts-demo.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

accounts.files = accounts
accounts.path = /usr/share
INSTALLS += accounts

INCLUDEPATH += /usr/include
INCLUDEPATH += /usr/include/accounts-qt5
INCLUDEPATH += /usr/include/signon-qt5

