#include "demoaccount.h"

#include <Accounts/Account>
#include <Accounts/AccountService>
#include <Accounts/Manager>
#include <Accounts/Provider>
#include <Accounts/Service>

#include <SignOn/Identity>
#include <SignOn/SessionData>
#include <SignOn/Error>


#include <QDebug>

QString DemoAccount::username() const
{
    return m_username;
}

QString DemoAccount::password() const
{
    return m_password;
}

DemoAccount::DemoAccount(QObject *parent)
    : QObject(parent)
{
    Accounts::Manager manager;

    Accounts::Service demoService = manager.service(QStringLiteral("demo"));
    if (!demoService.isValid()) {
        qWarning() << "Could not find DEMO service!";
        return;
    }

    Accounts::Account *demoAccount = nullptr;
    for (const Accounts::AccountId accountId: manager.accountListEnabled(QStringLiteral("sync"))) {
        Accounts::Account *account = manager.account(accountId);
        if (account->providerName() == QLatin1String("demo")) {
            demoAccount = account;
            break;
        }
    }
    if (!demoAccount) {
        qWarning() << "Could not find DEMO account!";
        return;
    }

    demoAccount->selectService(demoService);

    SignOn::Identity *demoIdentity = SignOn::Identity::existingIdentity(demoAccount->credentialsId());
    if (!demoIdentity) {
        qWarning() << "Failed to find DEMO account signon identity!";
        return;
    }

    connect(demoIdentity, &SignOn::Identity::info, [this] (const SignOn::IdentityInfo &idinfo) {
        m_username = idinfo.userName();
        emit usernameChanged(m_username);
    });

    connect(demoIdentity, &SignOn::Identity::error, [] (SignOn::Error err) {
        qWarning() << "Got SignOn::Identity error" << err.message();
    });

    demoIdentity->queryInfo();

    SignOn::AuthSessionP authSession = demoIdentity->createSession(QStringLiteral("password"));
    if (!authSession) {
        qWarning() << "Could not create auth session for identity!";
        return;
    }

    connect(authSession.data(), &SignOn::AuthSession::response, [this] (const SignOn::SessionData &data) {
        m_password = data.Secret();
        emit passwordChanged(m_password);
    });

    connect(authSession.data(), &SignOn::AuthSession::error, [] (const SignOn::Error &err) {
        qWarning() << "SignOn error!: " << err.type() << err.message();
    });

    SignOn::SessionData sessionData;
    sessionData.setUserName(m_username);
    authSession->process(sessionData, QStringLiteral("password"));
}
