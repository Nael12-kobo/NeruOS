#include "ForeignToplevelModel.h"

#include <QSocketNotifier>
#include <QVariant>

#include <wayland-client.h>
#include "wlr-foreign-toplevel-management-unstable-v1-client-protocol.h"

#include <algorithm>
#include <cerrno>
#include <cstring>

struct ForeignToplevelModel::Entry {
    ForeignToplevelModel *owner = nullptr;
    zwlr_foreign_toplevel_handle_v1 *handle = nullptr;
    QString title;
    QString appId;
    bool activated = false;
    bool minimized = false;
    bool maximized = false;
    bool fullscreen = false;
    bool closed = false;
};

namespace {
const wl_registry_listener registryListener = {
    ForeignToplevelModel::registryGlobal,
    ForeignToplevelModel::registryGlobalRemove
};

const zwlr_foreign_toplevel_manager_v1_listener managerListener = {
    ForeignToplevelModel::managerToplevel,
    ForeignToplevelModel::managerFinished
};

const zwlr_foreign_toplevel_handle_v1_listener handleListener = {
    ForeignToplevelModel::handleTitle,
    ForeignToplevelModel::handleAppId,
    ForeignToplevelModel::handleOutputEnter,
    ForeignToplevelModel::handleOutputLeave,
    ForeignToplevelModel::handleState,
    ForeignToplevelModel::handleDone,
    ForeignToplevelModel::handleClosed,
    ForeignToplevelModel::handleParent
};
}

ForeignToplevelModel::ForeignToplevelModel(QObject *parent)
    : QAbstractListModel(parent)
{
    initializeWayland();
}

ForeignToplevelModel::~ForeignToplevelModel()
{
    cleanupWayland();
}

int ForeignToplevelModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : static_cast<int>(m_entries.size());
}

int ForeignToplevelModel::count() const
{
    return rowCount();
}

QVariant ForeignToplevelModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 ||
        index.row() >= static_cast<int>(m_entries.size())) {
        return {};
    }

    const Entry &entry = *m_entries.at(static_cast<size_t>(index.row()));
    switch (role) {
    case TitleRole: return entry.title;
    case AppIdRole: return entry.appId;
    case ActivatedRole: return entry.activated;
    case MinimizedRole: return entry.minimized;
    case MaximizedRole: return entry.maximized;
    case FullscreenRole: return entry.fullscreen;
    default: return {};
    }
}

QHash<int, QByteArray> ForeignToplevelModel::roleNames() const
{
    return {
        {TitleRole, "title"},
        {AppIdRole, "appId"},
        {ActivatedRole, "activated"},
        {MinimizedRole, "minimized"},
        {MaximizedRole, "maximized"},
        {FullscreenRole, "fullscreen"}
    };
}

bool ForeignToplevelModel::available() const
{
    return m_available;
}

QString ForeignToplevelModel::error() const
{
    return m_error;
}

QStringList ForeignToplevelModel::runningAppIds() const
{
    QStringList result;
    for (const auto &entry : m_entries) {
        if (!entry->appId.isEmpty() && !result.contains(entry->appId))
            result.append(entry->appId);
    }
    result.sort(Qt::CaseInsensitive);
    return result;
}

QString ForeignToplevelModel::activeAppId() const
{
    for (const auto &entry : m_entries) {
        if (entry->activated)
            return entry->appId;
    }
    return {};
}

QString ForeignToplevelModel::activeTitle() const
{
    for (const auto &entry : m_entries) {
        if (entry->activated)
            return entry->title;
    }
    return {};
}

void ForeignToplevelModel::setAvailable(bool available)
{
    if (m_available == available)
        return;
    m_available = available;
    emit availableChanged();
}

void ForeignToplevelModel::setError(const QString &error)
{
    if (m_error == error)
        return;
    m_error = error;
    emit errorChanged();
}

