#include "DesktopSettings.h"

#include <QFileInfo>
#include <QUrl>

DesktopSettings::DesktopSettings(QObject *parent)
    : QObject(parent),
      m_settings(QStringLiteral("NeruOS"), QStringLiteral("Nebula"))
{
    if (!m_settings.contains(QStringLiteral("dock/pinnedApps")))
        m_settings.setValue(QStringLiteral("dock/pinnedApps"), defaultPinnedApps());
    if (!m_settings.contains(QStringLiteral("appearance/accentIndex")))
        m_settings.setValue(QStringLiteral("appearance/accentIndex"), 0);
    if (!m_settings.contains(QStringLiteral("appearance/darkMode")))
        m_settings.setValue(QStringLiteral("appearance/darkMode"), true);
}

QStringList DesktopSettings::defaultPinnedApps()
{
    return {
        QStringLiteral("NeruFiles"),
        QStringLiteral("NeruBrowser"),
        QStringLiteral("NeruTerminal"),
        QStringLiteral("NeruCode"),
        QStringLiteral("NeruSettings")
    };
}

QString DesktopSettings::wallpaperPath() const
{
    return m_settings.value(QStringLiteral("appearance/wallpaperPath")).toString();
}

QStringList DesktopSettings::pinnedApps() const
{
    return m_settings.value(QStringLiteral("dock/pinnedApps"), defaultPinnedApps()).toStringList();
}

int DesktopSettings::accentIndex() const
{
    return m_settings.value(QStringLiteral("appearance/accentIndex"), 0).toInt();
}

bool DesktopSettings::darkMode() const
{
    return m_settings.value(QStringLiteral("appearance/darkMode"), true).toBool();
}

void DesktopSettings::setWallpaperPath(const QString &path)
{
    const QString localPath = QUrl(path).isLocalFile() ? QUrl(path).toLocalFile() : path;
    if (localPath.isEmpty() || !QFileInfo::exists(localPath))
        return;
    if (wallpaperPath() == localPath)
        return;
    m_settings.setValue(QStringLiteral("appearance/wallpaperPath"), localPath);
    m_settings.sync();
    emit wallpaperPathChanged();
}

void DesktopSettings::resetWallpaper()
{
    if (wallpaperPath().isEmpty())
        return;
    m_settings.remove(QStringLiteral("appearance/wallpaperPath"));
    m_settings.sync();
    emit wallpaperPathChanged();
}

bool DesktopSettings::isPinned(const QString &alias) const
{
    return pinnedApps().contains(alias);
}

void DesktopSettings::togglePinned(const QString &alias)
{
    QStringList apps = pinnedApps();
    if (apps.contains(alias))
        apps.removeAll(alias);
    else
        apps.push_back(alias);
    setPinnedApps(apps);
}

void DesktopSettings::setPinnedApps(const QStringList &apps)
{
    static const QStringList allowed = {
        QStringLiteral("NeruFiles"), QStringLiteral("NeruBrowser"),
        QStringLiteral("NeruTerminal"), QStringLiteral("NeruCode"),
        QStringLiteral("NeruSettings"), QStringLiteral("NeruSearch"),
        QStringLiteral("Steam")
    };

    QStringList cleaned;
    for (const QString &app : apps) {
        if (allowed.contains(app) && !cleaned.contains(app))
            cleaned.push_back(app);
    }

    if (cleaned == pinnedApps())
        return;

    m_settings.setValue(QStringLiteral("dock/pinnedApps"), cleaned);
    m_settings.sync();
    emit pinnedAppsChanged();
}

void DesktopSettings::setAccentIndex(int index)
{
    const int safeIndex = qBound(0, index, 3);
    if (accentIndex() == safeIndex)
        return;
    m_settings.setValue(QStringLiteral("appearance/accentIndex"), safeIndex);
    m_settings.sync();
    emit accentIndexChanged();
}

void DesktopSettings::setDarkMode(bool enabled)
{
    if (darkMode() == enabled)
        return;
    m_settings.setValue(QStringLiteral("appearance/darkMode"), enabled);
    m_settings.sync();
    emit darkModeChanged();
}

void DesktopSettings::resetPreferences()
{
    m_settings.remove(QStringLiteral("appearance"));
    m_settings.remove(QStringLiteral("dock"));
    m_settings.sync();
    m_settings.setValue(QStringLiteral("dock/pinnedApps"), defaultPinnedApps());
    m_settings.setValue(QStringLiteral("appearance/accentIndex"), 0);
    m_settings.setValue(QStringLiteral("appearance/darkMode"), true);
    m_settings.sync();
    emit wallpaperPathChanged();
    emit pinnedAppsChanged();
    emit accentIndexChanged();
    emit darkModeChanged();
}
