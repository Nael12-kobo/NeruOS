#pragma once

#include <QObject>
#include <QProcess>
#include <QStringList>

class UpdateChecker final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString state READ state NOTIFY stateChanged)
    Q_PROPERTY(QString message READ message NOTIFY stateChanged)
    Q_PROPERTY(QStringList updates READ updates NOTIFY updatesChanged)
    Q_PROPERTY(int updateCount READ updateCount NOTIFY updatesChanged)
    Q_PROPERTY(bool checking READ checking NOTIFY stateChanged)
    Q_PROPERTY(QString lastChecked READ lastChecked NOTIFY stateChanged)

public:
    explicit UpdateChecker(QObject *parent = nullptr);
    ~UpdateChecker() override;

    QString state() const;
    QString message() const;
    QStringList updates() const;
    int updateCount() const;
    bool checking() const;
    QString lastChecked() const;

    Q_INVOKABLE void checkNow();

signals:
    void stateChanged();
    void updatesChanged();
    void checkFinished(bool updatesAvailable, int count);

private slots:
    void handleFinished(int exitCode, QProcess::ExitStatus exitStatus);
    void handleProcessError(QProcess::ProcessError error);

private:
    void setState(const QString &state, const QString &message);
    void clearProcess();

    QProcess *m_process = nullptr;
    QString m_state = QStringLiteral("idle");
    QString m_message = QStringLiteral("Check for system package updates.");
    QStringList m_updates;
    QString m_lastChecked;
};
