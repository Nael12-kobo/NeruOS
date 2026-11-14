#include "UpdateChecker.h"

#include <QDateTime>
#include <QProcessEnvironment>
#include <QRegularExpression>
#include <QStandardPaths>

UpdateChecker::UpdateChecker(QObject *parent)
    : QObject(parent),
      m_process(new QProcess(this))
{
    m_process->setProcessChannelMode(QProcess::SeparateChannels);
    connect(m_process,
            qOverload<int, QProcess::ExitStatus>(&QProcess::finished),
            this,
            &UpdateChecker::handleFinished);
    connect(m_process,
            &QProcess::errorOccurred,
            this,
            &UpdateChecker::handleProcessError);
}

UpdateChecker::~UpdateChecker()
{
    if (m_process->state() != QProcess::NotRunning) {
        m_process->terminate();
        if (!m_process->waitForFinished(500))
            m_process->kill();
    }
}

QString UpdateChecker::state() const
{
    return m_state;
}

QString UpdateChecker::message() const
{
    return m_message;
}

QStringList UpdateChecker::updates() const
{
    return m_updates;
}

int UpdateChecker::updateCount() const
{
    return m_updates.size();
}

bool UpdateChecker::checking() const
{
    return m_state == QStringLiteral("checking");
}

QString UpdateChecker::lastChecked() const
{
    return m_lastChecked;
}

void UpdateChecker::setState(const QString &state, const QString &message)
{
    if (m_state == state && m_message == message)
        return;
    m_state = state;
    m_message = message;
    emit stateChanged();
}

void UpdateChecker::checkNow()
{
    if (m_process->state() != QProcess::NotRunning)
        return;

    const QString executable = QStandardPaths::findExecutable(QStringLiteral("checkupdates"));
    if (executable.isEmpty()) {
        m_updates.clear();
        emit updatesChanged();
        setState(QStringLiteral("unavailable"),
                 QStringLiteral("Update checker is missing. Install pacman-contrib."));
        emit checkFinished(false, 0);
        return;
    }

    m_process->setProgram(executable);
    m_process->setArguments({QStringLiteral("--nocolor")});

    QProcessEnvironment environment = QProcessEnvironment::systemEnvironment();
    environment.insert(QStringLiteral("LC_ALL"), QStringLiteral("C"));
    m_process->setProcessEnvironment(environment);

    m_updates.clear();
    emit updatesChanged();
    setState(QStringLiteral("checking"),
             QStringLiteral("Checking available system package updates…"));
    m_process->start();
}

void UpdateChecker::handleFinished(int exitCode, QProcess::ExitStatus exitStatus)
{
    const QByteArray standardOutput = m_process->readAllStandardOutput();
    const QByteArray standardError = m_process->readAllStandardError();

    m_lastChecked = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd hh:mm"));
    const QString output = QString::fromLocal8Bit(standardOutput);
    const QStringList lines = output.split(QLatin1Char('\n'), Qt::SkipEmptyParts);

    QStringList parsedUpdates;
    const QRegularExpression packageLine(
        QStringLiteral(R"(^\s*([^\s]+)\s+([^\s]+)\s+->\s+([^\s]+)\s*$)"));

    for (const QString &line : lines) {
        const QRegularExpressionMatch match = packageLine.match(line);
        if (match.hasMatch()) {
            parsedUpdates.append(QStringLiteral("%1  %2 → %3")
                                     .arg(match.captured(1),
                                          match.captured(2),
                                          match.captured(3)));
        }
    }

    m_updates = parsedUpdates;
    emit updatesChanged();

    if (exitStatus != QProcess::NormalExit) {
        setState(QStringLiteral("error"),
                 QStringLiteral("The update check did not finish normally."));
        emit checkFinished(false, 0);
        return;
    }

    if (exitCode == 0 && !m_updates.isEmpty()) {
        setState(QStringLiteral("updates"),
                 QStringLiteral("%1 system package update(s) are available.")
                     .arg(m_updates.size()));
        emit checkFinished(true, m_updates.size());
        return;
    }

    if (exitCode == 2 || (exitCode == 0 && m_updates.isEmpty())) {
        setState(QStringLiteral("current"),
                 QStringLiteral("No system package updates are currently available."));
        emit checkFinished(false, 0);
        return;
    }

    QString errorText = QString::fromLocal8Bit(standardError).trimmed();
    if (errorText.isEmpty())
        errorText = QString::fromLocal8Bit(standardOutput).trimmed();
    if (errorText.isEmpty())
        errorText = QStringLiteral("Could not check updates. Check the network and package mirrors.");

    setState(QStringLiteral("error"), errorText);
    emit checkFinished(false, 0);
}

void UpdateChecker::handleProcessError(QProcess::ProcessError error)
{
    if (error == QProcess::FailedToStart) {
        m_lastChecked = QDateTime::currentDateTime().toString(QStringLiteral("yyyy-MM-dd hh:mm"));
        setState(QStringLiteral("error"),
                 QStringLiteral("Could not start checkupdates. Check pacman-contrib installation."));
        emit checkFinished(false, 0);
    }
}

void UpdateChecker::clearProcess()
{
    if (m_process->state() != QProcess::NotRunning)
        m_process->kill();
}
