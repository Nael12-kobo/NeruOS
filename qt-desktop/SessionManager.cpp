#include "SessionManager.h"

#include <QProcess>
#include <QRegularExpression>
#include <QStandardPaths>
#include <QStringList>

SessionManager::SessionManager(QObject *parent)
    : QObject(parent)
{
    m_userName = qEnvironmentVariable("USER", QStringLiteral("neru"));
    m_sessionId = qEnvironmentVariable("XDG_SESSION_ID");
    m_loginctlPath = QStandardPaths::findExecutable(QStringLiteral("loginctl"));

    // Some minimal Wayland sessions do not export XDG_SESSION_ID.
    // Ask logind for the graphical display session rather than guessing a
    // session number or terminating every session owned by this user.
    if (m_sessionId.isEmpty() && !m_loginctlPath.isEmpty()) {
        QProcess process;
        process.start(m_loginctlPath,
                      {QStringLiteral("show-user"), m_userName,
                       QStringLiteral("--property=Display"), QStringLiteral("--value")});
        if (process.waitForStarted(1000) && process.waitForFinished(1500) &&
            process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0) {
            m_sessionId = QString::fromLocal8Bit(process.readAllStandardOutput()).trimmed();
        }
    }

    if (m_sessionId.isEmpty() && !m_loginctlPath.isEmpty()) {
        QProcess process;
        process.start(m_loginctlPath,
                      {QStringLiteral("show-user"), m_userName,
                       QStringLiteral("--property=Sessions"), QStringLiteral("--value")});
        if (process.waitForStarted(1000) && process.waitForFinished(1500) &&
            process.exitStatus() == QProcess::NormalExit && process.exitCode() == 0) {
            const QString sessions = QString::fromLocal8Bit(process.readAllStandardOutput()).trimmed();
            const QStringList candidates = sessions.split(QRegularExpression(QStringLiteral("\\s+")),
                                                          Qt::SkipEmptyParts);
            for (const QString &candidate : candidates) {
                QProcess sessionQuery;
                sessionQuery.start(m_loginctlPath,
                                   {QStringLiteral("show-session"), candidate,
                                    QStringLiteral("--property=Active"), QStringLiteral("--value")});
                if (sessionQuery.waitForStarted(1000) && sessionQuery.waitForFinished(1500) &&
                    sessionQuery.exitStatus() == QProcess::NormalExit &&
                    sessionQuery.exitCode() == 0 &&
                    QString::fromLocal8Bit(sessionQuery.readAllStandardOutput()).trimmed()
                        == QStringLiteral("yes")) {
                    m_sessionId = candidate;
                    break;
                }
            }
        }
    }

    m_lockerPath = QStandardPaths::findExecutable(QStringLiteral("swaylock"));
    if (m_lockerPath.isEmpty())
        m_lockerPath = QStandardPaths::findExecutable(QStringLiteral("gtklock"));
}

QString SessionManager::userName() const { return m_userName; }
QString SessionManager::sessionId() const { return m_sessionId; }
bool SessionManager::lockerAvailable() const { return !m_lockerPath.isEmpty(); }

void SessionManager::lockScreen()
{
    if (!lockerAvailable()) {
        emit actionFailed(QStringLiteral("lock"),
                          QStringLiteral("No PAM-backed screen locker is installed in this image."));
        return;
    }

    QStringList arguments;
    if (m_lockerPath.endsWith(QStringLiteral("swaylock")))
        arguments << QStringLiteral("--color") << QStringLiteral("071126");
    if (!QProcess::startDetached(m_lockerPath, arguments)) {
        emit actionFailed(QStringLiteral("lock"), QStringLiteral("The screen locker could not be started."));
        return;
    }
    emit actionStarted(QStringLiteral("lock"));
}

bool SessionManager::runLoginctl(const QString &action, const QStringList &arguments)
{
    if (m_loginctlPath.isEmpty()) {
        emit actionFailed(action, QStringLiteral("systemd-logind is not available."));
        return false;
    }

    QProcess process;
    process.setProcessChannelMode(QProcess::MergedChannels);
    process.start(m_loginctlPath, arguments);
    if (!process.waitForStarted(1500) || !process.waitForFinished(5000)) {
        process.kill();
        emit actionFailed(action, QStringLiteral("The system session service did not respond."));
        return false;
    }

    if (process.exitStatus() != QProcess::NormalExit || process.exitCode() != 0) {
        const QString detail = QString::fromLocal8Bit(process.readAll()).trimmed();
        emit actionFailed(action, detail.isEmpty()
            ? QStringLiteral("The session action was denied or unavailable.")
            : detail);
        return false;
    }

    emit actionStarted(action);
    return true;
}

void SessionManager::logOut()
{
    if (m_sessionId.isEmpty()) {
        emit actionFailed(QStringLiteral("logout"), QStringLiteral("No active logind session ID was supplied."));
        return;
    }
    runLoginctl(QStringLiteral("logout"),
                {QStringLiteral("terminate-session"), m_sessionId});
}

void SessionManager::suspend()
{
    runLoginctl(QStringLiteral("suspend"), {QStringLiteral("suspend")});
}

void SessionManager::restart()
{
    runLoginctl(QStringLiteral("restart"), {QStringLiteral("reboot")});
}

void SessionManager::powerOff()
{
    runLoginctl(QStringLiteral("poweroff"), {QStringLiteral("poweroff")});
}
