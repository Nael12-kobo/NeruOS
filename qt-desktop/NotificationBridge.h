#pragma once

#include <QObject>
#include <QDBusAbstractAdaptor>
#include <QDBusConnection>
#include <QString>
#include <QVariantMap>

class NotificationAdaptor;

class NotificationBridge final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busAvailable READ busAvailable CONSTANT)

public:
    explicit NotificationBridge(QObject *parent = nullptr);

    bool busAvailable() const;

signals:
    void notificationReceived(uint id,
                              const QString &application,
                              const QString &title,
                              const QString &message,
                              const QString &timeText);
    void notificationClosed(uint id, uint reason);

private:
    friend class NotificationAdaptor;
    uint nextId();
    void close(uint id, uint reason);

    NotificationAdaptor *m_adaptor = nullptr;
    QDBusConnection m_bus = QDBusConnection::sessionBus();
    uint m_nextId = 1;
    bool m_objectRegistered = false;
    bool m_serviceRegistered = false;
};

class NotificationAdaptor final : public QDBusAbstractAdaptor
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.freedesktop.Notifications")

public:
    explicit NotificationAdaptor(NotificationBridge *parent);

public slots:
    QStringList GetCapabilities() const;
    QStringList GetServerInformation() const;
    uint Notify(const QString &appName,
                uint replacesId,
                const QString &appIcon,
                const QString &summary,
                const QString &body,
                const QStringList &actions,
                const QVariantMap &hints,
                int expireTimeout);
    void CloseNotification(uint id);

signals:
    void NotificationClosed(uint id, uint reason);
    void ActionInvoked(uint id, const QString &action);
};
