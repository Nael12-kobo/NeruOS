#pragma once

#include <gio/gio.h>

#include <QAbstractListModel>
#include <QHash>
#include <QSet>
#include <QStringList>
#include <QTimer>
#include <QVector>

struct DesktopApplication {
    GAppInfo *info = nullptr;
    QString id;
    QString name;
    QString description;
    QString executable;
    QSet<qint64> processIds;
    bool trackingAvailable = false;
};

class AppCatalogModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    enum Roles {
        DisplayNameRole = Qt::UserRole + 1,
        AppIdRole,
        DescriptionRole,
        ExecutableRole,
        RunningRole,
        ProcessCountRole,
        TrackingAvailableRole
    };
    Q_ENUM(Roles)

    explicit AppCatalogModel(QObject *parent = nullptr);
    ~AppCatalogModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    int count() const;

    Q_INVOKABLE void refresh();
    Q_INVOKABLE bool launch(const QString &appId);
    Q_INVOKABLE bool launchAlias(const QString &alias);
    Q_INVOKABLE bool isRunning(const QString &appId) const;

signals:
    void countChanged();
    void launchStarted(const QString &displayName, const QString &appId);
    void launchError(const QString &displayName, const QString &message);

private slots:
    void scanProcesses();

private:
    void clearApplications();
    int indexOfId(const QString &appId) const;
    bool launchEntry(DesktopApplication &entry);
    static QString baseExecutable(const QString &path);
    static bool canTrackExecutable(const QString &executable);

    QVector<DesktopApplication> m_applications;
    QTimer m_processTimer;
};
