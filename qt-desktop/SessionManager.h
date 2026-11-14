#pragma once

#include <QObject>
#include <QString>

class SessionManager final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString userName READ userName CONSTANT)
    Q_PROPERTY(QString sessionId READ sessionId CONSTANT)
    Q_PROPERTY(bool lockerAvailable READ lockerAvailable CONSTANT)

public:
    explicit SessionManager(QObject *parent = nullptr);

    QString userName() const;
    QString sessionId() const;
    bool lockerAvailable() const;

    Q_INVOKABLE void lockScreen();
    Q_INVOKABLE void logOut();
    Q_INVOKABLE void suspend();
    Q_INVOKABLE void restart();
    Q_INVOKABLE void powerOff();

signals:
    void actionStarted(const QString &action);
    void actionFailed(const QString &action, const QString &message);

private:
    bool runLoginctl(const QString &action, const QStringList &arguments);
    QString m_userName;
    QString m_sessionId;
    QString m_lockerPath;
    QString m_loginctlPath;
};
