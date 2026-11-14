#pragma once

#include <QObject>
#include <QSettings>
#include <QStringList>

class DesktopSettings final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString wallpaperPath READ wallpaperPath NOTIFY wallpaperPathChanged)
    Q_PROPERTY(QStringList pinnedApps READ pinnedApps NOTIFY pinnedAppsChanged)
    Q_PROPERTY(int accentIndex READ accentIndex WRITE setAccentIndex NOTIFY accentIndexChanged)
    Q_PROPERTY(bool darkMode READ darkMode WRITE setDarkMode NOTIFY darkModeChanged)

public:
    explicit DesktopSettings(QObject *parent = nullptr);

    QString wallpaperPath() const;
    QStringList pinnedApps() const;
    int accentIndex() const;
    bool darkMode() const;

    Q_INVOKABLE void setWallpaperPath(const QString &path);
    Q_INVOKABLE void resetWallpaper();
    Q_INVOKABLE bool isPinned(const QString &alias) const;
    Q_INVOKABLE void togglePinned(const QString &alias);
    Q_INVOKABLE void setPinnedApps(const QStringList &apps);
    Q_INVOKABLE void resetPreferences();

public slots:
    void setAccentIndex(int index);
    void setDarkMode(bool enabled);

signals:
    void wallpaperPathChanged();
    void pinnedAppsChanged();
    void accentIndexChanged();
    void darkModeChanged();

private:
    QSettings m_settings;
    static QStringList defaultPinnedApps();
};
