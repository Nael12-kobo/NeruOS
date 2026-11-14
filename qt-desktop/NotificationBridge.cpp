#include "NotificationBridge.h"

#include <QDateTime>
#include <QDBusConnectionInterface>

NotificationBridge::NotificationBridge(QObject *parent)
    : QObject(parent)
{
    m_adaptor = new NotificationAdaptor(this);

    m_objectRegistered = m_bus.registerObject(
        QStringLiteral("/org/freedesktop/Notifications"),
        this,
        QDBusConnection::ExportAdaptors);

    if (m_objectRegistered) {
        m_serviceRegistered = m_bus.registerService(
            QStringLiteral("org.freedesktop.Notifications"));
    }
}

bool NotificationBridge::busAvailable() const
{
    return m_objectRegistered && m_serviceRegistered;
}

uint NotificationBridge::nextId()
{
    if (m_nextId == 0)
        m_nextId = 1;
    return m_nextId++;
}

void NotificationBridge::close(uint id, uint reason)
{
    emit notificationClosed(id, reason);
}

NotificationAdaptor::NotificationAdaptor(NotificationBridge *parent)
    : QDBusAbstractAdaptor(parent)
{
    setAutoRelaySignals(true);
}

QStringList NotificationAdaptor::GetCapabilities() const
{
    return {
        QStringLiteral("body")
    };
}

QStringList NotificationAdaptor::GetServerInformation() const
{
    return {
        QStringLiteral("NeruOS"),
        QStringLiteral("NeruOS Project"),
        QStringLiteral("0.4.0-alpha2"),
        QStringLiteral("1.2")
    };
}

uint NotificationAdaptor::Notify(const QString &appName,
                                 uint replacesId,
                                 const QString &appIcon,
                                 const QString &summary,
                                 const QString &body,
                                 const QStringList &actions,
                                 const QVariantMap &hints,
                                 int expireTimeout)
{
    Q_UNUSED(appIcon)
    Q_UNUSED(actions)
    Q_UNUSED(hints)
    Q_UNUSED(expireTimeout)

    auto *bridge = qobject_cast<NotificationBridge *>(parent());
    if (!bridge)
        return 0;

    const uint id = replacesId ? replacesId : bridge->nextId();
    const QString application = appName.trimmed().isEmpty()
        ? QStringLiteral("Application") : appName.trimmed();
    const QString title = summary.trimmed().isEmpty()
        ? application : summary.trimmed();
    const QString timeText = QDateTime::currentDateTime().toString(QStringLiteral("hh:mm"));

    emit bridge->notificationReceived(id, application, title, body, timeText);
    return id;
}

void NotificationAdaptor::CloseNotification(uint id)
{
    auto *bridge = qobject_cast<NotificationBridge *>(parent());
    if (!bridge)
        return;

    bridge->close(id, 3);
    emit NotificationClosed(id, 3);
}