void ForeignToplevelModel::initializeWayland()
{
    m_display = wl_display_connect(nullptr);
    if (!m_display) {
        setError(QStringLiteral("No Wayland display is available."));
        return;
    }

    m_registry = wl_display_get_registry(m_display);
    if (!m_registry || wl_registry_add_listener(m_registry, &registryListener, this) < 0) {
        setError(QStringLiteral("Unable to read the Wayland compositor registry."));
        cleanupWayland();
        return;
    }

    if (wl_display_roundtrip(m_display) < 0) {
        setError(QStringLiteral("The Wayland compositor did not answer the registry request."));
        cleanupWayland();
        return;
    }

    if (!m_manager) {
        setError(QStringLiteral("The compositor does not expose wlr-foreign-toplevel-management."));
        cleanupWayland();
        return;
    }
    if (!m_seat) {
        setError(QStringLiteral("The compositor did not expose a Wayland seat."));
        cleanupWayland();
        return;
    }

    if (wl_display_roundtrip(m_display) < 0) {
        setError(QStringLiteral("Unable to receive the initial native window list."));
        cleanupWayland();
        return;
    }

    if (!m_manager || !m_seat) {
        setError(QStringLiteral("The native window-management protocol became unavailable during startup."));
        cleanupWayland();
        return;
    }

    wl_registry_destroy(m_registry);
    m_registry = nullptr;

    const int displayFd = wl_display_get_fd(m_display);
    if (displayFd < 0) {
        setError(QStringLiteral("Unable to monitor Wayland events."));
        cleanupWayland();
        return;
    }

    m_notifier = new QSocketNotifier(displayFd, QSocketNotifier::Read, this);
    connect(m_notifier, &QSocketNotifier::activated,
            this, &ForeignToplevelModel::dispatchEvents);
    setAvailable(true);
    setError({});
    emit countChanged();
    emit runningAppIdsChanged();
    emit activeWindowChanged();
}

void ForeignToplevelModel::cleanupWayland()
{
    if (m_notifier) {
        m_notifier->setEnabled(false);
        m_notifier->deleteLater();
        m_notifier = nullptr;
    }

    for (auto &entry : m_entries) {
        if (entry->handle) {
            zwlr_foreign_toplevel_handle_v1_destroy(entry->handle);
            entry->handle = nullptr;
        }
    }
    m_entries.clear();

    if (m_manager) {
        zwlr_foreign_toplevel_manager_v1_destroy(m_manager);
        m_manager = nullptr;
    }
    if (m_seat) {
        wl_seat_destroy(m_seat);
        m_seat = nullptr;
    }
    if (m_registry) {
        wl_registry_destroy(m_registry);
        m_registry = nullptr;
    }
    if (m_display) {
        wl_display_disconnect(m_display);
        m_display = nullptr;
    }
    setAvailable(false);
}

void ForeignToplevelModel::registryGlobal(void *data, wl_registry *registry,
                                          uint32_t name, const char *interface,
                                          uint32_t version)
{
    auto *self = static_cast<ForeignToplevelModel *>(data);
    if (!self || !interface)
        return;

    if (!self->m_seat && std::strcmp(interface, wl_seat_interface.name) == 0) {
        self->m_seat = static_cast<wl_seat *>(
            wl_registry_bind(registry, name, &wl_seat_interface, std::min(version, 1u)));
        return;
    }

    if (!self->m_manager &&
        std::strcmp(interface, zwlr_foreign_toplevel_manager_v1_interface.name) == 0) {
        const uint32_t supportedVersion = std::min(version, 3u);
        self->m_manager = static_cast<zwlr_foreign_toplevel_manager_v1 *>(
            wl_registry_bind(registry, name,
                            &zwlr_foreign_toplevel_manager_v1_interface,
                            supportedVersion));
        if (self->m_manager) {
            zwlr_foreign_toplevel_manager_v1_add_listener(
                self->m_manager, &managerListener, self);
        }
    }
}

void ForeignToplevelModel::registryGlobalRemove(void *, wl_registry *, uint32_t)
{
}

void ForeignToplevelModel::managerToplevel(
    void *data, zwlr_foreign_toplevel_manager_v1 *,
    zwlr_foreign_toplevel_handle_v1 *handle)
{
    auto *self = static_cast<ForeignToplevelModel *>(data);
    if (!self || !handle)
        return;

    auto entry = std::make_unique<Entry>();
    entry->owner = self;
    entry->handle = handle;
    if (zwlr_foreign_toplevel_handle_v1_add_listener(
            handle, &handleListener, entry.get()) < 0) {
        zwlr_foreign_toplevel_handle_v1_destroy(handle);
        return;
    }

    const int row = static_cast<int>(self->m_entries.size());
    self->beginInsertRows(QModelIndex(), row, row);
    self->m_entries.push_back(std::move(entry));
    self->endInsertRows();
    emit self->countChanged();
}

