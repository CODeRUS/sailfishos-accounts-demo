#ifndef DEMOACCOUNT_H
#define DEMOACCOUNT_H

#include <QObject>

class DemoAccount : public QObject
{
    Q_OBJECT
public:
    Q_PROPERTY(QString username READ username NOTIFY usernameChanged)
    QString username() const;

    Q_PROPERTY(QString password READ password NOTIFY passwordChanged)
    QString password() const;

    explicit DemoAccount(QObject *parent = nullptr);

signals:
    void usernameChanged(const QString &username);
    void passwordChanged(const QString &password);

private:
    QString m_username;
    QString m_password;
};

#endif // DEMOACCOUNT_H
