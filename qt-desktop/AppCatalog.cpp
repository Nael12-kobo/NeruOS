#include "AppCatalog.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSet>
#include <QVariant>

#include <algorithm>

AppCatalogModel::AppCatalogModel(QObject *parent)
    : QAbstractListModel(parent)
{
    refresh();

    m_processTimer.setInterval(2500);
    m_processTimer.setTimerType(Qt::CoarseTimer);
    connect(&m_processTimer, &QTimer::timeout,
            this, &AppCatalogModel::scanProcesses);
    m_processTimer.start();
    scanProcesses();
}

AppCatalogModel::~AppCatalogModel()
{
    clearApplications();
}

int AppCatalogModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_applications.size();
}

QVariant AppCatalogModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 ||
        index.row() >= m_applications.size()) {
        return {};
    }

    const DesktopApplication &entry = m_applications.at(index.row());
    switch (role) {
    case DisplayNameRole:
        return entry.name;
    case AppIdRole:
        return entry.id;
    case DescriptionRole:
        return entry.description;
    case ExecutableRole:
        return entry.executable;
    case RunningRole:
        return !entry.processIds.isEmpty();
    case ProcessCountRole:
        return entry.processIds.size();
    case TrackingAvailableRole:
        return entry.trackingAvailable;
    default:
        return {};
    }
}

QHash<int, QByteArray> AppCatalogModel::roleNames() const
{
    return {
        {DisplayNameRole, "displayName"},
        {AppIdRole, "appId"},
        {DescriptionRole, "description"},
        {ExecutableRole, "executable"},
        {RunningRole, "running"},
        {ProcessCountRole, "processCount"},
        {TrackingAvailableRole, "trackingAvailable"}
    };
}

int AppCatalogModel::count() const
{
    return m_applications.size();
}

QStringList AppCatalogModel::runningAliases() const
{
    return m_runningAliases;
}

void AppCatalogModel::clearApplications()
{
    for (DesktopApplication &entry : m_applications) {
        if (entry.info)
            g_object_unref(entry.info);
        entry.info = nullptr;
    }
    m_applications.clear();
}

void AppCatalogModel::refresh()
{
    beginResetModel();
    clearApplications();

    GList *allApps = g_app_info_get_all();
    for (GList *item = allApps; item; item = item->next) {
        auto *info = G_APP_INFO(item->data);
        if (!info || !g_app_info_should_show(info))
            continue;

        const char *rawName = g_app_info_get_display_name(info);
        if (!rawName || !*rawName)
            rawName = g_app_info_get_name(info);
        const char *rawId = g_app_info_get_id(info);
        const char *rawExec = g_app_info_get_executable(info);
        if (!rawName || !*rawName || !rawId || !*rawId || !rawExec || !*rawExec)
            continue;

        DesktopApplication entry;
        entry.info = G_APP_INFO(g_object_ref(info));
        entry.id = QString::fromUtf8(rawId);
        entry.name = QString::fromUtf8(rawName);
        entry.executable = QString::fromUtf8(rawExec);
        const char *rawDescription = g_app_info_get_description(info);
        if (rawDescription)
            entry.description = QString::fromUtf8(rawDescription);

        m_applications.push_back(std::move(entry));
    }
    g_list_free_full(allApps, g_object_unref);

    std::sort(m_applications.begin(), m_applications.end(),
              [](const DesktopApplication &left, const DesktopApplication &right) {
                  return left.name.localeAwareCompare(right.name) < 0;
              });

    // Only report process status when the desktop entry points to a
    // distinctive executable. Generic launchers and duplicate executables
    // cannot reliably identify one specific application.
    QHash<QString, int> executableCounts;
    for (const DesktopApplication &entry : m_applications) {
        const QString executable = baseExecutable(entry.executable);
        if (canTrackExecutable(executable))
            ++executableCounts[executable];
    }

    for (DesktopApplication &entry : m_applications) {
        const QString executable = baseExecutable(entry.executable);
        entry.trackingAvailable =
            canTrackExecutable(executable) && executableCounts.value(executable) == 1;
    }

    endResetModel();
    emit countChanged();
    scanProcesses();
}

QString AppCatalogModel::baseExecutable(const QString &path)
{
    return QFileInfo(path).fileName().trimmed().toCaseFolded();
}