void ForeignToplevelModel::managerFinished(
    void *data, zwlr_foreign_toplevel_manager_v1 *)
{
    auto *self = static_cast<ForeignToplevelModel *>(data);
    if (!self)
        return;
    if (self->m_manager) {
        zwlr_foreign_toplevel_manager_v1_destroy(self->m_manager);
        self->m_manager = nullptr;
    }
    self->setAvailable(false);
    self->setError(QStringLiteral("The compositor ended native window tracking."));
}

void ForeignToplevelModel::handleTitle(
    void *data, zwlr_foreign_toplevel_handle_v1 *, const char *title)
{
    auto *entry = static_cast<Entry *>(data);
    if (entry)
        entry->title = QString::fromUtf8(title ? title : "");
}

void ForeignToplevelModel::handleAppId(
    void *data, zwlr_foreign_toplevel_handle_v1 *, const char *appId)
{
    auto *entry = static_cast<Entry *>(data);
    if (entry)
        entry->appId = QString::fromUtf8(appId ? appId : "");
}

void ForeignToplevelModel::handleOutputEnter(void *, zwlr_foreign_toplevel_handle_v1 *, wl_output *)
{
}

void ForeignToplevelModel::handleOutputLeave(void *, zwlr_foreign_toplevel_handle_v1 *, wl_output *)
{
}

void ForeignToplevelModel::handleState(
    void *data, zwlr_foreign_toplevel_handle_v1 *, wl_array *state)
{
    auto *entry = static_cast<Entry *>(data);
    if (!entry || !state)
        return;

    entry->activated = false;
    entry->minimized = false;
    entry->maximized = false;
    entry->fullscreen = false;

    const auto *value = static_cast<const uint32_t *>(state->data);
    const auto *end = reinterpret_cast<const uint32_t *>(
        static_cast<const char *>(state->data) + state->size);
    for (; value < end; ++value) {
        switch (*value) {
        case ZWLR_FOREIGN_TOPLEVEL_HANDLE_V1_STATE_ACTIVATED:
            entry->activated = true;
            break;
        case ZWLR_FOREIGN_TOPLEVEL_HANDLE_V1_STATE_MINIMIZED:
            entry->minimized = true;
            break;
        case ZWLR_FOREIGN_TOPLEVEL_HANDLE_V1_STATE_MAXIMIZED:
            entry->maximized = true;
            break;
        case ZWLR_FOREIGN_TOPLEVEL_HANDLE_V1_STATE_FULLSCREEN:
            entry->fullscreen = true;
            break;
        default:
            break;
        }
    }
}

void ForeignToplevelModel::handleDone(
    void *data, zwlr_foreign_toplevel_handle_v1 *)
{
    auto *entry = static_cast<Entry *>(data);
    if (!entry || !entry->owner)
        return;

    auto *self = entry->owner;
    const int row = self->indexOf(entry);
    if (row < 0)
        return;

    emit self->dataChanged(self->index(row, 0), self->index(row, 0));
    emit self->runningAppIdsChanged();
    emit self->activeWindowChanged();
}

void ForeignToplevelModel::handleClosed(
    void *data, zwlr_foreign_toplevel_handle_v1 *)
{
    auto *entry = static_cast<Entry *>(data);
    if (!entry || !entry->owner || entry->closed)
        return;

    auto *self = entry->owner;
    const int row = self->indexOf(entry);
    if (row < 0)
        return;

    entry->closed = true;
    self->beginRemoveRows(QModelIndex(), row, row);
    auto owned = std::move(self->m_entries.at(static_cast<size_t>(row)));
    self->m_entries.erase(self->m_entries.begin() + row);
    self->endRemoveRows();

    if (owned->handle) {
        zwlr_foreign_toplevel_handle_v1_destroy(owned->handle);
        owned->handle = nullptr;
    }
    emit self->countChanged();
    emit self->runningAppIdsChanged();
    emit self->activeWindowChanged();
}

void ForeignToplevelModel::handleParent(
    void *, zwlr_foreign_toplevel_handle_v1 *,
    zwlr_foreign_toplevel_handle_v1 *)
{
}

