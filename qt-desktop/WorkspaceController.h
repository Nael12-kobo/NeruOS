#pragma once

#include <QObject>
#include <QString>

class WorkspaceController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available CONSTANT)

public:
    explicit WorkspaceController(QObject *parent = nullptr);

    bool available() const;

    Q_INVOKABLE bool switchTo(int index);
    Q_INVOKABLE bool moveActiveTo(int index);
    Q_INVOKABLE bool minimizeActive();
    Q_INVOKABLE bool toggleMaximize();
    Q_INVOKABLE bool snapActiveLeft();
    Q_INVOKABLE bool snapActiveRight();
    Q_INVOKABLE bool closeActive();
    Q_INVOKABLE bool showDesktop();
    Q_INVOKABLE bool nextWindow();
    Q_INVOKABLE bool showWindowMenu();

signals:
    void actionFailed(const QString &message);

private:
    bool sendShortcut(const QStringList &arguments);
    QString m_wtypePath;
};