bool AppCatalogModel::canTrackExecutable(const QString &executable)
{
    static const QSet<QString> genericLaunchers = {
        QStringLiteral("env"),
        QStringLiteral("sh"),
        QStringLiteral("bash"),
        QStringLiteral("zsh"),
        QStringLiteral("fish"),
        QStringLiteral("steam"),
        QStringLiteral("flatpak"),
        QStringLiteral("flatpak-spawn"),
        QStringLiteral("pkexec"),
        QStringLiteral("sudo"),
        QStringLiteral("su"),
        QStringLiteral("python"),
        QStringLiteral("python2"),
        QStringLiteral("python3"),
        QStringLiteral("wine"),
        QStringLiteral("wine64"),
        QStringLiteral("proton"),
        QStringLiteral("java"),
        QStringLiteral("javaw"),
        QStringLiteral("xdg-open"),
        QStringLiteral("gio"),
        QStringLiteral("gtk-launch"),
        QStringLiteral("kdeinit5"),
        QStringLiteral("kdeinit6")
    };
    return !executable.isEmpty() && !genericLaunchers.contains(executable);
}

int AppCatalogModel::indexOfId(const QString &appId) const
{
    for (qsizetype i = 0; i < m_applications.size(); ++i) {
        if (m_applications.at(i).id == appId)
            return static_cast<int>(i);
    }
    return -1;
}

bool AppCatalogModel::launchEntry(DesktopApplication &entry)
{
    if (!entry.info) {
        emit launchError(entry.name, QStringLiteral("The desktop entry is no longer available."));
        return false;
    }

    GAppLaunchContext *context = g_app_launch_context_new();
    GError *error = nullptr;
    const gboolean launched = g_app_info_launch(entry.info, nullptr, context, &error);
    g_object_unref(context);

    if (!launched) {
        const QString message = error
            ? QString::fromUtf8(error->message)
            : QStringLiteral("The application could not be started.");
        if (error)
            g_error_free(error);
        emit launchError(entry.name, message);
        return false;
    }

    emit launchStarted(entry.name, entry.id);
    return true;
}

bool AppCatalogModel::launch(const QString &appId)
{
    const int index = indexOfId(appId);
    if (index < 0) {
        emit launchError(appId, QStringLiteral("Application not found. Refresh the catalog and try again."));
        return false;
    }
    return launchEntry(m_applications[index]);
}

static QHash<QString, QStringList> appAliasCandidates()
{
    return {
        {QStringLiteral("nerufiles"), {QStringLiteral("dolphin"), QStringLiteral("thunar"), QStringLiteral("nautilus"), QStringLiteral("nemo"), QStringLiteral("pcmanfm")}},
        {QStringLiteral("nerubrowser"), {QStringLiteral("firefox"), QStringLiteral("chromium"), QStringLiteral("brave"), QStringLiteral("brave-browser"), QStringLiteral("vivaldi"), QStringLiteral("vivaldi-stable"), QStringLiteral("google-chrome"), QStringLiteral("google-chrome-stable")}},
        {QStringLiteral("neruterminal"), {QStringLiteral("konsole"), QStringLiteral("kitty"), QStringLiteral("alacritty"), QStringLiteral("wezterm"), QStringLiteral("foot"), QStringLiteral("xterm")}},
        {QStringLiteral("nerucode"), {QStringLiteral("code-oss"), QStringLiteral("codium"), QStringLiteral("code"), QStringLiteral("kate"), QStringLiteral("mousepad")}},
        {QStringLiteral("steam"), {QStringLiteral("steam")}},
        {QStringLiteral("nerugallery"), {QStringLiteral("gwenview"), QStringLiteral("loupe"), QStringLiteral("ristretto"), QStringLiteral("eog"), QStringLiteral("feh")}}
    };
}

bool AppCatalogModel::launchAlias(const QString &alias)
{
    const QString key = alias.trimmed().toCaseFolded();
    if (key.isEmpty())
        return false;

    const QHash<QString, QStringList> candidates = appAliasCandidates();

    const QStringList preferred = candidates.value(key);
    for (const QString &candidate : preferred) {
        for (DesktopApplication &entry : m_applications) {
            const QString executable = baseExecutable(entry.executable);
            const QString appId = entry.id.toCaseFolded();
            const QString name = entry.name.toCaseFolded();
            if (executable == candidate ||
                appId.contains(candidate) ||
                name == candidate) {
                return launchEntry(entry);
            }
        }
    }

    emit launchError(alias, QStringLiteral("No matching application is installed. Open NeruSearch to choose an available app."));
    return false;
}

bool AppCatalogModel::isRunning(const QString &appId) const
{
    const int index = indexOfId(appId);
    return index >= 0 && m_applications.at(index).trackingAvailable &&
           !m_applications.at(index).processIds.isEmpty();
}

static QString normalizedWindowAppId(const QString &value)
{
    QString normalized = QFileInfo(value).fileName().trimmed().toCaseFolded();
    if (normalized.endsWith(QStringLiteral(".desktop")))
        normalized.chop(8);
    return normalized;
}