int ForeignToplevelModel::indexOf(const Entry *entry) const
{
    for (size_t i = 0; i < m_entries.size(); ++i) {
        if (m_entries[i].get() == entry)
            return static_cast<int>(i);
    }
    return -1;
}

bool ForeignToplevelModel::flushRequests()
{
    if (!m_display)
        return false;
    if (wl_display_flush(m_display) < 0 && errno != EAGAIN) {
        setError(QStringLiteral("Failed to send a native window request to the compositor."));
        return false;
    }
    return true;
}

bool ForeignToplevelModel::activate(int row)
{
    if (!available() || !m_seat || row < 0 ||
        row >= static_cast<int>(m_entries.size())) {
        return false;
    }
    auto *handle = m_entries.at(static_cast<size_t>(row))->handle;
    if (!handle)
        return false;
    zwlr_foreign_toplevel_handle_v1_activate(handle, m_seat);
    return flushRequests();
}

static QString normalizedWindowAppId(const QString &value)
{
    QString normalized = value.trimmed().toCaseFolded();
    if (normalized.endsWith(QStringLiteral(".desktop")))
        normalized.chop(8);
    return normalized;
}

bool ForeignToplevelModel::activateByAppId(const QString &appId)
{
    const QString target = normalizedWindowAppId(appId);
    if (target.isEmpty())
        return false;
    for (size_t i = 0; i < m_entries.size(); ++i) {
        if (normalizedWindowAppId(m_entries[i]->appId) == target)
            return activate(static_cast<int>(i));
    }
    return false;
}

bool ForeignToplevelModel::activateFirstMatchingAppId(const QStringList &appIds)
{
    if (!available() || appIds.isEmpty())
        return false;

    QStringList targets;
    targets.reserve(appIds.size());
    for (const QString &appId : appIds) {
        const QString target = normalizedWindowAppId(appId);
        if (!target.isEmpty() && !targets.contains(target))
            targets.append(target);
    }

    for (size_t i = 0; i < m_entries.size(); ++i) {
        if (targets.contains(normalizedWindowAppId(m_entries[i]->appId)))
            return activate(static_cast<int>(i));
    }
    return false;
}

bool ForeignToplevelModel::closeWindow(int row)
{
    if (!available() || row < 0 || row >= static_cast<int>(m_entries.size()))
        return false;
    auto *handle = m_entries.at(static_cast<size_t>(row))->handle;
    if (!handle)
        return false;
    zwlr_foreign_toplevel_handle_v1_close(handle);
    return flushRequests();
}

bool ForeignToplevelModel::setMinimized(int row, bool minimized)
{
    if (!available() || row < 0 || row >= static_cast<int>(m_entries.size()))
        return false;
    auto *handle = m_entries.at(static_cast<size_t>(row))->handle;
    if (!handle)
        return false;
    if (minimized)
        zwlr_foreign_toplevel_handle_v1_set_minimized(handle);
    else
        zwlr_foreign_toplevel_handle_v1_unset_minimized(handle);
    return flushRequests();
}

bool ForeignToplevelModel::setMaximized(int row, bool maximized)
{
    if (!available() || row < 0 || row >= static_cast<int>(m_entries.size()))
        return false;
    auto *handle = m_entries.at(static_cast<size_t>(row))->handle;
    if (!handle)
        return false;
    if (maximized)
        zwlr_foreign_toplevel_handle_v1_set_maximized(handle);
    else
        zwlr_foreign_toplevel_handle_v1_unset_maximized(handle);
    return flushRequests();
}

void ForeignToplevelModel::dispatchEvents()
{
    if (!m_display)
        return;

    while (wl_display_prepare_read(m_display) != 0) {
        if (wl_display_dispatch_pending(m_display) < 0) {
            setError(QStringLiteral("Wayland event dispatch failed."));
            return;
        }
    }

    if (wl_display_read_events(m_display) < 0 ||
        wl_display_dispatch_pending(m_display) < 0) {
        setError(QStringLiteral("The Wayland connection was interrupted."));
        setAvailable(false);
        if (m_notifier)
            m_notifier->setEnabled(false);
        return;
    }

    wl_display_flush(m_display);
}
