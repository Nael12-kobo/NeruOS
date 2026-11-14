#pragma once

#include <QAbstractListModel>

#include <cstdint>
#include <QStringList>

#include <memory>
#include <vector>

struct wl_display;
struct wl_registry;
struct wl_seat;
struct wl_output;
struct wl_array;
struct zwlr_foreign_toplevel_manager_v1;
struct zwlr_foreign_toplevel_handle_v1;

class QSocketNotifier;

class ForeignToplevelModel final : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)
    Q_PROPERTY(QStringList runningAppIds READ runningAppIds NOTIFY runningAppIdsChanged)
    Q_PROPERTY(QString activeAppId READ activeAppId NOTIFY activeWindowChanged)
    Q_PROPERTY(QString activeTitle READ activeTitle NOTIFY activeWindowChanged)

public:
    enum Roles {
        TitleRole = Qt::UserRole + 1,
        AppIdRole,
        ActivatedRole,
        MinimizedRole,
        MaximizedRole,
        FullscreenRole
    };
    Q_ENUM(Roles)

    explicit ForeignToplevelModel(QObject *parent = nullptr);
    ~ForeignToplevelModel() override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    bool available() const;
    int count() const;
    QString error() const;
    QStringList runningAppIds() const;
    QString activeAppId() const;
    QString activeTitle() const;

    Q_INVOKABLE bool activate(int row);
    Q_INVOKABLE bool activateByAppId(const QString &appId);
    Q_INVOKABLE bool activateFirstMatchingAppId(const QStringList &appIds);
    Q_INVOKABLE bool closeWindow(int row);
    Q_INVOKABLE bool setMinimized(int row, bool minimized);
    Q_INVOKABLE bool setMaximized(int row, bool maximized);

signals:
    void availableChanged();
    void countChanged();
    void errorChanged();
    void runningAppIdsChanged();
    void activeWindowChanged();

private:
    struct Entry;

public:
    // Wayland protocol callbacks are public only so C listener tables can reference them.
    static void registryGlobal(void *data, wl_registry *registry,
                               uint32_t name, const char *interface, uint32_t version);
    static void registryGlobalRemove(void *data, wl_registry *registry, uint32_t name);
    static void managerToplevel(void *data,
                                zwlr_foreign_toplevel_manager_v1 *manager,
                                zwlr_foreign_toplevel_handle_v1 *handle);
    static void managerFinished(void *data,
                                zwlr_foreign_toplevel_manager_v1 *manager);

    static void handleTitle(void *data, zwlr_foreign_toplevel_handle_v1 *handle,
                            const char *title);
    static void handleAppId(void *data, zwlr_foreign_toplevel_handle_v1 *handle,
                            const char *appId);
    static void handleOutputEnter(void *data, zwlr_foreign_toplevel_handle_v1 *handle,
                                  wl_output *output);
    static void handleOutputLeave(void *data, zwlr_foreign_toplevel_handle_v1 *handle,
                                  wl_output *output);
    static void handleState(void *data, zwlr_foreign_toplevel_handle_v1 *handle,
                            wl_array *state);
    static void handleDone(void *data, zwlr_foreign_toplevel_handle_v1 *handle);
    static void handleClosed(void *data, zwlr_foreign_toplevel_handle_v1 *handle);
    static void handleParent(void *data, zwlr_foreign_toplevel_handle_v1 *handle,
                             zwlr_foreign_toplevel_handle_v1 *parent);

private:
    void initializeWayland();
    void cleanupWayland();
    void dispatchEvents();
    void setAvailable(bool available);
    void setError(const QString &error);
    int indexOf(const Entry *entry) const;
    bool flushRequests();

    wl_display *m_display = nullptr;
    wl_registry *m_registry = nullptr;
    wl_seat *m_seat = nullptr;
    zwlr_foreign_toplevel_manager_v1 *m_manager = nullptr;
    QSocketNotifier *m_notifier = nullptr;
    std::vector<std::unique_ptr<Entry>> m_entries;
    bool m_available = false;
    QString m_error;
};