QStringList AppCatalogModel::windowIdsForAlias(const QString &alias) const
{
    const QString key = alias.trimmed().toCaseFolded();
    if (key.isEmpty())
        return {};

    const QStringList candidates = appAliasCandidates().value(key);
    if (candidates.isEmpty())
        return {};

    QStringList result;
    for (const QString &candidate : candidates)
        result.append(normalizedWindowAppId(candidate));

    for (const DesktopApplication &entry : m_applications) {
        const QString executable = baseExecutable(entry.executable);
        const QString desktopId = normalizedWindowAppId(entry.id);
        const QString name = entry.name.trimmed().toCaseFolded();
        const bool matches = candidates.contains(executable) ||
                             candidates.contains(desktopId) ||
                             candidates.contains(name);
        if (!matches)
            continue;

        if (!desktopId.isEmpty())
            result.append(desktopId);
        if (!executable.isEmpty())
            result.append(executable);
    }

    result.removeDuplicates();
    return result;
}

QStringList AppCatalogModel::aliasesForWindowAppIds(const QStringList &appIds) const
{
    if (appIds.isEmpty())
        return {};

    QStringList normalizedIds;
    normalizedIds.reserve(appIds.size());
    for (const QString &appId : appIds) {
        const QString normalized = normalizedWindowAppId(appId);
        if (!normalized.isEmpty() && !normalizedIds.contains(normalized))
            normalizedIds.append(normalized);
    }

    QStringList result;
    const auto aliases = appAliasCandidates();
    for (auto it = aliases.cbegin(); it != aliases.cend(); ++it) {
        const QStringList acceptedIds = windowIdsForAlias(it.key());
        const bool running = std::any_of(
            normalizedIds.cbegin(), normalizedIds.cend(),
            [&acceptedIds](const QString &id) { return acceptedIds.contains(id); });
        if (running)
            result.append(it.key());
    }

    result.sort();
    return result;
}

QString AppCatalogModel::aliasForWindowAppId(const QString &appId) const
{
    const QStringList aliases = aliasesForWindowAppIds({appId});
    return aliases.isEmpty() ? QString{} : aliases.first();
}

void AppCatalogModel::scanProcesses()
{
    QHash<QString, QSet<qint64>> processesByExecutable;
    const QDir procDirectory(QStringLiteral("/proc"));
    const QStringList processDirectories =
        procDirectory.entryList(QDir::Dirs | QDir::NoDotAndDotDot);

    for (const QString &directory : processDirectories) {
        bool pidOk = false;
        const qint64 pid = directory.toLongLong(&pidOk);
        if (!pidOk || pid <= 0)
            continue;

        const QString processPath = QStringLiteral("/proc/") + directory;
        QFile commFile(processPath + QStringLiteral("/comm"));
        QString comm;
        if (commFile.open(QIODevice::ReadOnly))
            comm = QString::fromLocal8Bit(commFile.readAll()).trimmed().toCaseFolded();

        QFile cmdlineFile(processPath + QStringLiteral("/cmdline"));
        QString argvZero;
        if (cmdlineFile.open(QIODevice::ReadOnly)) {
            QByteArray commandLine = cmdlineFile.readAll();
            const qsizetype separator = commandLine.indexOf('\0');
            if (separator >= 0)
                commandLine.truncate(separator);
            argvZero = baseExecutable(QString::fromLocal8Bit(commandLine));
        }

        if (!comm.isEmpty())
            processesByExecutable[comm].insert(pid);
        if (!argvZero.isEmpty())
            processesByExecutable[argvZero].insert(pid);
    }

    for (qsizetype i = 0; i < m_applications.size(); ++i) {
        DesktopApplication &entry = m_applications[i];
        const int previousCount = entry.processIds.size();
        const QString executable = baseExecutable(entry.executable);
        entry.processIds = entry.trackingAvailable
            ? processesByExecutable.value(executable)
            : QSet<qint64>{};

        if (previousCount != entry.processIds.size()) {
            const QModelIndex changed = index(static_cast<int>(i), 0);
            emit dataChanged(changed, changed, {RunningRole, ProcessCountRole});
        }
    }

    QStringList aliases;
    const auto candidates = appAliasCandidates();
    for (auto it = candidates.cbegin(); it != candidates.cend(); ++it) {
        bool running = false;
        for (const QString &candidate : it.value()) {
            if (!processesByExecutable.value(candidate).isEmpty()) {
                running = true;
                break;
            }
        }
        if (running)
            aliases.push_back(it.key());
    }
    aliases.sort();
    if (aliases != m_runningAliases) {
        m_runningAliases = aliases;
        emit runningAliasesChanged();
    }
}
