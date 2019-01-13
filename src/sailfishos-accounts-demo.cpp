#include <QtQuick>
#include <sailfishapp.h>

#include "demoaccount.h"

int main(int argc, char *argv[])
{
    qmlRegisterType<DemoAccount>("org.coderus.test", 1, 0, "DemoAccount");
    return SailfishApp::main(argc, argv);
}
