#include "AppCatalog.h"
#include "DesktopSettings.h"
#include "FileSystemModel.h"
#include "NotificationBridge.h"
#include "SessionManager.h"
#include "SystemControls.h"
#include "UpdateChecker.h"
#include "WorkspaceController.h"

#include <QDebug>
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QSortFilterProxyModel>
#include <QTimer>
#include <QUrl>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("NeruOS"));
    QGuiApplication::setApplicationDisplayName(QStringLiteral("NeruOS"));
    QGuiApplication::setOrganizationName(QStringLiteral("NeruOS"));

    // Keep the startup splash lightweight: it opens before AppCatalog/GIO
    // discovery and the update checker are constructed for the full shell.
    if (app.arguments().contains(QStringLiteral("--boot-splash"))) {
        QQmlApplicationEngine splashEngine;
        const QUrl splashUrl(QStringLiteral("qrc:/qt/qml/NeruOS/BootSplash.qml"));

        QObject::connect(
            &splashEngine,
            &QQmlApplicationEngine::objectCreated,
            &app,
            [splashUrl](QObject *object, const QUrl &objectUrl) {
                if (!object && objectUrl == splashUrl)
                    QCoreApplication::exit(1);
            },
            Qt::QueuedConnection
        );

        splashEngine.load(splashUrl);
        if (splashEngine.rootObjects().isEmpty())
            return 1;

        return app.exec();
    }

    AppCatalogModel appCatalog;
    DesktopSettings desktopSettings;
    FileSystemModel fileSystemModel;
    SessionManager sessionManager;
    NotificationBridge notificationBridge;
    SystemControls systemControls;
    WorkspaceController workspaceController;
    UpdateChecker updateChecker;

    if (app.arguments().contains(QStringLiteral("--test-notifications"))) {
        qInfo().noquote() << QStringLiteral("NeruOS notification D-Bus service: %1")
                                 .arg(notificationBridge.busAvailable()
                                          ? QStringLiteral("available")
                                          : QStringLiteral("unavailable"));
        QTimer::singleShot(3000, &app, &QCoreApplication::quit);
        return app.exec();
    }

    if (app.arguments().contains(QStringLiteral("--list-apps"))) {
        qInfo().noquote() << QStringLiteral("NeruOS application catalog: %1 launchable desktop entries")
                                 .arg(appCatalog.count());
        for (int row = 0; row < appCatalog.rowCount(); ++row) {
            const QModelIndex item = appCatalog.index(row, 0);
            const QString name = appCatalog.data(item, AppCatalogModel::DisplayNameRole).toString();
            const QString id = appCatalog.data(item, AppCatalogModel::AppIdRole).toString();
            const QString executable = appCatalog.data(item, AppCatalogModel::ExecutableRole).toString();
            const bool running = appCatalog.data(item, AppCatalogModel::RunningRole).toBool();
            const bool trackingAvailable = appCatalog.data(item, AppCatalogModel::TrackingAvailableRole).toBool();
            const QString status = !trackingAvailable
                ? QStringLiteral("Unverified")
                : (running ? QStringLiteral("Running") : QStringLiteral("Not detected"));
            qInfo().noquote() << QStringLiteral("%1 | %2 | %3 | %4")
                                     .arg(name, id, executable, status);
        }
        return 0;
    }

    const int launchArgument = app.arguments().indexOf(QStringLiteral("--launch-app"));
    if (launchArgument >= 0) {
        if (launchArgument + 1 >= app.arguments().size()) {
            qCritical() << "Usage: neruos-nebula --launch-app <desktop-file-id>";
            return 2;
        }

        const QString appId = app.arguments().at(launchArgument + 1);
        QObject::connect(&appCatalog, &AppCatalogModel::launchError,
                         &app, [&app](const QString &name, const QString &message) {
            qCritical().noquote() << QStringLiteral("Launch failed for %1: %2").arg(name, message);
            app.exit(1);
        });

        if (!appCatalog.launch(appId))
            return 1;

        QTimer::singleShot(3500, &app, [&app, &appCatalog, appId]() {
            const bool running = appCatalog.isRunning(appId);
            qInfo().noquote() << QStringLiteral("Launch test for %1: process %2")
                                     .arg(appId, running ? QStringLiteral("detected")
                                                        : QStringLiteral("not detected / unverified"));
            app.exit(running ? 0 : 1);
        });
        return app.exec();
    }

    const bool showSearch = app.arguments().contains(QStringLiteral("--show-search"));
    const bool showCenter = app.arguments().contains(QStringLiteral("--show-center"));
    const bool showFiles = app.arguments().contains(QStringLiteral("--show-files"));
    const bool showSettings = app.arguments().contains(QStringLiteral("--show-settings"));
    const bool showNotifications = app.arguments().contains(QStringLiteral("--show-notifications"));
    const bool showSession = app.arguments().contains(QStringLiteral("--show-session"));
    const bool showUpdates = app.arguments().contains(QStringLiteral("--show-updates"));
    const bool checkUpdates = app.arguments().contains(QStringLiteral("--check-updates"));

    if (checkUpdates) {
        QObject::connect(&updateChecker, &UpdateChecker::checkFinished,
                         &app, [&app, &updateChecker](bool updatesAvailable, int count) {
            qInfo().noquote() << updateChecker.message();
            for (const QString &item : updateChecker.updates())
                qInfo().noquote() << item;
            app.exit(updatesAvailable ? 10 : 0);
        });
        updateChecker.checkNow();
        return app.exec();
    }

    QSortFilterProxyModel appFilter;
    appFilter.setSourceModel(&appCatalog);
    appFilter.setFilterRole(AppCatalogModel::DisplayNameRole);
    appFilter.setFilterCaseSensitivity(Qt::CaseInsensitive);
    appFilter.setSortRole(AppCatalogModel::DisplayNameRole);
    appFilter.sort(0);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("appCatalog"), &appCatalog);
    engine.rootContext()->setContextProperty(QStringLiteral("appFilter"), &appFilter);
    engine.rootContext()->setContextProperty(QStringLiteral("desktopSettings"), &desktopSettings);
    engine.rootContext()->setContextProperty(QStringLiteral("fileSystemModel"), &fileSystemModel);
    engine.rootContext()->setContextProperty(QStringLiteral("sessionManager"), &sessionManager);
    engine.rootContext()->setContextProperty(QStringLiteral("notificationBridge"), &notificationBridge);
    engine.rootContext()->setContextProperty(QStringLiteral("systemControls"), &systemControls);
    engine.rootContext()->setContextProperty(QStringLiteral("workspaceController"), &workspaceController);
    engine.rootContext()->setContextProperty(QStringLiteral("updateChecker"), &updateChecker);

    const QUrl mainUrl(QStringLiteral("qrc:/qt/qml/NeruOS/Main.qml"));

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [mainUrl](QObject *object, const QUrl &objectUrl) {
            if (!object && objectUrl == mainUrl)
                QCoreApplication::exit(EXIT_FAILURE);
        },
        Qt::QueuedConnection
    );

    engine.load(mainUrl);
    if (!engine.rootObjects().isEmpty()) {
        if (showSearch)
            engine.rootObjects().first()->setProperty("searchOpen", true);
        if (showCenter)
            engine.rootObjects().first()->setProperty("centerOpen", true);
        if (showFiles)
            engine.rootObjects().first()->setProperty("activeApp", QStringLiteral("NeruFiles"));
        if (showSettings)
            engine.rootObjects().first()->setProperty("activeApp", QStringLiteral("NeruSettings"));
        if (showNotifications)
            engine.rootObjects().first()->setProperty("notificationCenterOpen", true);
        if (showSession)
            engine.rootObjects().first()->setProperty("sessionPanelOpen", true);
        if (showUpdates) {
            engine.rootObjects().first()->setProperty("updatePanelOpen", true);
            QTimer::singleShot(0, &updateChecker, &UpdateChecker::checkNow);
        }
    }

    return app.exec();
}
