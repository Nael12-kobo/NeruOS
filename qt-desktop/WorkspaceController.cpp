#include "WorkspaceController.h"

#include <QProcess>
#include <QStandardPaths>

WorkspaceController::WorkspaceController(QObject *parent)
    : QObject(parent),
      m_wtypePath(QStandardPaths::findExecutable(QStringLiteral("wtype")))
{
}

bool WorkspaceController::available() const
{
    return !m_wtypePath.isEmpty();
}

bool WorkspaceController::sendShortcut(const QStringList &arguments)
{
    if (!available()) {
        emit actionFailed(QStringLiteral("Workspace/window shortcuts are unavailable: wtype is not installed."));
        return false;
    }

    if (!QProcess::startDetached(m_wtypePath, arguments)) {
        emit actionFailed(QStringLiteral("The compositor did not accept the requested keyboard shortcut."));
        return false;
    }
    return true;
}

bool WorkspaceController::switchTo(int index)
{
    if (index < 1 || index > 4)
        return false;

    const QString key = QString::number(index);
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-P"), key,
        QStringLiteral("-p"), key,
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}

bool WorkspaceController::moveActiveTo(int index)
{
    if (index < 1 || index > 4)
        return false;

    const QString key = QString::number(index);
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-M"), QStringLiteral("shift"),
        QStringLiteral("-P"), key,
        QStringLiteral("-p"), key,
        QStringLiteral("-m"), QStringLiteral("shift"),
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}

bool WorkspaceController::minimizeActive()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-P"), QStringLiteral("m"),
        QStringLiteral("-p"), QStringLiteral("m"),
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}

bool WorkspaceController::toggleMaximize()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-P"), QStringLiteral("a"),
        QStringLiteral("-p"), QStringLiteral("a"),
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}

bool WorkspaceController::snapActiveLeft()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-P"), QStringLiteral("left"),
        QStringLiteral("-p"), QStringLiteral("left"),
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}

bool WorkspaceController::snapActiveRight()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-P"), QStringLiteral("right"),
        QStringLiteral("-p"), QStringLiteral("right"),
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}

bool WorkspaceController::closeActive()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("alt"),
        QStringLiteral("-P"), QStringLiteral("F4"),
        QStringLiteral("-p"), QStringLiteral("F4"),
        QStringLiteral("-m"), QStringLiteral("alt")
    });
}

bool WorkspaceController::showDesktop()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-P"), QStringLiteral("d"),
        QStringLiteral("-p"), QStringLiteral("d"),
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}

bool WorkspaceController::nextWindow()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("alt"),
        QStringLiteral("-P"), QStringLiteral("Tab"),
        QStringLiteral("-p"), QStringLiteral("Tab"),
        QStringLiteral("-m"), QStringLiteral("alt")
    });
}

bool WorkspaceController::showWindowMenu()
{
    return sendShortcut({
        QStringLiteral("-M"), QStringLiteral("logo"),
        QStringLiteral("-P"), QStringLiteral("space"),
        QStringLiteral("-p"), QStringLiteral("space"),
        QStringLiteral("-m"), QStringLiteral("logo")
    });
}
