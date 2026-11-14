#include "AppCatalog.h"
#include "UpdateChecker.h"

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
    QGuiApplication::setApplicationName(QStringLiteral("NeruOS Nebula"));
    QGuiApplication::setOrganizationName(QStringLiteral("NeruOS"));

    AppCatalogModel appCatalog;
    UpdateChecker updateChecker;

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
        if (showUpdates) {
            engine.rootObjects().first()->setProperty("updatePanelOpen", true);
            QTimer::singleShot(0, &updateChecker, &UpdateChecker::checkNow);
        }
    }

    return app.exec();
}
