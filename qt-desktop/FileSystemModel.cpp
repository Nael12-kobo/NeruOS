#include "FileSystemModel.h"

#include <QDir>
#include <QDesktopServices>
#include <QUrl>
#include <QFile>
#include <QFileInfo>
#include <QLocale>
#include <QRegularExpression>
#include <QStandardPaths>

// GLib headers contain a member named "signals", which clashes with
// Qt's signals macro. Temporarily suspend the macro around the GIO include.
#pragma push_macro("signals")
#undef signals
#include <gio/gio.h>
#pragma pop_macro("signals")

#include <algorithm>

FileSystemModel::FileSystemModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_homePath = QDir::homePath();
    m_currentPath = m_homePath;
    loadDirectory();
}

int FileSystemModel::rowCount(const QModelIndex &parent) const
{
    return parent.isValid() ? 0 : m_entries.size();
}

QVariant FileSystemModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= m_entries.size())
        return {};

    const QFileInfo &entry = m_entries.at(index.row());
    switch (role) {
    case NameRole: return entry.fileName();
    case PathRole: return entry.absoluteFilePath();
    case IsDirectoryRole: return entry.isDir();
    case SizeRole: return entry.isDir() ? QStringLiteral("Folder") : QLocale().formattedDataSize(entry.size());
    case ModifiedRole: return entry.lastModified().toString(QStringLiteral("yyyy-MM-dd hh:mm"));
    case HiddenRole: return entry.isHidden();
    default: return {};
    }
}

QHash<int, QByteArray> FileSystemModel::roleNames() const
{
    return {
        {NameRole, "name"},
        {PathRole, "path"},
        {IsDirectoryRole, "isDirectory"},
        {SizeRole, "sizeText"},
        {ModifiedRole, "modifiedText"},
        {HiddenRole, "hidden"}
    };
}

QString FileSystemModel::currentPath() const { return m_currentPath; }
QString FileSystemModel::homePath() const { return m_homePath; }
int FileSystemModel::count() const { return m_entries.size(); }
bool FileSystemModel::showHidden() const { return m_showHidden; }

void FileSystemModel::setShowHidden(bool enabled)
{
    if (m_showHidden == enabled)
        return;
    m_showHidden = enabled;
    emit showHiddenChanged();
    loadDirectory();
}

QString FileSystemModel::normalizedPath(const QString &path) const
{
    const QFileInfo info(QDir::cleanPath(path));
    return info.canonicalFilePath().isEmpty() ? info.absoluteFilePath() : info.canonicalFilePath();
}

bool FileSystemModel::navigate(const QString &path)
{
    const QString target = normalizedPath(path);
    const QFileInfo info(target);
    if (!info.exists() || !info.isDir() || !info.isReadable()) {
        emit operationFailed(QStringLiteral("This folder cannot be opened."));
        return false;
    }

    if (m_currentPath != target) {
        m_currentPath = target;
        emit currentPathChanged();
    }
    loadDirectory();
    return true;
}

bool FileSystemModel::goUp()
{
    const QDir directory(m_currentPath);
    const QString parent = directory.absolutePath() == directory.rootPath()
                               ? directory.absolutePath()
                               : directory.filePath(QStringLiteral(".."));
    return navigate(parent);
}

bool FileSystemModel::goHome()
{
    return navigate(m_homePath);
}

void FileSystemModel::refresh()
{
    loadDirectory();
}

void FileSystemModel::loadDirectory()
{
    QDir directory(m_currentPath);
    QDir::Filters filters = QDir::AllEntries | QDir::NoDotAndDotDot | QDir::Readable;
    if (m_showHidden)
        filters |= QDir::Hidden;

    const QFileInfoList entries = directory.entryInfoList(
        filters, QDir::DirsFirst | QDir::Name | QDir::IgnoreCase);

    beginResetModel();
    m_entries.clear();
    m_entries.reserve(entries.size());
    for (const QFileInfo &entry : entries)
        m_entries.push_back(entry);
    endResetModel();
    emit countChanged();
}

bool FileSystemModel::openItem(const QString &path)
{
    const QFileInfo info(path);
    if (!info.exists()) {
        emit operationFailed(QStringLiteral("The selected item no longer exists."));
        return false;
    }

    if (info.isDir())
        return navigate(info.absoluteFilePath());

    const QUrl url = QUrl::fromLocalFile(info.absoluteFilePath());
    if (!QDesktopServices::openUrl(url)) {
        emit operationFailed(QStringLiteral("No application could open this file."));
        return false;
    }

    emit itemOpened(info.absoluteFilePath());
    return true;
}

bool FileSystemModel::isSafeChildName(const QString &name) const
{
    const QString value = name.trimmed();
    if (value.isEmpty() || value == QStringLiteral(".") ||
        value == QStringLiteral("..") || value.contains('/') ||
        value.contains('\\') || value.contains(QChar::Null))
        return false;
    return true;
}

bool FileSystemModel::createFolder(const QString &name)
{
    if (!isSafeChildName(name)) {
        emit operationFailed(QStringLiteral("Enter a valid folder name."));
        return false;
    }

    QDir directory(m_currentPath);
    if (!directory.mkdir(name.trimmed())) {
        emit operationFailed(QStringLiteral("The folder could not be created. Check permissions or choose another name."));
        return false;
    }

    loadDirectory();
    return true;
}

bool FileSystemModel::renameItem(const QString &path, const QString &newName)
{
    if (!isSafeChildName(newName)) {
        emit operationFailed(QStringLiteral("Enter a valid new name."));
        return false;
    }

    const QFileInfo source(path);
    if (!source.exists() || source.absolutePath() != QDir(m_currentPath).absolutePath()) {
        emit operationFailed(QStringLiteral("The selected item is outside the current folder."));
        return false;
    }

    const QString target = source.dir().filePath(newName.trimmed());
    if (QFileInfo::exists(target)) {
        emit operationFailed(QStringLiteral("An item with that name already exists."));
        return false;
    }

    if (!QFile::rename(source.absoluteFilePath(), target)) {
        emit operationFailed(QStringLiteral("The item could not be renamed."));
        return false;
    }

    loadDirectory();
    return true;
}

bool FileSystemModel::moveToTrash(const QString &path)
{
    const QFileInfo source(path);
    if (!source.exists() || source.absolutePath() != QDir(m_currentPath).absolutePath()) {
        emit operationFailed(QStringLiteral("The selected item is outside the current folder."));
        return false;
    }

    GFile *file = g_file_new_for_path(source.absoluteFilePath().toUtf8().constData());
    GError *error = nullptr;
    const gboolean moved = g_file_trash(file, nullptr, &error);
    g_object_unref(file);

    if (!moved) {
        const QString message = error
            ? QString::fromUtf8(error->message)
            : QStringLiteral("The item could not be moved to Trash.");
        if (error)
            g_error_free(error);
        emit operationFailed(message);
        return false;
    }

    loadDirectory();
    return true;
}
